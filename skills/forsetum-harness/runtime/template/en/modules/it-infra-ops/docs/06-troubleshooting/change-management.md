# Change Management Protocol & Maintenance Windows — {{PROJECT_NAME}}

## 1. Principles of Change Management

Direct ad-hoc configuration edits, kernel upgrades, or network changes in `{{INFRA_ENVIRONMENT}}` without documented procedures and approval are strictly prohibited.

## 2. Pre-Flight Checklist

Prior to initiating operations inside `{{MAINTENANCE_WINDOW}}`:

- [ ] All stakeholders have received maintenance notification at least 24 hours in advance.
- [ ] Complete system snapshot and database backup verified in `{{BACKUP_DESTINATION}}`.
- [ ] Step-by-step change execution plan reviewed with peers.
- [ ] Tested, concrete rollback procedure ready for immediate trigger if required.

## 3. Execution & Rollback Procedure

### Standard Execution Steps:
1. Enable maintenance banner at the reverse proxy layer.
2. Gracefully stop dependent application services to halt new database writes.
3. Apply targeted configuration changes or `{{PRIMARY_OS}}` system patches.
4. Execute smoke tests verifying primary ports and endpoints.
5. Disable maintenance banner and restore public access.

### Mandatory Rollback Triggers:
- Upgrade exceeds scheduled timeline with less than 30 minutes left in `{{MAINTENANCE_WINDOW}}`.
- Unresolved kernel instability or core dependency corruption occurs.
- Primary services fail to achieve healthy status after 3 recovery attempts.

**Rollback Action:**
1. Abort deployment activity immediately.
2. Restore configuration files from `/etc` backups or revert hypervisor VM snapshots.
3. Restart original services and confirm all operational checks pass.
4. Document the root cause in the post-maintenance incident record.
