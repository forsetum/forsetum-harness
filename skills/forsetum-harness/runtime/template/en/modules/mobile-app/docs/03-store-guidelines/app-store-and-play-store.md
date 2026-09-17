# App Store & Google Play Store Guidelines — {{PROJECT_NAME}}

> Compliance protocol, store submission policies, privacy declarations, and pre-release review rejection prevention checklist.

---

## 1. Apple App Store Compliance (App Review Guidelines)

1. **Account Deletion (Section 5.1.1(v)):** If the app supports account creation, users must be able to initiate account deletion and data scrubbing directly within the app without requiring an email or external website.
2. **App Tracking Transparency (ATT):** If any ad identifier (IDFA) or third-party analytics tracking across other apps is used, the ATT permission dialog must be presented before initialization.
3. **In-App Purchases (Section 3.1.1):** Digital goods, digital subscriptions, and premium feature unlocks must exclusively use StoreKit IAP. No external payment links are allowed for digital features.
4. **Privacy Nutrition Labels:** Complete accurate declarations in App Store Connect detailing collected data types (contact info, identifiers, usage data) linked to user identity.

---

## 2. Google Play Store Compliance (Developer Policy)

1. **Target API Level:** Android builds must target the latest mandated Android API level (currently API 34+ / Android 14+).
2. **Data Safety Form:** Must declare all data collected, shared, and encrypted in transit on Google Play Console before submission.
3. **Foreground Services:** Declaring `FOREGROUND_SERVICE` permissions requires a documented user-facing ongoing task (audio, location tracking, large file download) with notification controls.
4. **Photo & Video Permissions:** Use modern Android Photo Picker (`ActivityResultContracts.PickVisualMedia`) instead of broad `READ_EXTERNAL_STORAGE`.

---

## 3. Review Rejection Prevention Checklist

Run this checklist prior to submitting any binary to Apple Review or Google Play Store Review:

| Review Item | Verification Method | Status | Notes |
| :--- | :--- | :---: | :--- |
| **Demo / Reviewer Credentials** | Provide working test account with prepopulated mock data | [ ] | In App Store Connect Review Notes |
| **No Broken Links or Placeholders** | Verify terms of service, privacy policy, and support URLs | [ ] | Must return HTTP 200 |
| **No "Beta", "Test", or "Demo" Text** | Scan binary strings for test artifacts in release builds | [ ] | Binary check |
| **Account Deletion Path** | Verify Settings > Account > Delete Account flow works | [ ] | Required by Apple 5.1.1 |
| **Crash-Free Startup** | Launch build on physical low-end test device without internet | [ ] | Verify splash screen handles offline |
| **iPad / Tablet Layout** | Verify UI renders correctly without clipped buttons on tablets | [ ] | Test on iPad / Android Tablet emulator |
