# Mobile Platform & Permissions Specification — {{PROJECT_NAME}}

> Canonical specification for supported mobile operating systems, runtime frameworks, hardware permission justifications, and device capabilities.

---

## 1. Platform Matrix & Baseline Requirements

- **Application Name:** `{{PROJECT_NAME}}`
- **Application Bundle ID / Package Name:** `{{APP_BUNDLE_ID}}`
- **Primary Framework:** `{{MOBILE_FRAMEWORK}}`
- **Target Operating Systems:** `{{TARGET_OS}}`
- **Minimum OS Support:** `{{MIN_OS_VERSION}}`
- **Target Architectures:** `arm64-v8a`, `armeabi-v7a`, `x86_64` (iOS 64-bit arm64)
- **Supported Form Factors:** Smartphones (Portrait primary, Landscape adaptive) and Tablets.

---

## 2. Hardware & System Permissions

Every permission requested must serve a declared user-facing feature. Undisclosed background access is prohibited.

| Permission Identifier | Platform | User Justification String | Requirement Level | Handled Gracefully If Denied |
| :--- | :--- | :--- | :--- | :--- |
| `CAMERA` | iOS / Android | "Scan QR codes and capture profile verification photos." | Optional / On-Demand | Yes (Fallback to manual input) |
| `READ_MEDIA_IMAGES` / `Photos` | iOS / Android | "Select images from gallery to upload profile avatars and attachments." | Optional / On-Demand | Yes (Cancel attachment) |
| `POST_NOTIFICATIONS` | iOS / Android | "Receive real-time transactional updates and system alerts." | Optional / Post-Onboarding | Yes (In-app notification inbox) |
| `ACCESS_FINE_LOCATION` | iOS / Android | "Pinpoint immediate pickup or delivery locations." | On-Demand | Yes (Manual address search) |
| `USE_BIOMETRIC` / `FaceID` | iOS / Android | "Authenticate securely using fingerprint or facial recognition." | Optional | Yes (Fallback to master PIN/Password) |

---

## 3. Platform Configuration Manifests

### 3.1. iOS (`Info.plist`)
```xml
<!-- Permission disclosure strings required by Apple Review -->
<key>NSCameraUsageDescription</key>
<string>Allow {{PROJECT_NAME}} to access your camera to scan QR codes and capture verification documents.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Allow {{PROJECT_NAME}} to access your photos to attach receipts and profile pictures.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Allow {{PROJECT_NAME}} to use your location while using the app to show nearby services.</string>
<key>NSFaceIDUsageDescription</key>
<string>Authenticate securely using Face ID.</string>
```

### 3.2. Android (`AndroidManifest.xml`)
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="{{APP_BUNDLE_ID}}">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="{{PROJECT_NAME}}"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:allowBackup="false"
        android:supportsRtl="true">
        <!-- Activities and service configurations -->
    </application>
</manifest>
```

---

## 4. Runtime Permission Workflow

1. **Contextual Explanation:** Display an in-app explanatory modal before triggering system permission dialogs.
2. **Never Block App Launch:** Never request sensitive permissions (camera/location) during splash or onboarding screens unless fundamentally required for the core value proposition.
3. **Denial Recovery:** If the user permanently denies a permission ("Don't ask again"), provide an actionable button that deep-links directly to the system application settings page.
