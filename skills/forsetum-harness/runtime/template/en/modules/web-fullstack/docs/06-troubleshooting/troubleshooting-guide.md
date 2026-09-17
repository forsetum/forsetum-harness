# Troubleshooting Guide — {{PROJECT_NAME}}

## 1. Triage Sequence

1. Confirm the scope, timestamp, environment, and impacted capability.
2. Review recent deployments, configuration changes, and external dependency updates.
3. Inspect health checks, structured logs, metric anomalies, distributed traces, and persistence state.
4. Safely reproduce the issue without exposing sensitive data.
5. Apply immediate mitigations, record the outcome, and file follow-up issues if required.

## 2. Incident Record Template

- Incident symptom: {{INCIDENT_SYMPTOM}}
- Business / User impact: {{INCIDENT_IMPACT}}
- Detection method: {{INCIDENT_DETECTION}}
- Likely causes: {{INCIDENT_CAUSES}}
- Immediate mitigation: {{INCIDENT_MITIGATION}}
- Verification step: {{INCIDENT_VERIFICATION}}
- Escalation owner: {{INCIDENT_OWNER}}
- Preventive follow-up: {{INCIDENT_FOLLOW_UP}}

## 3. Incident Safety Rules

- Never perform destructive actions as diagnostic steps without verified backups and explicit approval.
- Never paste credentials, secrets, or personal data into issue trackers, chat channels, or log files.
- Strictly distinguish between temporary operational workarounds and permanent root-cause fixes.
