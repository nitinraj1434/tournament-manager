# Turnament - Esports Tournament App

A complete, production-ready Flutter application for managing and participating in Esports tournaments. This app features a dual-role system (User & Admin) powered by Firebase Backend (Firestore & Auth).

## 🚀 Features

### 👤 User Features
*   **Authentication**: Secure Login & Signup using Email/Password and Google Sign-In.
*   **Home Dashboard**: Browse upcoming and live tournaments with filters.
*   **Tournament Details**: View complete details including:
    *   Game Type, Date & Time.
    *   Entry Fee & Prize Pool.
    *   Rules & Regulations.
    *   Participant List.
*   **Join Tournaments**: Seamless joining process with wallet balance check.
*   **My Tournaments**: Track joined tournaments.
    *   View status (Confirmed, Completed).
    *   **Room Details**: Access Room ID and Password (visible only to participants).
    *   **Results**: View winners and winnings.
*   **Wallet System**:
    *   **Real-time Balance**: View current wallet balance.
    *   **Deposit**: Scan QR code and submit UTR/Transaction ID for manual verification.
    *   **Withdraw**: Request winnings withdrawal to bank/UPI.
    *   **Transaction History**: Detailed log of all credits (Deposits, Winnings) and debits (Entry Fees, Withdrawals).
*   **Profile Management**:
    *   Edit Profile (Name, Bio, etc.).
    *   **Game ID Management**: Update In-Game Name and ID for tournament verification.
    *   **Support**: Direct WhatsApp support integration.
    *   **About Us**: Information about the platform.

### 🛡️ Admin Features
*   **Admin Dashboard**: Quick access to all management modules.
*   **Tournament Management**:
    *   **Create/Edit**: Set up new tournaments with images, fees, prizes, and schedules.
    *   **Manage**: Publish, unpublish, or delete tournaments.
    *   **Participants**: View list of joined players.
*   **Match Operations**:
    *   **Room Details**: Update Room ID and Password for players to see.
    *   **Result Entry**: Select winner from participants.
    *   **Prize Distribution**: **Automated** prize credit to the winner's wallet upon match completion.
*   **Financial Management**:
    *   **Wallet Requests**: View pending deposit requests with UTR. Approve (credits wallet) or Reject.
    *   **Withdrawal Requests**: View pending withdrawal requests. Approve or Reject (refunds wallet).
*   **User Management**: View and manage registered users.

## 🛠️ Tech Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase
    *   **Authentication**: User management.
    *   **Cloud Firestore**: Real-time NoSQL database.
*   **State Management**: `Provider` & `StreamBuilder` for real-time updates.
*   **UI/UX**: Custom design with Glassmorphism elements, gradients, and animations.

## 📂 Project Structure

```
lib/
├── constants/         # App colors, styles, and static strings
├── models/            # Data models (User, Tournament, Transaction, etc.)
├── screens/
│   ├── admin/         # Admin-specific screens (Dashboard, Management)
│   ├── ...            # User screens (Home, Profile, Wallet, etc.)
├── services/          # Backend logic (AuthService, DatabaseService)
├── widgets/           # Reusable UI components (Buttons, Cards, TextFields)
└── main.dart          # App entry point
```

## ⚙️ Setup & Installation

1.  **Prerequisites**:
    *   Flutter SDK installed.
    *   Android Studio / VS Code.

2.  **Firebase Configuration**:
    *   This project uses Firebase. Ensure `google-services.json` is present in `android/app/`.
    *   Enable **Authentication** (Email/Password, Google).
    *   Enable **Cloud Firestore**.

3.  **Run the App**:
    ```bash
    # Get dependencies
    flutter pub get

    # Run on device/emulator
    flutter run
    ```

4.  **First Run**:
    *   The app automatically initializes default data (Demo User, Sample Tournaments, Config) if the database is empty.

## 📱 Screenshots

*(Add screenshots of Home, Tournament Detail, Wallet, and Admin Dashboard here)*

---

## 🚀 Release & Distribution

### Indus App Store Release

This app is configured for release on the **Indus App Store** (and other Android app stores).

#### 📚 Release Documentation

Complete release guides are available:

- **[RELEASE_GUIDE_HINDI.md](RELEASE_GUIDE_HINDI.md)** - Quick guide in Hindi (शुरू करने के लिए यहां पढ़ें!)
- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Comprehensive English checklist
- **[app_store_listing.md](app_store_listing.md)** - App store listing content (English + Hindi)
- **[privacy_policy.html](privacy_policy.html)** - Privacy policy webpage
- **[.agent/workflows/release-indus-appstore.md](.agent/workflows/release-indus-appstore.md)** - Detailed workflow

#### ⚡ Quick Start

**Automated Build (Easiest):**
```powershell
# Run the automated build script
.\build_release.ps1
```

**Manual Build:**
```powershell
# Create keystore (first time only)
keytool -genkey -v -keystore android/turnament-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias turnament

# Build release AAB (recommended for app stores)
flutter build appbundle --release

# Build release APK (for direct distribution)
flutter build apk --release
```

#### 📋 Release Steps Summary

1. ✅ Create keystore and configure signing
2. ✅ Build release APK/AAB
3. ✅ Prepare screenshots and assets
4. ✅ Create Indus App Store developer account
5. ✅ Upload app and fill listing details
6. ✅ Submit for review
7. ✅ Wait for approval (2-7 days)
8. 🎉 Go live!

See **[RELEASE_GUIDE_HINDI.md](RELEASE_GUIDE_HINDI.md)** for complete step-by-step instructions.

#### 🎨 App Store Assets

Pre-generated assets are included:
- ✅ Feature Graphic (1024x500)
- ✅ App Icon (512x512)
- ✅ Privacy Policy (ready to upload)

#### 🔐 Security Notes

**Never commit these files:**
- `android/key.properties`
- `android/*.jks` or `*.keystore`
- Any passwords or credentials

These are automatically excluded in `.gitignore`.

---

## 📄 License

This project is proprietary software. All rights reserved.
