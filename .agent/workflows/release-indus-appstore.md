---
description: Release app on Indus App Store
---

# Indus App Store Release Workflow

## Pre-Release Checklist

### 1. Verify App Information
- [ ] App Name: `turnament`
- [ ] Package Name: `com.ecxample.turnament` (Fix typo to `com.example.turnament`)
- [ ] Current Version: `1.0.1+2`
- [ ] Min SDK: 21 (Android 5.0)

### 2. Create Keystore (If Not Already Created)

```powershell
keytool -genkey -v -keystore c:\Users\Nitin\OneDrive\Desktop\turnament\android\turnament-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias turnament
```

**Note:** Save the password securely!

### 3. Create key.properties File

Create file at: `c:\Users\Nitin\OneDrive\Desktop\turnament\android\key.properties`

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=turnament
storeFile=turnament-release-key.jks
```

### 4. Build Release APK

// turbo
```powershell
flutter build apk --release
```

### 5. Build Release App Bundle (AAB) - Recommended

// turbo
```powershell
flutter build appbundle --release
```

**Output Location:**
- APK: `build\app\outputs\flutter-apk\app-release.apk`
- AAB: `build\app\outputs\bundle\release\app-release.aab`

## Indus App Store Submission Process

### Step 1: Create Indus AppStore Developer Account
1. Visit: https://indusappstore.com/developer
2. Sign up with your email/phone
3. Complete KYC verification (Aadhaar/PAN)
4. Pay registration fee (if applicable)

### Step 2: Prepare App Assets

#### Required Screenshots (Minimum 2, Maximum 8):
- **Phone Screenshots**: 1080x1920 or 1440x2560
- **Tablet Screenshots** (optional): 2048x2732
- Format: PNG or JPG
- No device frames, only app interface

#### App Icon:
- **Size**: 512x512 pixels
- **Format**: PNG (with transparency)
- Already configured: `assets/images/app_logo.jpg`

#### Feature Graphic:
- **Size**: 1024x500 pixels
- **Format**: PNG or JPG

### Step 3: App Listing Information

Prepare the following details:

1. **App Title**: Tournament Manager (या आपका पसंदीदा नाम)
2. **Short Description** (80 characters):
   ```
   Organize and manage gaming tournaments with ease
   ```

3. **Full Description** (4000 characters max):
   ```
   Tournament Manager is a comprehensive app for organizing, managing, and participating in gaming tournaments. 

   Key Features:
   • 🎮 Create and manage tournaments
   • 💰 Wallet system for prize management
   • 🔔 Real-time notifications
   • 📊 Live leaderboards
   • 🔐 Secure Google Sign-In
   • 💸 Multiple payment options (UPI/Bank Transfer)

   Perfect for gamers, organizers, and esports enthusiasts!
   ```

4. **Category**: Games or Sports
5. **Content Rating**: Suitable for all ages / Teen (depending on content)
6. **Privacy Policy URL**: (Required - create one)
7. **Contact Email**: Your support email
8. **Keywords/Tags**: tournament, gaming, esports, competition, prizes

### Step 4: Upload APK/AAB

1. Login to Indus App Store Developer Console
2. Click "Create New App"
3. Fill in app details
4. Upload your APK or AAB file
5. Upload screenshots and graphics
6. Set pricing (Free/Paid)
7. Add app description and metadata

### Step 5: Content Rating & Compliance

Answer questionnaire about:
- Violence
- Adult content
- User-generated content
- In-app purchases
- Data collection

### Step 6: Submit for Review

1. Review all information
2. Submit app for review
3. Wait for approval (typically 2-7 days)
4. Address any feedback from review team

## Post-Submission

### Monitor Status
- Check developer console regularly
- Respond to review team quickly
- Fix any issues reported

### After Approval
1. App will be live on Indus App Store
2. Monitor user reviews
3. Plan updates and improvements

## Update Release Process

For future updates:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.2+3  # Increment build number
   ```

2. Build new APK/AAB
// turbo
```powershell
flutter build appbundle --release
```

3. Upload to Indus App Store Developer Console
4. Update "What's New" section
5. Submit for review

## Important Notes

- **First-time approval**: May take longer
- **App size limit**: Typically 150MB for APK
- **Indian market focus**: Indus App Store targets Indian users
- **Regional languages**: Consider adding Hindi support
- **Payment integration**: Use Indian payment methods (UPI, Paytm, etc.)

## Troubleshooting

### Build Errors
If build fails, try:
```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

### Signing Issues
Verify `key.properties` file exists and has correct paths

### Firebase Configuration
Ensure `google-services.json` is present in `android/app/`

## Resources

- Indus App Store Developer Guide: https://indusappstore.com/developer-guide
- Flutter Release Documentation: https://docs.flutter.dev/deployment/android
- Android App Bundle: https://developer.android.com/guide/app-bundle
