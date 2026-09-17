# Routine Infrastructure Maintenance SOP — {{PROJECT_NAME}}

## 1. Schedule & Maintenance Windows

All planned maintenance activities must occur within the authorized maintenance window:
- Maintenance Window: `{{MAINTENANCE_WINDOW}}`
- Target Environment: `{{INFRA_ENVIRONMENT}}`
- Decision Owner: Documented in the project Decision Register.

## 2. Daily Routine Checklist

1. **Disk Utilization Inspection:**
   - Execute `df -h` across all operating nodes. Ensure root (`/`) and data partitions stay below 80% usage.
2. **Service Health Verification:**
   - Run `systemctl status <service_name>` for primary services. Verify `active (running)` state.
3. **System Error Log Audit:**
   - Review critical messages using `journalctl -p err -n 50 --no-pager`.

## 3. Weekly Routine Checklist

1. **Log Rotation & Pruning:**
   - Verify logrotate operates cleanly and compressed log archives are properly handled.
2. **Package Cache & Temporary Files Cleanup:**
   - Execute `apt-get autoremove -y && apt-get clean` (or `dnf clean all` on RHEL/CentOS).
3. **Backup Snapshot Integrity Check:**
   - Confirm weekly backup snapshots successfully arrived at `{{BACKUP_DESTINATION}}`.

## 4. Monthly Routine Checklist (OS Patching & Security Audit)

1. **Operating System Security Updates (`{{PRIMARY_OS}}`):**
   - Apply vendor security updates (`apt-get update && apt-get upgrade -y` filtering security advisories).
   - If a kernel restart is required, perform staged node reboots inside the scheduled window.
2. **User & SSH Key Audit:**
   - Inspect `/etc/passwd` and `~/.ssh/authorized_keys` to ensure no dormant or unauthorized accounts exist.
3. **SSL/TLS Certificate Expiration Inspection:**
   - Check expiration dates for web endpoints and internal CA certificates: `openssl x509 -enddate -noout -in /path/to/cert.pem`.
