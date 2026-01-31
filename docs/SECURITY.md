# WFSL NIEE Security Model

## Security Philosophy
WFSL NIEE is built on **minimisation and determinism**.
Security is achieved by reducing surface area, not by complexity.

---

## What NIEE Does Securely

- Runs only when explicitly invoked.
- Executes a finite, auditable set of diagnostics.
- Preserves raw outputs without modification.
- Produces a sealed evidence artefact.

No hidden behaviour.

---

## Data Handling

- All data is generated locally.
- No automatic transmission.
- No background collection.
- No third-party endpoints.

Users decide if and where evidence is shared.

---

## Cryptographic Integrity

- SHA-256 used for snapshot integrity.
- Optional signing supported.
- Hashes are embedded into the artefact itself.
- Tampering is detectable.

This enables independent verification.

---

## Attack Surface

Reduced by design:
- No network listeners.
- No inbound ports.
- No persistent services.
- No privileged system hooks.

The CLI exits after completion.

---

## Threats Explicitly Out of Scope

WFSL NIEE does not attempt to mitigate:
- Nation-state interception.
- ISP-level surveillance.
- Physical compromise of the host.

It provides **evidence**, not concealment.

---

## Compliance Posture

WFSL NIEE:
- Does not inspect content.
- Does not process personal data beyond device metadata.
- Does not perform surveillance.

It is compatible with common data protection principles.

---

## Responsible Use

WFSL NIEE is intended for:
- Diagnostics.
- Evidence generation.
- Dispute resolution.
- Engineering validation.

It is not a hacking tool.

---

End of document.
