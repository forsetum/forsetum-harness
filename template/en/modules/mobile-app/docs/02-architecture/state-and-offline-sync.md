# State Management & Offline Synchronization — {{PROJECT_NAME}}

> Architecture specification for client-side state, local persistence, offline caching, and remote data synchronization.

---

## 1. State Architecture & Boundaries

The client architecture enforces unidirectional data flow and strict separation between presentation, business logic, and data storage:

- **Presentation Layer (UI/Widgets):** Consumes reactive state from ViewModels or Controllers. Contains zero network or raw database code.
- **State Management Pattern:** Predictable state container matching `{{MOBILE_FRAMEWORK}}` conventions (e.g. Riverpod/Bloc, Zustand/Redux, MVVM/Combine).
- **Domain Layer:** Pure business entities and use cases with no UI framework dependencies.
- **Repository Layer:** Abstract data source selector switching between local cache and remote network endpoints.

---

## 2. Local Persistence Strategy

| Data Type | Storage Mechanism | Encryption | Eviction Policy |
| :--- | :--- | :--- | :--- |
| **Auth Tokens & Private Keys** | Keychain (iOS) / EncryptedSharedPreferences (Android) | Hardware AES-256 | Purged on logout or app reinstall |
| **User Preferences & Flags** | Key-Value Store (UserDefaults / DataStore / MMKV) | None / Optional | Persistent across sessions |
| **Structured Relational Data** | Local Database (SQLite / Room / Drift / WatermelonDB) | SQLCipher (Optional) | LRU cache or explicit sync |
| **Media & Cached Assets** | App Sandbox Temporary Directory | OS-level | Automatic OS cleanup on storage pressure |

---

## 3. Offline-First & Network Synchronization

### 3.1. Read Workflow (Cache First)
1. The UI requests data from the repository.
2. The repository immediately returns cached local records if present (fast render).
3. In the background, a network fetch queries the remote API.
4. On network success, local records are updated and UI reactive state emits fresh data.
5. On network failure, UI shows cached data with an unobtrusive "offline banner".

### 3.2. Write Workflow (Optimistic Mutation & Sync Queue)
1. User triggers a mutation (e.g., submitting a form or marking an item complete).
2. UI updates optimistically, storing the mutation payload in a durable `outbox_queue` table with a unique UUID.
3. Network listener triggers background processing when connectivity is restored:
   - Items in `outbox_queue` are dispatched in FIFO order.
   - Successful items are deleted from `outbox_queue`.
   - Temporary network failures retry with exponential backoff (max 5 attempts).
   - Unrecoverable 4xx client errors move to a dead-letter quarantine with user notification.

---

## 4. Deep Linking & Routing Schema

The application handles standard HTTPS Universal Links (iOS) / Android App Links, as well as custom scheme fallback:

- **Universal / App Link Domain:** `https://app.{{PROJECT_NAME}}.com`
- **Custom URI Scheme:** `{{PROJECT_NAME}}://`
- **Supported Route Formats:**
  - `https://app.{{PROJECT_NAME}}.com/auth/callback` (OAuth & magic link handler)
  - `https://app.{{PROJECT_NAME}}.com/resource/:id` (Direct resource viewer)
  - `https://app.{{PROJECT_NAME}}.com/settings/billing` (Account navigation)
