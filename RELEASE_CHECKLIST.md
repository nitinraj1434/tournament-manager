# 📋 Indus App Store Release Checklist

## Pre-Submission Checklist

### ✅ Code & Build
- [x] Package name typo fixed (com.example.turnament)
- [ ] Create release keystore
- [ ] Configure key.properties file
- [ ] Build release APK successfully
- [ ] Build release AAB successfully  
- [ ] Test APK on real device
- [ ] Verify all features work in release mode
- [ ] Check app size (should be < 150MB)

### ✅ App Assets
- [x] Feature graphic (1024x500) - Generated ✓
- [x] App icon (512x512) - Generated ✓
- [ ] Minimum 2 screenshots (1080x1920 or 1440x2560)
- [ ] Optional: Tablet screenshots
- [ ] Optional: Promo video

### ✅ Legal & Compliance
- [x] Privacy Policy created ✓
- [ ] Privacy Policy uploaded to web hosting
- [ ] Terms of Service document
- [ ] Content rating questionnaire answers prepared
- [ ] Age restriction justification ready

### ✅ App Listing Content
- [x] App name (English & Hindi) ✓
- [x] Short description (80 chars) ✓
- [x] Full description (4000 chars) ✓
- [x] Keywords/tags prepared ✓
- [x] Category selected ✓
- [x] What's New text ✓

### ✅ Developer Account
- [ ] Indus App Store developer account created
- [ ] Email verified
- [ ] KYC verification completed (Aadhaar/PAN)
- [ ] Registration fee paid (if applicable)
- [ ] Payment details added (for revenue)

### ✅ Firebase Configuration
- [x] Firebase project configured ✓
- [x] google-services.json in place ✓
- [ ] Firebase authentication tested
- [ ] Firestore rules configured properly
- [ ] Cloud messaging working
- [ ] Firebase Analytics enabled

### ✅ Testing
- [ ] App installs successfully
- [ ] Google Sign-In works
- [ ] Tournament creation works
- [ ] Wallet deposit/withdrawal works
- [ ] Notifications received
- [ ] All screens render correctly
- [ ] No crashes or errors
- [ ] Performance is smooth

---

## Build Commands

### 1. Clean Build
```bash
flutter clean
flutter pub get
```

### 2. Create Keystore (First time only)
```bash
keytool -genkey -v -keystore ./android/turnament-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias turnament
```

**Save this information securely:**
- Keystore password: _______________
- Key password: _______________
- Key alias: turnament
- Keystore file: android/turnament-release-key.jks

### 3. Configure key.properties
Create file: `android/key.properties`
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=turnament
storeFile=turnament-release-key.jks
```

### 4. Build Release APK
```bash
flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### 5. Build Release AAB (Recommended)
```bash
flutter build appbundle --release
```
**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## Screenshot Checklist

### Required Screenshots (Minimum 2, Maximum 8)

**Recommended screens to capture:**
1. ✅ Login Screen (Google Sign-In)
2. ✅ Dashboard/Home Screen
3. ✅ Tournament List
4. ✅ Tournament Details
5. ✅ Wallet Screen
6. ✅ My Tournaments
7. ⚪ Profile Screen
8. ⚪ Notifications Screen

**Screenshot Specifications:**
- Resolution: 1080x1920 or 1440x2560
- Format: PNG or JPG
- No device frames
- Clean UI (no debug elements)
- Good quality (not blurry)

**How to capture:**
1. Run app on device/emulator
2. Navigate to each screen
3. Take screenshot (Power + Volume Down)
4. Transfer to computer
5. Crop if needed (remove status bar if desired)

---

## Submission Steps

### Step 1: Login to Indus App Store Developer Console
🌐 https://indusappstore.com/developer

### Step 2: Create New App
- Click "Create New App" or "Add Application"
- Fill in basic details

### Step 3: Upload APK/AAB
- Upload the app-release.aab file
- Wait for processing
- Check for any warnings

### Step 4: Store Listing
Copy content from `app_store_listing.md`:

**App Details:**
- Title: Tournament Manager - Gaming Tournaments
- Short Description: [Copy from listing file]
- Full Description: [Copy from listing file]
- Category: Games / Sports
- Content Rating: Teen (13+)

**Graphics:**
- App Icon: Upload app_icon_512.png
- Feature Graphic: Upload feature_graphic.png
- Screenshots: Upload all prepared screenshots

**Contact Information:**
- Email: support@tournamentmanager.com
- Website: [Your website]
- Privacy Policy URL: [Your hosted privacy policy URL]

### Step 5: Content Rating
Answer questionnaire honestly:
- Violence: None/Minimal
- Language: None
- Sexual Content: None
- Gambling: No (skill-based gaming)
- User Interaction: Yes (usernames, profiles)
- In-App Purchases: Yes (wallet deposits)
- Location Sharing: No
- Personal Info Sharing: Yes (Google Sign-In)

### Step 6: Pricing & Distribution
- Free: Yes
- In-App Purchases: Yes (wallet features)
- Countries: India (primary), All countries (optional)
- Android version: 5.0+ (API 21+)

### Step 7: Review & Submit
- Review all information
- Check for errors/warnings
- Click "Submit for Review"
- Save draft if not ready

---

## Post-Submission

### Approval Timeline
- Initial Review: 2-7 days
- Feedback Response: 24-48 hours
- Final Approval: 1-3 days

### What to Monitor
- [ ] Check developer console daily
- [ ] Respond to review team queries promptly
- [ ] Fix any issues reported
- [ ] Update build if needed

### After Approval
- [ ] App goes live on Indus App Store
- [ ] Test installation from store
- [ ] Monitor user reviews
- [ ] Respond to user feedback
- [ ] Track analytics and downloads
- [ ] Plan updates and improvements

---

## Common Issues & Solutions

### Issue: Build Failed
**Solution:** 
```bash
flutter clean
flutter pub get
flutter build appbundle --release --verbose
```

### Issue: Signing Error
**Solution:** 
- Check key.properties file exists
- Verify passwords are correct
- Ensure keystore file path is correct

### Issue: App Rejected
**Reasons:**
- Privacy Policy missing
- Screenshots don't match app
- Description misleading
- Content rating incorrect

**Solution:** Fix issues and resubmit

---

## Version Update Checklist

For future updates:

1. Update version in pubspec.yaml:
   ```yaml
   version: 1.0.2+3  # Major.Minor.Patch+BuildNumber
   ```

2. Update "What's New" section

3. Build new release:
   ```bash
   flutter build appbundle --release
   ```

4. Upload to developer console

5. Submit for review

---

## Important Notes

⚠️ **DO NOT:**
- Commit keystore or key.properties to git
- Share keystore passwords publicly
- Use debug builds for submission
- Use lorem ipsum or fake content
- Violate content policies

✅ **DO:**
- Keep keystore backup in safe place
- Test thoroughly before submission
- Respond quickly to review feedback
- Monitor app performance after launch
- Update app regularly
- Engage with user reviews

---

## Contact & Support

**Indus App Store Support:**
- Developer Portal: https://indusappstore.com/developer
- Support Email: developer-support@indusappstore.com
- FAQ: https://indusappstore.com/developer-faq

**Your App Support:**
- Email: support@tournamentmanager.com
- In-App: Settings → Contact Support

---

## Resources

📚 **Documentation:**
- Indus App Store Guidelines: [Link]
- Flutter Deployment Guide: https://docs.flutter.dev/deployment/android
- Firebase Console: https://console.firebase.google.com

🛠️ **Tools:**
- Android Studio: Device screenshots
- Figma/Canva: Graphics editing
- APK Analyzer: Check app size

---

## Success Metrics

After Launch, Track:
- Downloads count
- User reviews & ratings
- Crash reports
- User retention
- Active tournaments
- Wallet transactions
- Revenue metrics

---

## Timeline Estimate

**Day 1-2:** Preparation
- Create keystore
- Build APK/AAB
- Prepare screenshots
- Upload privacy policy

**Day 3:** Submission
- Fill app listing
- Upload assets
- Submit for review

**Day 4-10:** Review Period
- Wait for feedback
- Fix any issues

**Day 11+:** Live!
- Monitor performance
- Engage with users
- Plan updates

---

**Last Updated:** December 3, 2025
**Version:** 1.0.1+2
**Status:** Ready for Submission

🎉 **Good Luck with Your Launch!** 🎉
