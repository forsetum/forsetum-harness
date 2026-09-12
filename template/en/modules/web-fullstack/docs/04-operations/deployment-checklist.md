# Deployment & Runtime Validation Checklist — {{PROJECT_NAME}}

## 1. Scope

Use this checklist when provisioning environments, releasing updates, or diagnosing startup/runtime issues. Check conditional items only if the corresponding capability is active.

## 2. Configuration

- [ ] Runtime and toolchain match the documented [technical context](../00-overview/mission.md).
- [ ] Non-secret configurations are available and valid.
- [ ] Secrets and credentials are provided via environment variables or secret managers, not in source code.
- [ ] Required endpoints and external dependencies are reachable.
- [ ] Resource limits and timeouts are properly configured for the target environment.
- [ ] Exposed interfaces and ports have been verified for security compliance.

## 3. Security

- [ ] Authentication and authorization mechanisms verified where applicable.
- [ ] Input validation and rate limiting verified where applicable.
- [ ] Privacy controls and data classification rules enforced.
- [ ] Application responses, build artifacts, and logs do not leak secrets or personal data.

## 4. Runtime Validation

- [ ] The service or application starts up cleanly, or build artifacts execute as expected.
- [ ] Health and readiness check endpoints succeed.
- [ ] Persistence layers, queues, and external integrations validate successfully.
- [ ] Primary flow smoke tests pass.
- [ ] Failure handling and retry behaviors operate correctly.
- [ ] Observability signals, alerts, and structured logs are active.

## 5. Rollback

- [ ] Backups, snapshots, or rollback commit references exist prior to data/schema modifications.
- [ ] Rollback procedures are tested or thoroughly reviewed.
- [ ] Release version and validation results are recorded.

## 6. Definition of Done

- [ ] All applicable checklist items pass.
- [ ] Any inapplicable items carry documented written justifications.
- [ ] No critical blockers remain for the target environment.
