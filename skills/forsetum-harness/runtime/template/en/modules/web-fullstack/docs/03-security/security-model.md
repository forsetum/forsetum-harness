# Security Model — {{PROJECT_NAME}}

## 1. Security Scope

This document details protected assets, identified threats, security controls, and residual risks. Include only controls that are actually implemented.

## 2. Assets & Trust Boundaries

- Protected assets: {{PROTECTED_ASSETS}}
- Trusted components: {{TRUSTED_COMPONENTS}}
- Untrusted inputs: {{UNTRUSTED_INPUTS}}
- External security boundaries: {{SECURITY_BOUNDARIES}}
- Data classification: {{DATA_CLASSIFICATION}}
- Authentication strategy & session management: {{AUTH_STRATEGY}}

## 3. Threats & Security Controls

- **Unauthorized access:** {{ACCESS_CONTROL}}
- **Input abuse / Injection:** {{INPUT_VALIDATION_CONTROL}}
- **Secret exposure:** {{SECRET_MANAGEMENT_CONTROL}}
- **Data leakage / Privacy violation:** {{DATA_PROTECTION_CONTROL}}
- **Resource exhaustion:** {{RESOURCE_PROTECTION_CONTROL}}
- **Dependency compromise:** {{DEPENDENCY_SECURITY_CONTROL}}
- **Tampering / Replay attacks:** {{INTEGRITY_CONTROL}}

## 4. Operational Controls

- Secure logging without sensitive data: {{SECURE_LOGGING_CONTROL}}
- Security monitoring & alerts: {{SECURITY_MONITORING_CONTROL}}
- Incident response procedure: {{SECURITY_INCIDENT_PROCEDURE}}
- Data retention and deletion policy: {{RETENTION_POLICY}}

## 5. Security Verification

- [ ] All threats mapped to requirements and test suites.
- [ ] Secrets and credentials are not stored in source code, repositories, artifacts, or logs.
- [ ] Access controls and input validation are verified through automated or manual tests.
- [ ] Residual risks and accepted exceptions are documented in the Decision Register.
