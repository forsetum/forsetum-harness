# Template Variable Registry

This registry defines the official instantiation contract of the AI Harness template. Populate all required variables, customize optional variables to match project capabilities, and ensure all placeholders are eliminated from final instantiated project outputs.

## 1. Project Context

| Variable | Required? | Description |
|---|---:|---|
| `PROJECT_NAME` | Yes | Official name of the project |
| `PROJECT_MISSION` | Yes | High-level purpose and core objective of this project |
| `DECISION_OWNER` | Yes | Primary human stakeholder authorized to confirm decisions |
| `PROJECT_DESCRIPTION` | Yes | Brief summary of project purpose and functionality |
| `PROJECT_TYPE` | Yes | Project type (e.g., library, REST API service, web app, CLI tool, background worker) |
| `PRIMARY_STAKEHOLDERS` | Yes | Primary users or key project stakeholders |
| `PROBLEM_STATEMENT` | Yes | Core problem solved by this project |
| `PRIMARY_LANGUAGE` | Yes | Primary programming language |
| `FRAMEWORK` | Yes | Primary framework/platform or `N/A` |
| `RUNTIME` | Yes | Execution runtime or `N/A` |
| `PACKAGE_MANAGER` | Yes | Package manager / build toolchain or `N/A` |
| `PERSISTENCE_STRATEGY` | Yes | Persistence / database strategy or `N/A` |
| `PERSISTENCE_MIGRATION_STRATEGY` | Yes | Schema / data migration strategy or `N/A` |
| `AUTH_STRATEGY` | Yes | Authentication and session strategy (Recommended default: NextAuth.js / Auth.js; Alternatives: Supabase Auth, Clerk, or Custom Manual Session) |
| `DOMAIN_NAME` | Yes | Business domain or `General Application` |
| `CRITICAL_DATA_AREA` | Yes | Critical data assets requiring specialized privacy/security controls or `N/A` |

## 2. Commands and Operations

| Variable | Required? | Description |
|---|---:|---|
| `ENV_SETUP_COMMAND` | Yes | Environment setup command or `N/A` |
| `RUN_OR_BUILD_COMMAND` | Yes | Command to run or build the project locally or `N/A` |
| `TEST_COMMAND` | Yes | Primary test execution command or `N/A` |
| `INTEGRATION_TEST_COMMAND` | No | Secondary integration test command if applicable |
| `BUILD_COMMAND` | No | Build/packaging command if distinct from run command |
| `DEPLOY_COMMAND` | Yes | Deployment command or release procedure reference or `N/A` |
| `HEALTHCHECK_PATH` | Yes | Health check URL or diagnostic command or `N/A` |

## 3. Requirements and Flow

| Variable | Required? | Description |
|---|---:|---|
| `BUSINESS_GOAL_1` | Yes | Primary business objective |
| `TECHNICAL_GOAL_1` | Yes | Primary technical objective |
| `NON_GOAL_1` | No | Explicitly out-of-scope non-goal |
| `CORE_FEATURE_1` | Yes | First core feature |
| `OUT_OF_SCOPE_FEATURE_1` | No | Explicitly excluded feature |
| `FR_TITLE` | Yes | Title of first functional requirement |
| `FR_DESCRIPTION` | Yes | Detailed description of first functional requirement |
| `PRIMARY_FLOW_TITLE` | No | Title of primary operational flow |
| `PRIMARY_ACTOR` | No | Primary system actor |
| `STATE_1` | No | Initial lifecycle state |
| `TRANSITION_1` | No | Trigger action for state transition |

## 4. Architecture and Deployment

The following architecture and deployment variables must be explicitly set to `N/A` if the corresponding capability is unused, and must never be left blank:

`ENTRYPOINTS`, `CORE_COMPONENTS`, `PERSISTENCE_COMPONENTS`, `ASYNC_COMPONENTS`, `EXTERNAL_DEPENDENCIES`, `PUBLIC_INTERFACES`, `INTERNAL_INTERFACES`, `CONFIGURATION_BOUNDARY`, `RESOURCE_LIMITS`, `SCALING_MODEL`, `DEPLOYMENT_ENVIRONMENTS`, `RUNTIME_CONFIGURATION`, `SECRET_CONFIGURATION`, `DEPENDENCY_ENDPOINTS`, `OBSERVABILITY_CONFIGURATION`, `DEPLOY_STEP_1`, `DEPLOY_STEP_2`, `ROLLBACK_TRIGGER`, `ROLLBACK_PROCEDURE`, `DATA_COMPATIBILITY_RULE`, `DOWNTIME_EXPECTATION`.

## 5. Instantiation Values

In instantiated project documentation, complete the Value column for each required variable below. Never delete these rows. Values must be concrete or `N/A` supported by a Decision ID and written rationale in the Decision Register.

| Variable | Value |
|---|---|
| `PROJECT_NAME` | `{{PROJECT_NAME}}` |
| `PROJECT_MISSION` | `{{PROJECT_MISSION}}` |
| `DECISION_OWNER` | `{{DECISION_OWNER}}` |
| `PROJECT_DESCRIPTION` | `{{PROJECT_DESCRIPTION}}` |
| `PROJECT_TYPE` | `{{PROJECT_TYPE}}` |
| `PRIMARY_STAKEHOLDERS` | `{{PRIMARY_STAKEHOLDERS}}` |
| `PROBLEM_STATEMENT` | `{{PROBLEM_STATEMENT}}` |
| `PRIMARY_LANGUAGE` | `{{PRIMARY_LANGUAGE}}` |
| `FRAMEWORK` | `{{FRAMEWORK}}` |
| `RUNTIME` | `{{RUNTIME}}` |
| `PACKAGE_MANAGER` | `{{PACKAGE_MANAGER}}` |
| `PERSISTENCE_STRATEGY` | `{{PERSISTENCE_STRATEGY}}` |
| `PERSISTENCE_MIGRATION_STRATEGY` | `{{PERSISTENCE_MIGRATION_STRATEGY}}` |
| `AUTH_STRATEGY` | `{{AUTH_STRATEGY}}` |
| `DOMAIN_NAME` | `{{DOMAIN_NAME}}` |
| `CRITICAL_DATA_AREA` | `{{CRITICAL_DATA_AREA}}` |
| `ENV_SETUP_COMMAND` | `{{ENV_SETUP_COMMAND}}` |
| `RUN_OR_BUILD_COMMAND` | `{{RUN_OR_BUILD_COMMAND}}` |
| `TEST_COMMAND` | `{{TEST_COMMAND}}` |
| `DEPLOY_COMMAND` | `{{DEPLOY_COMMAND}}` |
| `HEALTHCHECK_PATH` | `{{HEALTHCHECK_PATH}}` |
| `BUSINESS_GOAL_1` | `{{BUSINESS_GOAL_1}}` |
| `TECHNICAL_GOAL_1` | `{{TECHNICAL_GOAL_1}}` |
| `CORE_FEATURE_1` | `{{CORE_FEATURE_1}}` |
| `FR_TITLE` | `{{FR_TITLE}}` |
| `FR_DESCRIPTION` | `{{FR_DESCRIPTION}}` |

## 6. Rules

- Variable names use only uppercase letters (A-Z), numbers (0-9), and underscores (`_`).
- Variable values must never contain secrets, credentials, access tokens, or sensitive personal data.
- Inapplicable placeholders are populated with `N/A` in the final instantiated output.
- Structural validators will reject unregistered placeholders.

## 7. Instantiation Contract

Every project decision affecting documentation or implementation must be recorded in the [Decision Register](decision-register.md). Use only these canonical decision statuses:

| Status | Meaning | Impact on Readiness |
|---|---|---|
| `Confirmed` | The answer has been chosen and confirmed by the authorized human user. | Satisfies readiness when accompanied by concrete rationale and references. |
| `Not Applicable` | The capability or decision is genuinely inapplicable to the project. | Satisfies readiness only when justified with written rationale. |
| `Open` | The question is identified, but remains undecided. | Blocks readiness (*blocking*). |
| `Unknown` | Information is not yet available or cannot currently be verified. | Blocks readiness (*blocking*). |
| `Assumption` | A provisional answer awaiting human user confirmation. | Blocks readiness; requires confirmation prior to implementation. |

Only `Confirmed` and justified `Not Applicable` statuses satisfy the readiness gate. The source template retains registered placeholders listed below; instantiated project outputs must replace all placeholders with concrete values.

## 8. Complete Placeholder Index

The following names represent all official placeholders provided by the AI Harness template:

```text
ACCESSIBILITY_REQUIREMENT
ACCESS_CONTROL
ALERT_MAINTENANCE_RULE
ALERT_OWNER
ASYNC_COMPONENTS
AUTH_STRATEGY
AVAILABILITY_REQUIREMENT
BACKEND_STACK
BACKLOG_ITEM_1
BACKLOG_ITEM_2
BACKLOG_ITEM_3
BACKUP_RETENTION
BACKUP_SCOPE
BUILD_COMMAND
BUSINESS_GOAL_1
BUSINESS_SIGNAL
CAPABILITY_ACTOR
CAPABILITY_COMPATIBILITY
CAPABILITY_DEPENDENCIES
CAPABILITY_DEPENDENCY_FAILURE
CAPABILITY_FAILURE_PATH_TEST
CAPABILITY_HAPPY_PATH_TEST
CAPABILITY_INPUTS
CAPABILITY_INVALID_INPUT
CAPABILITY_NAME
CAPABILITY_OUTPUTS
CAPABILITY_PERMISSION_FAILURE
CAPABILITY_REQUIREMENTS
CAPABILITY_STEP_1
CAPABILITY_STEP_2
CAPABILITY_STEP_3
CONFIGURATION_BOUNDARY
CORE_COMPONENTS
CORE_FEATURE_1
CREDENTIAL_CONFIGURATION_NOTES
CREDENTIAL_CONFIGURATION_REQUIRED
CREDENTIAL_CONFIGURATION_SECRET
CREDENTIAL_CONFIGURATION_SOURCE
CRITICAL_ALERT
CRITICAL_CAPABILITIES
CRITICAL_DATA_AREA
DATA_CLASSIFICATION
DATA_COMPATIBILITY_RULE
DATA_PROTECTION_CONTROL
DEPENDENCY_CONFIGURATION_NOTES
DEPENDENCY_CONFIGURATION_REQUIRED
DEPENDENCY_CONFIGURATION_SECRET
DEPENDENCY_CONFIGURATION_SOURCE
DEPENDENCY_ENDPOINTS
DEPENDENCY_FAILURE_BEHAVIOR
DEPENDENCY_SECURITY_CONTROL
DEPLOYMENT_ENVIRONMENTS
DEPLOY_COMMAND
DEPLOY_STEP_1
DEPLOY_STEP_2
DOMAIN_NAME
DOMAIN_RULE_1
DOMAIN_RULE_2
DOWNTIME_EXPECTATION
ENTRYPOINTS
ENV_SETUP_COMMAND
EXTERNAL_DEPENDENCIES
EXTERNAL_FAILURE_RECOVERY
EXTERNAL_SYSTEMS
FRAMEWORK
FRONTEND_STACK
FR_DESCRIPTION
FR_TITLE
GLOSSARY_DEFINITION_1
GLOSSARY_TERM_1
HEALTHCHECK_PATH
HEALTH_SIGNAL
INCIDENT_CAUSES
INCIDENT_DETECTION
INCIDENT_FOLLOW_UP
INCIDENT_IMPACT
INCIDENT_MITIGATION
INCIDENT_OWNER
INCIDENT_SYMPTOM
INCIDENT_VERIFICATION
INPUT_VALIDATION_CONTROL
INTEGRATION_TEST_COMMAND
INTEGRITY_CONTROL
INTERNAL_COMPONENTS
INTERNAL_INTERFACES
INVALID_INPUT_BEHAVIOR
LIMIT_CONFIGURATION_NOTES
LIMIT_CONFIGURATION_REQUIRED
LIMIT_CONFIGURATION_SOURCE
LOGGING_SIGNAL
METRICS_SIGNAL
MIGRATE_COMMAND
MODEL_PATH
NON_GOAL_1
OBSERVABILITY_CONFIGURATION
OBSERVABILITY_CONFIGURATION_NOTES
OBSERVABILITY_CONFIGURATION_REQUIRED
OBSERVABILITY_CONFIGURATION_SECRET
OBSERVABILITY_CONFIGURATION_SOURCE
OUT_OF_SCOPE_FEATURE_1
PACKAGE_MANAGER
PARTIAL_FAILURE_BEHAVIOR
PERFORMANCE_REQUIREMENT
PERSISTENCE_COMPONENTS
PERSISTENCE_MIGRATION_STRATEGY
PERSISTENCE_STRATEGY
PRIMARY_ACTOR
PRIMARY_LANGUAGE
PRIMARY_STAKEHOLDERS
PROBLEM_STATEMENT
PROJECT_ASSUMPTIONS
PROJECT_CONSTRAINTS
PROJECT_DESCRIPTION
PROJECT_MISSION
PROJECT_NAME
DECISION_OWNER
PROJECT_RISKS
PROJECT_TYPE
PROTECTED_ASSETS
PUBLIC_INTERFACES
RECOVERY_OWNER
RELEASE_ROLLBACK_RECOVERY
RESOURCE_LIMITS
RESOURCE_PROTECTION_CONTROL
RESTORE_PROCEDURE
RESTORE_VERIFICATION
RETENTION_POLICY
RETRY_IDEMPOTENCY_BEHAVIOR
ROLLBACK_PROCEDURE
ROLLBACK_TRIGGER
ROUTER_PATH
RPO
RTO
RUNTIME
RUNTIME_CONFIGURATION
RUNTIME_CONFIGURATION_NOTES
RUNTIME_CONFIGURATION_REQUIRED
RUNTIME_CONFIGURATION_SECRET
RUNTIME_CONFIGURATION_SOURCE
RUNTIME_FAILURE_RECOVERY
RUN_OR_BUILD_COMMAND
SCALING_MODEL
SCHEMA_PATH
SECRET_CONFIGURATION
SECRET_MANAGEMENT_CONTROL
SECURE_LOGGING_CONTROL
SECURITY_BOUNDARIES
SECURITY_INCIDENT_PROCEDURE
SECURITY_MONITORING_CONTROL
SECURITY_REQUIREMENT
SERVICE_PATH
STATE_1
STATE_2
STATE_FAILURE_RECOVERY
STEP_1_DESCRIPTION
STORAGE_STACK
SUPPORTING_ACTORS
TECHNICAL_GOAL_1
TEST_COMMAND
TRACING_SIGNAL
TRANSITION_1
TRUSTED_COMPONENTS
UNAUTHORIZED_BEHAVIOR
UNTRUSTED_INPUTS
WARNING_ALERT
```
