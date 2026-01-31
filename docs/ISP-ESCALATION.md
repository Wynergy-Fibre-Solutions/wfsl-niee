# WFSL NIEE – ISP Escalation Pack

## Purpose
This document provides exact, evidence-backed wording for escalating network faults to an ISP.
It is generated to align with WFSL NIEE snapshot classifications.

Use this text verbatim. Do not dilute.

---

## How to Use
1. Run WFSL NIEE and generate a snapshot.
2. Confirm the classification in the snapshot.
3. Copy the matching escalation text below.
4. Submit via ISP chat, email, or fault ticket.

Attach the NIEE snapshot file if requested.

---

## LAN_FAULT

**Statement**
I am experiencing packet loss to my local gateway.  
This indicates a local network fault rather than an external routing issue.

Please investigate local wiring, router hardware, or Wi-Fi infrastructure.

---

## WAN_FAULT

**Statement**
My local network is confirmed healthy with zero packet loss to the gateway.  
Sustained packet loss begins beyond the gateway, indicating a WAN-side issue.

Please investigate line quality, error rates, congestion, or routing instability on your network.

---

## UPSTREAM_CONGESTION

**Statement**
Diagnostics show high latency variance and packet loss beyond the gateway during normal usage periods.  
This pattern is consistent with upstream congestion or backhaul saturation.

Please investigate capacity and routing beyond my local connection.

---

## INTERMITTENT_DEGRADATION

**Statement**
Intermittent packet loss and significant latency variance are present beyond the gateway.  
Local network tests are clean.

Please investigate line stability, noise margins, and transient faults on the WAN side.

---

## HEALTHY

**Statement**
Current diagnostics show no packet loss or abnormal latency.  
No ISP-side fault is indicated at this time.

---

## Notes for Support Agents
- LAN health has already been verified.
- Evidence is timestamped and repeatable.
- Diagnostics are user-initiated and deterministic.
- The snapshot includes raw outputs and metrics.

WFSL NIEE evidence is not a speed test.
It is a fault attribution record.
