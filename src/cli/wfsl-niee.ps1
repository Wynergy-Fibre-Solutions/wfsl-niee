# WFSL NIEE
# Deterministic diagnostics with atomic write and sidecar SHA-256 verification
# PowerShell 5.1+ compatible

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------- Config ----------------
$SchemaId = "wfsl.niee.snapshot.v1"
$ToolName = "wfsl-niee"
$ToolVersion = "0.2.1"
$DefaultExternalTarget = "8.8.8.8"
$PingCount = 50

# ---------------- Helpers ----------------
function Get-Sha256FileHex {
    param([Parameter(Mandatory)][string]$Path)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $fs = [System.IO.File]::OpenRead($Path)
        try {
            ($sha.ComputeHash($fs) | ForEach-Object { $_.ToString("x2") }) -join ""
        } finally {
            $fs.Dispose()
        }
    } finally {
        $sha.Dispose()
    }
}

function Write-AtomicFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )
    $dir = Split-Path $Path -Parent
    $tmp = Join-Path $dir ([System.IO.Path]::GetRandomFileName())
    [System.IO.File]::WriteAllText($tmp, $Content, [System.Text.Encoding]::UTF8)
    Move-Item -Force $tmp $Path
}

function Get-OsInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    @{
        os = "Windows"
        osVersion = $os.Version
        architecture = $env:PROCESSOR_ARCHITECTURE
        hostname = $env:COMPUTERNAME
    }
}

function Get-PrimaryInterface {
    $ip = Get-NetIPConfiguration | Where-Object {
        $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq "Up"
    } | Select-Object -First 1
    if (-not $ip) { throw "No active network interface with IPv4 gateway found" }
    @{
        name = $ip.InterfaceAlias
        type = if ($ip.NetAdapter.MediaType -match "802\.11") { "wifi" } else { "ethernet" }
        gateway = $ip.IPv4DefaultGateway.NextHop
        ipv4 = $ip.IPv4Address.IPAddress
        ipv6 = $null
    }
}

function Invoke-PingTest {
    param(
        [Parameter(Mandatory)][string]$Target,
        [int]$Count = 50
    )
    $raw = @()
    $times = @()
    $sent = $Count
    $received = 0

    for ($i = 0; $i -lt $Count; $i++) {
        try {
            $r = Test-Connection -TargetName $Target -Count 1 -TimeoutSeconds 2 -ErrorAction Stop
            if ($null -ne $r -and $r.ResponseTime -ge 0) {
                $received++
                $times += [double]$r.ResponseTime
                $raw += ("Reply time={0}ms" -f $r.ResponseTime)
            } else {
                $raw += "Request timed out"
            }
        } catch {
            $raw += "Request timed out"
        }
    }

    $lossPercent = if ($sent -eq 0) { 100 } else {
        [math]::Round((($sent - $received) / $sent) * 100, 2)
    }

    $lat = if ($times.Count -gt 0) {
        @{
            min = [math]::Round(($times | Measure-Object -Minimum).Minimum, 2)
            avg = [math]::Round(($times | Measure-Object -Average).Average, 2)
            max = [math]::Round(($times | Measure-Object -Maximum).Maximum, 2)
        }
    } else {
        @{ min = 0; avg = 0; max = 0 }
    }

    @{
        target = $Target
        sent = $sent
        received = $received
        lossPercent = $lossPercent
        latencyMs = $lat
        raw = $raw
    }
}

function Classify-Fault {
    param(
        [hashtable]$GatewayPing,
        [hashtable]$ExternalPing,
        [hashtable]$Iface
    )

    $rationale = @()
    $classification = "HEALTHY"
    $confidence = "HIGH"

    if ($GatewayPing.received -eq 0) {
        $classification = "LAN_FAULT"
        $rationale += "No successful replies from gateway"
    }
    elseif ($ExternalPing.received -eq 0) {
        $classification = "WAN_FAULT"
        $rationale += "No successful replies beyond gateway"
    }
    elseif ($ExternalPing.lossPercent -gt 5) {
        $classification = "WAN_FAULT"
        $rationale += "Packet loss detected beyond gateway"
    }

    if ($ExternalPing.lossPercent -gt 20 -and
        ($ExternalPing.latencyMs.max - $ExternalPing.latencyMs.min) -gt 150) {
        $classification = "INTERMITTENT_DEGRADATION"
        $confidence = "MEDIUM"
        $rationale += "High latency variance with intermittent packet loss"
    }

    $rationale += ("Interface used: {0} ({1}), Gateway: {2}" -f $Iface.name, $Iface.type, $Iface.gateway)

    if ($rationale.Count -eq 0) { $rationale += "No packet loss detected" }

    @{
        classification = $classification
        confidence = $confidence
        rationale = $rationale
    }
}

# ---------------- Verify Mode ----------------
if ($args.Count -ge 1 -and $args[0] -eq "verify") {
    if ($args.Count -lt 2) { throw "Usage: pwsh .\src\cli\wfsl-niee.ps1 verify <snapshot.json>" }
    $snap = Resolve-Path $args[1]
    $sidecar = "$snap.sha256"
    if (-not (Test-Path $sidecar)) { throw "Missing sidecar hash file: $sidecar" }

    $expected = (Get-Content -Raw -Path $sidecar).Trim()
    $actual = Get-Sha256FileHex -Path $snap

    if ($actual -eq $expected) {
        Write-Host "VERIFY PASS"
        Write-Host $actual
        exit 0
    } else {
        Write-Host "VERIFY FAIL"
        Write-Host ("expected: {0}" -f $expected)
        Write-Host ("actual:   {0}" -f $actual)
        exit 2
    }
}

# ---------------- Execute Diagnostics ----------------
$hostInfo = Get-OsInfo
$iface = Get-PrimaryInterface

$gatewayPing = Invoke-PingTest -Target $iface.gateway -Count $PingCount
$externalPing = Invoke-PingTest -Target $DefaultExternalTarget -Count $PingCount

$analysis = Classify-Fault -GatewayPing $gatewayPing -ExternalPing $externalPing -Iface $iface

$resolutionText = switch ($analysis.classification) {
    "LAN_FAULT" { "No successful replies from the local gateway. Investigate local network hardware or Wi-Fi." }
    "WAN_FAULT" { "Local network healthy. Connectivity fails beyond the gateway. Escalate to ISP." }
    "INTERMITTENT_DEGRADATION" { "Intermittent loss and high latency variance detected beyond the gateway." }
    default { "No actionable fault detected." }
}

$snapshot = @{
    wfsl = @{
        schema = $SchemaId
        tool = @{ name = $ToolName; version = $ToolVersion; buildHash = "" }
        capturedUtc = (Get-Date).ToUniversalTime().ToString("o")
    }
    host = @{
        os = $hostInfo.os
        osVersion = $hostInfo.osVersion
        hostname = $hostInfo.hostname
        architecture = $hostInfo.architecture
        interfaces = @($iface)
    }
    tests = @{
        gatewayPing = $gatewayPing
        externalPing = $externalPing
    }
    analysis = $analysis
    resolution = @{
        summary = $analysis.classification
        nextAction = "Review escalation guidance"
        escalationText = $resolutionText
    }
    integrity = @{
        hashAlg = "SHA-256"
        signature = $null
        signingKeyId = $null
    }
}

$finalJson = ($snapshot | ConvertTo-Json -Depth 8)
$outPath = Join-Path (Get-Location) ("niee-snapshot-" + (Get-Date -Format "yyyyMMddTHHmmss") + ".json")
Write-AtomicFile -Path $outPath -Content $finalJson

$hash = Get-Sha256FileHex -Path $outPath
$hash | Set-Content -Encoding ASCII -Path ($outPath + ".sha256")

Write-Host "WFSL NIEE snapshot written to:"
Write-Host $outPath
Write-Host ("SHA-256 (sidecar): {0}" -f $hash)
