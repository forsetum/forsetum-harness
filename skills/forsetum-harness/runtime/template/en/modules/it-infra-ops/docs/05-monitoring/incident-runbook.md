# Incident Response & Emergency Runbook — {{PROJECT_NAME}}

## 1. Incident Severity Matrix

| Severity Level | Impact Definition | Response Target | Escalation Pathway |
|---|---|---|---|
| **P1 - Critical** | Complete service unavailability (Full Outage) | < 15 Minutes | Immediate page to Sysadmin & Leadership |
| **P2 - High** | Major functional disruption or lost node redundancy | < 1 Hour | Operational Team Notification |
| **P3 - Medium** | Performance degradation without functional failure | < 4 Hours | Standard Work Queue Ticket |
| **P4 - Low** | Minor cosmetic glitch or non-critical warning | < 24 Hours | Maintenance Backlog |

## 2. Standard Emergency Runbooks

### Scenario A: Partition 100% Full (Disk Full Emergency)
1. **Identify:** Execute `df -h` to locate the exhausted partition (e.g. `/var/log` or `/var/lib/docker`).
2. **Immediate Remediation:**
   - Locate largest files: `du -ahx /var/log | sort -rh | head -n 10`
   - Truncate active log files safely (do not delete while file handle is open): `> /var/log/<service>/large_file.log`
   - Purge old compressed archives: `find /var/log -name "*.gz" -mtime +30 -delete`
3. **Verify:** Confirm disk utilization drops below 80% and affected services resume write operations.

### Scenario B: Extreme CPU / RAM Spike
1. **Identify:** Launch `top` or `htop`, press `M` to sort by memory or `P` to sort by CPU.
2. **Analysis:** Determine whether the culprit is a runaway database query, application memory leak, or localized DDoS.
3. **Remediation:**
   - Graceful restart: `systemctl reload <service>` or `systemctl restart <service>`.
   - Terminate uncooperative processes: `kill -15 <PID>` (use `kill -9 <PID>` only as last resort).

### Scenario C: Database Locked / Deadlock
1. Inspect active processes: `SELECT * FROM pg_stat_activity WHERE state = 'active';` (PostgreSQL).
2. Cancel blocking queries: `SELECT pg_cancel_backend(<pid>);`.
