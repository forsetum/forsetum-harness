# Registry Variabel Template (Template Variable Registry)

Registry ini adalah kontrak instansiasi resmi dari template AI Harness. Isi seluruh variabel yang wajib (*required*), sesuaikan variabel opsional dengan kapabilitas proyek, lalu pastikan seluruh placeholder dihapus dari keluaran akhir proyek yang diinstansiasi.

## 1. Konteks Proyek (Project Context)

| Variabel | Wajib? | Kegunaan |
|---|---:|---|
| `PROJECT_NAME` | Ya | Nama resmi proyek |
| `PROJECT_MISSION` | Ya | Misi utama dan sasaran tingkat tinggi proyek |
| `DECISION_OWNER` | Ya | Pemangku kepentingan utama yang berwenang mengonfirmasi keputusan |
| `PROJECT_DESCRIPTION` | Ya | Deskripsi singkat fungsi proyek |
| `PROJECT_TYPE` | Ya | Jenis proyek (misal: library, REST API service, web app, CLI, worker) |
| `PRIMARY_STAKEHOLDERS` | Ya | Pengguna atau pemangku kepentingan utama |
| `PROBLEM_STATEMENT` | Ya | Masalah utama yang diselesaikan oleh proyek |
| `PRIMARY_LANGUAGE` | Ya | Bahasa pemrograman utama |
| `FRAMEWORK` | Ya | Framework/platform utama atau `N/A` |
| `RUNTIME` | Ya | Runtime eksekusi atau `N/A` |
| `PACKAGE_MANAGER` | Ya | Manajer paket / toolchain atau `N/A` |
| `PERSISTENCE_STRATEGY` | Ya | Strategi persistensi/database atau `N/A` |
| `PERSISTENCE_MIGRATION_STRATEGY` | Ya | Strategi migrasi skema atau `N/A` |
| `AUTH_STRATEGY` | Ya | Strategi autentikasi dan manajemen sesi (Rekomendasi default: NextAuth.js / Auth.js; Alternatif: Supabase Auth, Clerk, atau Custom Manual Session) |
| `DOMAIN_NAME` | Ya | Domain bisnis proyek atau `General Application` |
| `CRITICAL_DATA_AREA` | Ya | Aset data kritis yang memerlukan kontrol privasi khusus atau `N/A` |

## 2. Perintah dan Operasional (Commands and Operations)

| Variabel | Wajib? | Kegunaan |
|---|---:|---|
| `ENV_SETUP_COMMAND` | Ya | Perintah penyiapan lingkungan kerja (*environment setup*) atau `N/A` |
| `RUN_OR_BUILD_COMMAND` | Ya | Perintah menjalankan atau mengompilasi proyek secara lokal atau `N/A` |
| `TEST_COMMAND` | Ya | Perintah menjalankan pengujian (*test suite*) atau `N/A` |
| `INTEGRATION_TEST_COMMAND` | Tidak | Perintah pengujian integrasi tambahan jika ada |
| `BUILD_COMMAND` | Tidak | Perintah spesifik build/packaging jika terpisah dari run command |
| `DEPLOY_COMMAND` | Ya | Perintah atau prosedur rilis (*deployment*) atau `N/A` |
| `HEALTHCHECK_PATH` | Ya | Jalur URL/perintah uji kesehatan (*health check*) atau `N/A` |

## 3. Persyaratan dan Alur (Requirement and Flow)

| Variabel | Wajib? | Kegunaan |
|---|---:|---|
| `BUSINESS_GOAL_1` | Ya | Tujuan bisnis utama |
| `TECHNICAL_GOAL_1` | Ya | Tujuan teknis utama |
| `NON_GOAL_1` | Tidak | Batasan yang secara eksplisit tidak dikerjakan |
| `CORE_FEATURE_1` | Ya | Fitur inti pertama |
| `OUT_OF_SCOPE_FEATURE_1` | Tidak | Fitur yang berada di luar cakupan |
| `FR_TITLE` | Ya | Judul persyaratan fungsional pertama |
| `FR_DESCRIPTION` | Ya | Deskripsi detail persyaratan fungsional pertama |
| `PRIMARY_FLOW_TITLE` | Tidak | Judul alur operasional utama |
| `PRIMARY_ACTOR` | Tidak | Aktor utama sistem |
| `STATE_1` | Tidak | Status awal sistem |
| `TRANSITION_1` | Tidak | Aksi pemicu transisi status |

## 4. Arsitektur dan Penyebaran (Architecture and Deployment)

Variabel arsitektur dan penyebaran berikut wajib diisi `N/A` jika kapabilitasnya tidak digunakan, dan dilarang dibiarkan kosong:

`ENTRYPOINTS`, `CORE_COMPONENTS`, `PERSISTENCE_COMPONENTS`, `ASYNC_COMPONENTS`, `EXTERNAL_DEPENDENCIES`, `PUBLIC_INTERFACES`, `INTERNAL_INTERFACES`, `CONFIGURATION_BOUNDARY`, `RESOURCE_LIMITS`, `SCALING_MODEL`, `DEPLOYMENT_ENVIRONMENTS`, `RUNTIME_CONFIGURATION`, `SECRET_CONFIGURATION`, `DEPENDENCY_ENDPOINTS`, `OBSERVABILITY_CONFIGURATION`, `DEPLOY_STEP_1`, `DEPLOY_STEP_2`, `ROLLBACK_TRIGGER`, `ROLLBACK_PROCEDURE`, `DATA_COMPATIBILITY_RULE`, `DOWNTIME_EXPECTATION`.

## 5. Nilai-Nilai Instansiasi (Instantiation Values)

Pada hasil instansiasi proyek, isi kolom Nilai untuk setiap variabel wajib berikut. Jangan menghapus barisnya. Nilai harus konkret atau `N/A` yang didukung oleh Decision ID dan alasan tertulis di Decision Register.

| Variabel | Nilai (Value) |
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

## 6. Aturan Registry (Rules)

- Nama variabel hanya boleh menggunakan huruf kapital (A-Z), angka (0-9), dan garis bawah (*underscore* `_`).
- Nilai variabel dilarang memuat kunci rahasia (*secret*), kredensial, token akses, atau data pribadi sensitif.
- Placeholder yang tidak relevan diisi `N/A` pada keluaran instansiasi akhir proyek.
- Script validator akan menolak placeholder yang tidak terdaftar di registry ini.

## 7. Kontrak Instansiasi (Instantiation Contract)

Setiap keputusan proyek yang memengaruhi dokumentasi atau implementasi wajib dicatat di [Decision Register](decision-register.md). Gunakan status keputusan berikut secara persis:

| Status | Arti | Dampak pada Kesiapan (*Readiness*) |
|---|---|---|
| `Confirmed` | Jawaban telah dipilih dan dikonfirmasi oleh pengguna atau pemilik proyek yang berwenang. | Memenuhi kesiapan jika alasan dan referensinya tertulis konkret. |
| `Not Applicable` | Kapabilitas atau keputusan benar-benar tidak berlaku untuk proyek. | Memenuhi kesiapan hanya jika alasan ketidakberlakuannya tertulis sah. |
| `Open` | Pertanyaan telah diketahui, namun jawabannya belum diputuskan. | Memblokir kesiapan (*blocking*). |
| `Unknown` | Informasi belum tersedia atau belum dapat diverifikasi. | Memblokir kesiapan (*blocking*). |
| `Assumption` | Jawaban sementara yang belum dikonfirmasi pengguna. | Memblokir kesiapan; wajib dikonfirmasi pengguna sebelum implementasi. |

Hanya status `Confirmed` dan `Not Applicable` yang disertai alasan tertulis yang dapat meloloskan gerbang kesiapan. Sumber template mempertahankan placeholder yang terdaftar di bawah ini; hasil instansiasi proyek wajib mengganti seluruh placeholder dengan nilai riil.

## 8. Indeks Placeholder Lengkap (Complete Placeholder Index)

Nama-nama berikut adalah seluruh placeholder resmi yang disediakan oleh template AI Harness:

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
