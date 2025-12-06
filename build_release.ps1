# Release Build Script for Tournament Manager App
# This script helps you build release APK/AAB for Indus App Store

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Tournament Manager - Release Builder  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Please run this script from the project root directory!" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Current Version:" -ForegroundColor Yellow
$version = Select-String -Path "pubspec.yaml" -Pattern "version:" | Select-Object -First 1
Write-Host $version -ForegroundColor White
Write-Host ""

# Check for keystore
$keystoreExists = Test-Path "android/turnament-release-key.jks"
$keyPropertiesExists = Test-Path "android/key.properties"

if (!$keystoreExists) {
    Write-Host "⚠️  Keystore not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Creating a new keystore..." -ForegroundColor Cyan
    Write-Host "You'll need to provide:" -ForegroundColor White
    Write-Host "  - First and Last Name" -ForegroundColor Gray
    Write-Host "  - Organization Unit (e.g., Development)" -ForegroundColor Gray
    Write-Host "  - Organization Name (e.g., Your Company)" -ForegroundColor Gray
    Write-Host "  - City" -ForegroundColor Gray
    Write-Host "  - State" -ForegroundColor Gray
    Write-Host "  - Country Code (e.g., IN)" -ForegroundColor Gray
    Write-Host "  - Keystore Password (SAVE THIS!)" -ForegroundColor Red
    Write-Host "  - Key Password (SAVE THIS!)" -ForegroundColor Red
    Write-Host ""
    
    $confirm = Read-Host "Do you want to create the keystore now? (y/n)"
    if ($confirm -eq "y") {
        keytool -genkey -v -keystore android/turnament-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias turnament
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Keystore created successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "⚠️  IMPORTANT: Save your passwords securely!" -ForegroundColor Red
            Write-Host ""
        } else {
            Write-Host "❌ Failed to create keystore!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Skipping keystore creation. You'll need to create it manually." -ForegroundColor Yellow
        exit 0
    }
}

if (!$keyPropertiesExists) {
    Write-Host "⚠️  key.properties file not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Creating key.properties file..." -ForegroundColor Cyan
    
    $storePassword = Read-Host "Enter Keystore Password" -AsSecureString
    $keyPassword = Read-Host "Enter Key Password" -AsSecureString
    
    # Convert SecureString to plain text
    $storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))
    $keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))
    
    $keyPropertiesContent = @"
storePassword=$storePasswordPlain
keyPassword=$keyPasswordPlain
keyAlias=turnament
storeFile=turnament-release-key.jks
"@
    
    $keyPropertiesContent | Out-File -FilePath "android/key.properties" -Encoding ASCII
    Write-Host "✅ key.properties created!" -ForegroundColor Green
    Write-Host ""
}

# Clean build
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter clean failed!" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Getting dependencies..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter pub get failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Choose Build Type  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Build APK (for direct distribution)" -ForegroundColor White
Write-Host "2. Build AAB (recommended for app stores)" -ForegroundColor Green
Write-Host "3. Build Both" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Enter your choice (1/2/3)"

$buildApk = $false
$buildAab = $false

switch ($choice) {
    "1" { $buildApk = $true }
    "2" { $buildAab = $true }
    "3" { 
        $buildApk = $true
        $buildAab = $true
    }
    default {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

if ($buildApk) {
    Write-Host "🔨 Building APK..." -ForegroundColor Cyan
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ APK built successfully!" -ForegroundColor Green
        $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
        if (Test-Path $apkPath) {
            $apkSize = (Get-Item $apkPath).Length / 1MB
            Write-Host "📦 APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor White
            Write-Host "📍 Location: $apkPath" -ForegroundColor Gray
        }
        Write-Host ""
    } else {
        Write-Host "❌ APK build failed!" -ForegroundColor Red
        exit 1
    }
}

if ($buildAab) {
    Write-Host "🔨 Building App Bundle (AAB)..." -ForegroundColor Cyan
    flutter build appbundle --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ AAB built successfully!" -ForegroundColor Green
        $aabPath = "build\app\outputs\bundle\release\app-release.aab"
        if (Test-Path $aabPath) {
            $aabSize = (Get-Item $aabPath).Length / 1MB
            Write-Host "📦 AAB Size: $([math]::Round($aabSize, 2)) MB" -ForegroundColor White
            Write-Host "📍 Location: $aabPath" -ForegroundColor Gray
        }
        Write-Host ""
    } else {
        Write-Host "❌ AAB build failed!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ Build Complete!  " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test the APK on a real device" -ForegroundColor White
Write-Host "2. Prepare screenshots (see RELEASE_CHECKLIST.md)" -ForegroundColor White
Write-Host "3. Upload AAB to Indus App Store Developer Console" -ForegroundColor White
Write-Host "4. Fill in app listing details" -ForegroundColor White
Write-Host "5. Submit for review" -ForegroundColor White
Write-Host ""
Write-Host "📚 Resources:" -ForegroundColor Yellow
Write-Host "- Release Checklist: RELEASE_CHECKLIST.md" -ForegroundColor Gray
Write-Host "- App Store Listing: app_store_listing.md" -ForegroundColor Gray
Write-Host "- Privacy Policy: privacy_policy.html" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 Good luck with your release!" -ForegroundColor Cyan
Write-Host ""

# Ask if user wants to open build folder
$openFolder = Read-Host "Open build output folder? (y/n)"
if ($openFolder -eq "y") {
    if ($buildAab) {
        Start-Process "build\app\outputs\bundle\release"
    } elseif ($buildApk) {
        Start-Process "build\app\outputs\flutter-apk"
    }
}
