# Platform Setup and Commands Guide

This comprehensive guide covers quick start commands, platform initialization, setup, commands, and compatibility for running the Flutter app on Android, iOS, Windows, and Web platforms.

---

## 🚀 Quick Start

### Quick Commands by Platform

#### Android
```bash
# Run on Android
flutter run -d android

# Build APK
flutter build apk --release
```

#### Windows
```bash
# Enable Windows support (first time only)
flutter config --enable-windows-desktop

# Run on Windows
flutter run -d windows

# Build for Windows
flutter build windows --release
```

#### Web
```bash
# Enable Web support (first time only)
flutter config --enable-web

# Run on Chrome
flutter run -d chrome

# Build for Web
flutter build web --release
```

#### iOS (macOS only)
```bash
# Run on iOS
flutter run -d ios

# Build for iOS
flutter build ios --release
```

---

## 📋 Prerequisites Checklist

### All Platforms
- ✅ Flutter SDK installed (`flutter --version`)
- ✅ Backend services running (`docker-compose up -d`)
- ✅ Dependencies installed (`flutter pub get`)

### Android
- ✅ Android Studio installed
- ✅ Android device connected OR emulator running
- ✅ Android SDK configured

### Windows
- ✅ Visual Studio 2019+ installed
- ✅ "Desktop development with C++" workload installed

### Web
- ✅ Chrome/Edge/Firefox browser installed

### iOS (macOS only)
- ✅ macOS required
- ✅ Xcode installed (free from Mac App Store)
- ✅ CocoaPods installed

---

## 🔧 Before Running

### 1. Check Backend Services
```bash
cd docker-compose
docker-compose ps
# All services should be "Up"
```

### 2. Verify Backend Health
```bash
curl http://localhost:3002/api/auth/health
# Should return success
```

### 3. Configure API URL (if needed)

**For Android Emulator:**
Edit `lib/core/config/app_config.dart`:
```dart
static const String baseApiUrl = 'http://10.0.2.2:8080';
```

**For Physical Android Device:**
Edit `lib/core/config/app_config.dart`:
```dart
static const String baseApiUrl = 'http://YOUR_COMPUTER_IP:8080';
```

**For Windows/Web:**
```dart
static const String baseApiUrl = 'http://localhost:8080';
```

---

## ✅ Platform Initialization Status

The Flutter app has been successfully initialized for Android and iOS platforms. Windows and Web support can be enabled as needed.

---

## 📱 Android Platform

### Prerequisites
- Android Studio installed
- Android SDK configured
- Android device connected OR emulator running

### Configuration Files

#### Files Created/Configured:
- ✅ `android/app/src/main/AndroidManifest.xml` - Configured with required permissions
- ✅ `android/app/build.gradle.kts` - Build configuration
- ✅ `android/build.gradle.kts` - Project-level build configuration
- ✅ `android/gradle.properties` - Gradle properties
- ✅ `android/settings.gradle.kts` - Gradle settings

#### Permissions Added:
- ✅ **Internet** - Required for API calls
- ✅ **Camera** - Required for QR code scanning
- ✅ **Network State** - Required for connectivity checks
- ✅ **Cleartext Traffic** - Enabled for localhost development

#### App Configuration:
- **App Name**: Library Booking
- **Package Name**: `com.example.library_booking_app`
- **Min SDK**: API 21 (Android 5.0 Lollipop)
- **Target SDK**: Latest Android version
- **Kotlin**: Configured for Kotlin support
- **Gradle**: Uses Kotlin DSL (`.kts` files)

### Step-by-Step Commands

#### 1. Check Android Setup
```bash
flutter doctor
```
Ensure Android toolchain shows no issues.

#### 2. List Available Devices
```bash
flutter devices
```
You should see your Android device or emulator listed, for example:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
```

#### 3. Run on Android
```bash
# Run on any available Android device
flutter run -d android

# Run on specific device (use device ID from flutter devices)
flutter run -d emulator-5554

# Run in release mode
flutter run -d android --release

# Run with hot reload enabled (default)
flutter run -d android --hot
```

#### 4. Build for Android

**Debug APK:**
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Split APKs (by ABI):**
```bash
flutter build apk --split-per-abi
# Outputs separate APKs for arm64-v8a, armeabi-v7a, x86_64
```

**App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### 5. Install APK on Device
```bash
# After building, install on connected device
flutter install

# Or manually install
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Android-Specific Notes
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: Latest (configured in `android/app/build.gradle.kts`)
- **Permissions**: Camera, Internet, Network State (configured in `AndroidManifest.xml`)
- **Localhost Access**: 
  - **Android Emulator**: Use `10.0.2.2` instead of `localhost` in API config
  - **Physical Android Device**: Use your computer's IP address (e.g., `192.168.1.100`)
  - Update `lib/core/config/app_config.dart`:
    ```dart
    // For Android emulator
    static const String baseApiUrl = 'http://10.0.2.2:8080';
    
    // For physical device (replace with your IP)
    static const String baseApiUrl = 'http://192.168.1.100:8080';
    ```

### Next Steps for Android:
1. **Update Android SDK** (if needed):
   ```bash
   # Flutter requires Android SDK 36
   # Update via Android Studio SDK Manager or command line
   ```

2. **Test on Android Device/Emulator**:
   ```bash
   flutter run -d android
   ```

---

## 🍎 iOS Platform

### Prerequisites
- macOS required
- Xcode installed (free from Mac App Store)
- CocoaPods installed

### Configuration Files

#### Files Created/Configured:
- ✅ `ios/Runner/Info.plist` - Configured with required permissions
- ✅ `ios/Runner/AppDelegate.swift` - App delegate
- ✅ `ios/Runner.xcodeproj` - Xcode project
- ✅ `ios/Runner.xcworkspace` - Xcode workspace
- ✅ `ios/Podfile` - CocoaPods dependencies

#### Permissions Added:
- ✅ **Camera Usage Description** - "This app needs access to camera to scan QR codes for booking check-in."
- ✅ **Photo Library Usage Description** - "This app needs access to photo library to save QR codes."
- ✅ **Location Usage Description** - "This app may use location to show nearby library resources."
- ✅ **App Transport Security** - Configured to allow localhost connections

#### App Configuration:
- **App Name**: Library Booking
- **Bundle Identifier**: Uses default (can be customized in Xcode)
- **Deployment Target**: iOS 12.0+ (Flutter default)
- **Swift**: Uses Swift for native code
- **CocoaPods**: Required for iOS dependencies

### Step-by-Step Commands

#### 1. Open in Xcode (macOS required)
```bash
open ios/Runner.xcworkspace
```

#### 2. Configure Signing
- Open Xcode project
- Select Runner target
- Go to "Signing & Capabilities"
- Select your development team
- Xcode will automatically manage provisioning profiles

#### 3. Install CocoaPods Dependencies
```bash
cd ios
pod install
cd ..
```

#### 4. Verify iOS Setup
```bash
flutter doctor
```
Ensure iOS toolchain shows no issues.

#### 5. List Available Devices
```bash
flutter devices
```

#### 6. Run on iOS
```bash
# Run on iOS Simulator/Device
flutter run -d ios

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run -d ios --release
```

#### 7. Build for iOS
```bash
flutter build ios --release
# Then open Xcode to archive and upload to App Store
```

---

## 🪟 Windows Desktop Platform

### Prerequisites
- Windows 10/11
- Visual Studio 2019 or later (with C++ desktop development workload)
- Flutter SDK with Windows desktop support enabled

### Step-by-Step Commands

#### 1. Enable Windows Desktop Support
```bash
flutter config --enable-windows-desktop
```

#### 2. Verify Windows Setup
```bash
flutter doctor
```
Ensure Windows toolchain shows no issues. You may need to install Visual Studio if not already installed.

#### 3. List Available Devices
```bash
flutter devices
```
You should see:
```
Windows (desktop) • windows • windows-x64 • Microsoft Windows [Version ...]
```

#### 4. Run on Windows
```bash
# Run on Windows desktop
flutter run -d windows

# Run in release mode
flutter run -d windows --release

# Run with specific window size
flutter run -d windows --window-size=800,600
```

#### 5. Build for Windows
```bash
# Debug build
flutter build windows --debug

# Release build
flutter build windows --release
# Output: build/windows/runner/Release/
```

### Windows-Specific Notes
- **Architecture**: x64 (64-bit) only
- **Visual Studio**: Required for building (free Community edition works)
- **Dependencies**: Some features may have limitations (see Platform Compatibility section)
- **Localhost Access**: `localhost` works normally on Windows

---

## 🌐 Web Platform

### Prerequisites
- Chrome, Edge, or Firefox browser
- Flutter SDK with Web support enabled

### Step-by-Step Commands

#### 1. Enable Web Support
```bash
flutter config --enable-web
```

#### 2. Verify Web Setup
```bash
flutter doctor
```

#### 3. List Available Devices
```bash
flutter devices
```
You should see:
```
Chrome (web) • chrome • web-javascript • Google Chrome ...
Edge (web)   • edge   • web-javascript • Microsoft Edge ...
```

#### 4. Run on Web
```bash
# Run on Chrome (default)
flutter run -d chrome

# Run on Edge
flutter run -d edge

# Run on Firefox
flutter run -d firefox

# Run on Chrome with specific port
flutter run -d chrome --web-port=8080

# Run with specific hostname
flutter run -d chrome --web-hostname=localhost
```

#### 5. Build for Web
```bash
# Debug build
flutter build web --debug

# Release build
flutter build web --release
# Output: build/web/

# Build with base href (for deployment)
flutter build web --release --base-href=/library-booking/
```

#### 6. Serve Web Build Locally
```bash
# After building, serve the web build
cd build/web
python -m http.server 8000
# Or use any static file server
```

### Web-Specific Notes
- **Browser Support**: Chrome, Edge, Firefox, Safari
- **Performance**: Web builds may be slower than native
- **Features**: Some features have limitations (see Platform Compatibility section)
- **Localhost Access**: `localhost` works normally on Web
- **CORS**: Ensure backend allows CORS for web requests

---

## 📊 Platform Compatibility

### ✅ Fully Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Fully Supported | All features work |
| **iOS** | ✅ Fully Supported | All features work (macOS required) |
| **Web** | ⚠️ Partially Supported | Some features limited (see below) |
| **Windows** | ⚠️ Partially Supported | Some features limited (see below) |
| **Linux** | ⚠️ Not Tested | May work with limitations |
| **macOS** | ⚠️ Not Tested | May work with limitations |

### 🔍 Dependency Platform Compatibility

#### ✅ Works on All Platforms

| Dependency | Android | iOS | Web | Windows | Notes |
|------------|---------|-----|-----|---------|-------|
| `provider` | ✅ | ✅ | ✅ | ✅ | State management |
| `http` | ✅ | ✅ | ✅ | ✅ | HTTP client |
| `web_socket_channel` | ✅ | ✅ | ✅ | ✅ | WebSocket support |
| `connectivity_plus` | ✅ | ✅ | ✅ | ✅ | Network connectivity |
| `shared_preferences` | ✅ | ✅ | ✅ | ✅ | Local storage |
| `intl` | ✅ | ✅ | ✅ | ✅ | Internationalization |
| `flutter_svg` | ✅ | ✅ | ✅ | ✅ | SVG rendering |
| `fl_chart` | ✅ | ✅ | ✅ | ✅ | Charts and graphs |
| `url_launcher` | ✅ | ✅ | ✅ | ✅ | URL launching |
| `share_plus` | ✅ | ✅ | ✅ | ✅ | Share functionality |

#### ⚠️ Platform-Specific Limitations

| Dependency | Android | iOS | Web | Windows | Notes |
|------------|---------|-----|-----|---------|-------|
| `flutter_secure_storage` | ✅ | ✅ | ⚠️ Limited | ✅ | Web uses localStorage fallback |
| `qr_flutter` | ✅ | ✅ | ✅ | ✅ | QR code generation works everywhere |
| `qr_code_scanner` | ✅ | ✅ | ❌ No | ❌ No | Camera access required |
| `image_picker` | ✅ | ✅ | ⚠️ Limited | ⚠️ Limited | Web: file picker only |
| `permission_handler` | ✅ | ✅ | ⚠️ Limited | ⚠️ Limited | Web: limited permissions |

### 🚫 Features Not Available on Web/Windows

#### 1. QR Code Scanner (`qr_code_scanner`)
- **Web**: ❌ Not available (no camera access)
- **Windows**: ❌ Not available (no camera access)
- **Workaround**: Use manual QR code entry (implemented in app)

#### 2. Camera Access
- **Web**: ❌ No native camera access
- **Windows**: ⚠️ Limited (depends on device)
- **Impact**: QR code scanning feature unavailable

#### 3. Secure Storage (`flutter_secure_storage`)
- **Web**: ⚠️ Uses localStorage (less secure than native)
- **Windows**: ✅ Works (uses Windows Credential Manager)
- **Impact**: Tokens stored less securely on web

#### 4. Image Picker
- **Web**: ⚠️ File picker only (no camera)
- **Windows**: ⚠️ File picker only (no camera)
- **Impact**: Can't take photos, only select files

#### 5. Permission Handler
- **Web**: ⚠️ Limited permissions (browser-based)
- **Windows**: ⚠️ Limited permissions
- **Impact**: Some permissions may not work as expected

### ✅ Features That Work on All Platforms

1. **Authentication**: Login, Register, Logout
2. **Resource Browsing**: View, search, filter resources
3. **Booking Management**: Create, view, cancel bookings
4. **QR Code Display**: Generate and display QR codes
5. **Real-time Updates**: WebSocket/polling (works on all platforms)
6. **Notifications**: View and manage notifications
7. **Analytics**: View charts and statistics
8. **User Management**: (Admin) Manage users
9. **Policy Management**: (Admin) Manage policies
10. **Resource Management**: (Admin) CRUD operations

### 🔧 Platform-Specific Workarounds

#### Web Platform

**QR Code Scanning:**
- The app includes a manual QR code entry option
- Users can type QR code data instead of scanning

**Secure Storage:**
- Uses browser localStorage (less secure)
- Consider using HTTPS in production

**Camera Access:**
- Not available on web
- QR code scanning feature disabled on web

#### Windows Platform

**QR Code Scanning:**
- Not available (unless device has camera)
- Use manual QR code entry

**Camera Access:**
- Limited to devices with cameras
- May not work on all Windows devices

---

## ⚠️ Platform Limitations

### Features NOT Available on Web/Windows:
- ❌ **QR Code Scanner** (camera access required)
  - ✅ **Workaround**: Manual QR code entry available

### Features with Limitations:
- ⚠️ **Secure Storage** (Web): Uses localStorage (less secure)
- ⚠️ **Image Picker** (Web/Windows): File picker only (no camera)

### Features Available on All Platforms:
- ✅ Authentication (Login/Register)
- ✅ Resource Browsing
- ✅ Booking Management
- ✅ QR Code Display (generation)
- ✅ Real-time Updates
- ✅ All Admin/Staff features

---

## 🛠️ Troubleshooting

### Common Issues

**"No devices found"**
```bash
# Check available devices
flutter devices

# For Android: Check ADB
adb devices

# Restart ADB (Android)
adb kill-server
adb start-server
```

**"Backend connection failed"**
1. Verify backend is running: `docker-compose ps`
2. Check API URL in `app_config.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`

**"Platform not enabled"**
```bash
# Enable the platform
flutter config --enable-windows-desktop  # For Windows
flutter config --enable-web              # For Web
```

### Android Issues

**Issue**: "No devices found"
```bash
# Check ADB connection
adb devices

# Restart ADB
adb kill-server
adb start-server
```

**Issue**: "SDK version mismatch"
```bash
# Update Android SDK
flutter doctor --android-licenses
```

**Issue**: SDK Version
- Update Android SDK to version 36
- Run `flutter clean` then `flutter pub get`
- Check `android/app/build.gradle.kts` configuration

**Issue**: Gradle Sync
```bash
flutter clean
flutter pub get
```

**Issue**: Build Errors
- Check `android/app/build.gradle.kts` configuration
- Verify Android SDK version

### iOS Issues

**Issue**: CocoaPods
```bash
cd ios
pod install
cd ..
```

**Issue**: Signing
- Configure signing in Xcode
- Select development team in "Signing & Capabilities"

**Issue**: Build Errors
- Check Xcode project settings
- Verify CocoaPods dependencies are installed

### Windows Issues

**Issue**: "Windows desktop not enabled"
```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

**Issue**: "Visual Studio not found"
- Install Visual Studio 2019 or later
- Install "Desktop development with C++" workload

### Web Issues

**Issue**: "Web not enabled"
```bash
flutter config --enable-web
```

**Issue**: "CORS errors"
- Configure backend to allow CORS
- Or use proxy during development

**Issue**: "Features not working on web"
- Check Platform Compatibility section
- Some features are intentionally disabled on web

---

## 📝 Recommended Platform Usage

### For Development
- **Android Emulator**: Best for testing mobile features
- **Chrome (Web)**: Fastest for UI development
- **Windows Desktop**: Good for desktop testing

### For Production
- **Android**: ✅ Full feature support
- **iOS**: ✅ Full feature support
- **Web**: ⚠️ Limited features (no QR scanning)
- **Windows**: ⚠️ Limited features (no QR scanning)

### For Testing
- Test on **Android** for full feature coverage
- Test on **Web** for cross-platform compatibility
- Test on **Windows** if targeting desktop users

---

## 🎯 Quick Reference

### Run Commands
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# Web (Chrome)
flutter run -d chrome
```

### Build Commands
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

### Check Devices
```bash
flutter devices
```

### Check Platform Support
```bash
flutter doctor
```

---

## ⚠️ Important Notes

1. **Android SDK**: You may need to update your Android SDK to version 36 as required by Flutter
2. **iOS Development**: Requires macOS and Xcode (free from Mac App Store)
3. **Signing**: Both Android and iOS require proper code signing for release builds
4. **Permissions**: Camera permission is required for QR code scanning feature
5. **Network**: App is configured to allow cleartext traffic for localhost development
6. **Windows**: Requires Visual Studio with C++ desktop development workload
7. **Web**: Some features have limitations due to browser security restrictions

---

## 📚 Additional Resources

- [Flutter Platform Support](https://docs.flutter.dev/platform-support)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/windows)
- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos)
- [Flutter Web Support](https://docs.flutter.dev/platforms/web)
- [Flutter Windows Support](https://docs.flutter.dev/platforms/windows)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS App Distribution](https://developer.apple.com/distribute/)

---

**Last Updated**: December 2025
