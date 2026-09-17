# Disaster Recovery Guide — {{PROJECT_NAME}}

## 1. Applicability

Use this module whenever runtime failure, data loss, artifact corruption, or external dependency outages could compromise business continuity.

## 2. Recovery Objectives

- Recovery Time Objective (RTO): {{RTO}}
- Recovery Point Objective (RPO): {{RPO}}
- Prioritized critical capabilities: {{CRITICAL_CAPABILITIES}}
- Recovery owner: {{RECOVERY_OWNER}}

## 3. Backup & Restore Procedures

- Backup scope: {{BACKUP_SCOPE}}
- Backup frequency & retention: {{BACKUP_RETENTION}}
- Restore source and operational procedure: {{RESTORE_PROCEDURE}}
- Restore integrity verification: {{RESTORE_VERIFICATION}}

## 4. Failure Scenarios

- Runtime environment unavailable: {{RUNTIME_FAILURE_RECOVERY}}
- Stateful dependency / database unavailable: {{STATE_FAILURE_RECOVERY}}
- External service dependency unavailable: {{EXTERNAL_FAILURE_RECOVERY}}
- Corrupted or incompatible release: {{RELEASE_ROLLBACK_RECOVERY}}

## 5. Recovery Readiness Verification

- [ ] Restore procedures assign a clear operational owner.
- [ ] Access to backup files is protected with strict authorization controls.
- [ ] Routine recovery test drills are scheduled.
- [ ] Simulation outcomes and residual recovery gaps are documented.
