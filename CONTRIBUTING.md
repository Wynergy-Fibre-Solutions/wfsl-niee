# Contributing to WFSL NIEE

## Purpose
WFSL NIEE accepts contributions that strengthen determinism, evidence quality, and verification.
This is an engineering system, not a feature playground.

---

## Contribution Principles

All contributions must:
- Preserve deterministic behaviour.
- Maintain explainable logic.
- Retain raw evidence.
- Respect user control.
- Avoid background execution.

If a change weakens any of these, it will be rejected.

---

## What Can Be Added

Allowed:
- New deterministic diagnostic tests.
- Additional metrics derived from existing data.
- Improvements to classification rules.
- Verification and integrity enhancements.
- Documentation and clarity improvements.

All additions must be optional and explicit.

---

## What Will Not Be Accepted

Not allowed:
- Passive monitoring.
- Packet sniffing or payload inspection.
- Persistent agents or services.
- Covert data collection.
- Opaque or probabilistic decision logic.

These are hard boundaries.

---

## Development Workflow

- One change per commit.
- Full-file replacements only.
- Canonical schema changes require a new version.
- Evidence semantics are immutable once released.

All changes must be reviewable in isolation.

---

## Licensing

By contributing, you agree that your contributions are licensed under the project licence.
Do not submit code you do not have the right to license.

---

## Review Standard

Contributions are evaluated on:
- Correctness.
- Determinism.
- Clarity.
- Maintainability.
- Alignment with WFSL values.

---

End of document.
