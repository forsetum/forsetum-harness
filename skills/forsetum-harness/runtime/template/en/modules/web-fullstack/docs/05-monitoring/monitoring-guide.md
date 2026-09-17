# Monitoring & Observability Guide — {{PROJECT_NAME}}

## 1. Applicability

Use this module for projects running background processes, scheduled jobs, asynchronous queues, public APIs, or operational SLOs. For static libraries or CLI tools, record `Not Applicable` in the Decision Register and document release validation procedures.

## 2. Telemetry Signals

- Health / Readiness check: {{HEALTH_SIGNAL}}
- Performance metrics: {{METRICS_SIGNAL}}
- Structured logging: {{LOGGING_SIGNAL}}
- Distributed tracing: {{TRACING_SIGNAL}}
- Business & quality signals: {{BUSINESS_SIGNAL}}

## 3. Alerts

- Critical alert (P1 / Critical): {{CRITICAL_ALERT}}
- Warning alert (P2 / Warning): {{WARNING_ALERT}}
- Escalation owner: {{ALERT_OWNER}}
- Suppression & maintenance rules: {{ALERT_MAINTENANCE_RULE}}

## 4. Privacy & Cost Governance

- Sensitive and personal data must be redacted or excluded from telemetry.
- Retention periods and sampling rates follow project data governance policies.
- High-cardinality or unbounded payloads must not be emitted by default.

## 5. Verification

- [ ] Health signal endpoints respond accurately.
- [ ] Alerting rules can be safely tested without exposing sensitive data.
- [ ] Dashboards and runbook links are current and accessible.
