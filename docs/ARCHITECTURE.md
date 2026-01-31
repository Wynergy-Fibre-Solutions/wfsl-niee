# WFSL NIEE Architecture

## Overview
WFSL NIEE is a deterministic, evidence-first diagnostic engine.
It is designed to isolate network fault domains, preserve proof, and support resolution without ambiguity.

The system is intentionally simple, explainable, and extensible.

---

## Execution Model

- User-initiated execution only.
- Single-run snapshot per invocation.
- No daemons, agents, or background processes.
- No persistent telemetry.

Each run is self-contained.

---

## Component Layers

### 1. CLI Runner (PowerShell v1)
- Executes diagnostic primitives.
- Collects raw outputs.
- Normalises metrics.
- Emits a single snapshot artefact.

### 2. Evidence Contract
- Canonical JSON schema.
- Stable semantics.
- Forward expansion via versioning only.
- Machine-verifiable.

### 3. Classification Engine
- Rule-based logic.
- Deterministic outcomes.
- Explicit rationale for each decision.

No probabilistic inference.

### 4. Integrity Layer
- SHA-256 hashing.
- Optional Ed25519 signing.
- Verifier-compatible structure.

Ensures tamper evidence.

---

## Data Flow

1. User executes NIEE CLI.
2. Diagnostics run sequentially.
3. Raw outputs captured.
4. Metrics derived.
5. Fault classified.
6. Resolution guidance generated.
7. Snapshot sealed and written.

No external dependencies.

---

## Expansion Strategy

Authorised expansion is vertical, not horizontal.

Allowed:
- Additional deterministic tests.
- Time-series snapshot correlation.
- Federated evidence (opt-in).
- Provider reliability analysis.

Disallowed:
- Passive traffic capture.
- Payload inspection.
- Continuous monitoring.
- Covert data collection.

---

## Trust Boundaries

- User controls execution.
- User controls storage.
- User controls sharing.

WFSL provides tooling, not surveillance.

---

## Positioning

WFSL NIEE is:
- Not a speed test.
- Not a monitoring agent.
- Not a consumer gimmick.

It is a network integrity proof engine.

---

End of document.
