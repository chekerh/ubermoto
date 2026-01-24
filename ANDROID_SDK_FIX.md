# 🔧 Android SDK Configuration Fix for Flutter

## Problem
Flutter cannot build Android APKs because the Android SDK Command Line Tools are missing.

**Error:** `Android sdkmanager not found. Update to the latest Android SDK and ensure that the cmdline-tools are installed to resolve this.`

## Root Cause
Your Android SDK is installed at `~/Library/Android/sdk` but is missing the Command Line Tools component.

## ✅ Solution: Install Android SDK Command Line Tools

### Method 1: Via Android Studio (Recommended)

1. **Open Android Studio**
2. **Go to SDK Manager:**
   - On macOS: `Android Studio > Settings > Languages & Frameworks > Android SDK`
   - Or use keyboard shortcut: `Cmd + ,` then search for "SDK"

3. **Show Package Details:**
   - Check "Show Package Details" in the bottom right

4. **Install Command Line Tools:**
   - Expand "Android SDK Command-line Tools (latest)"
   - Check the box for the latest version (e.g., "Android SDK Command-line Tools 13.0")
   - Click "Apply" to install

5. **Wait for Installation:**
   - This may take several minutes
   - Android Studio will download and install the tools

### Method 2: Manual Download (Alternative)

1. **Download from Android Developer Site:**
   ```bash
   # Go to: https://developer.android.com/studio#command-line-tools-only
   # Download the latest command line tools for macOS
   ```

2. **Extract and Install:**
   ```bash
   cd ~/Downloads
   unzip commandlinetools-mac-*.zip
   mkdir -p ~/Library/Android/sdk/cmdline-tools
   mv cmdline-tools ~/Library/Android/sdk/cmdline-tools/latest
   ```

## 🔧 Environment Variables (Optional but Recommended)

Add these to your `~/.zshrc` or `~/.bash_profile`:

```bash
# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
```

Reload your shell:
```bash
source ~/.zshrc
```

## ✅ Verification Steps

### 1. Check Android SDK Location
```bash
echo $ANDROID_HOME
# Should output: /Users/mac/Library/Android/sdk
```

### 2. Verify Command Line Tools
```bash
ls ~/Library/Android/sdk/cmdline-tools/
# Should show: latest/
```

### 3. Test SDK Manager
```bash
sdkmanager --version
# Should output version information
```

### 4. Accept Android Licenses
```bash
flutter doctor --android-licenses
# Accept all licenses when prompted
```

### 5. Run Flutter Doctor
```bash
flutter doctor
# Should show: [✓] Android toolchain - develop for Android devices
```

### 6. Test APK Build
```bash
cd frontend
flutter build apk --debug
# Should complete successfully
```

## 🚀 Test Your Fix

After completing the above steps, run the production setup again:

```bash
./scripts/final-production-setup.sh
```

You should now see:
```
🤖 Building Android APK...
✅ Android APK built - Size: XXX bytes
   APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Do You Need an Android Emulator?

**No, you don't need to launch an Android emulator to build APKs!**

- **APK Building:** Can be done without any emulator or device connected
- **Emulator Usage:** Only needed for testing/running the app on a virtual device
- **Physical Device:** Can test on real Android device via USB debugging

## 🔍 Troubleshooting

### Still Getting Errors?

**Check Flutter Doctor Output:**
```bash
flutter doctor -v
```

**Common Issues:**

1. **JAVA_HOME not set:**
   ```bash
   export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
   ```

2. **Multiple Java versions:**
   ```bash
   /usr/libexec/java_home -V
   export JAVA_HOME=$(/usr/libexec/java_home -v 17)  # or your Java version
   ```

3. **Permission issues:**
   ```bash
   sudo chown -R $(whoami) ~/Library/Android/sdk
   ```

4. **Clean Flutter cache:**
   ```bash
   flutter clean
   flutter pub get
   ```

### Alternative: Use Android Studio SDK Manager

If manual installation fails, use Android Studio:

1. Open Android Studio
2. Go to `Tools > SDK Manager`
3. Select `SDK Tools` tab
4. Check `Android SDK Command-line Tools (latest)`
5. Click `Apply` and wait for installation

## 🎯 Next Steps

Once Android SDK is properly configured:

1. ✅ Run `./scripts/final-production-setup.sh`
2. ✅ Android APK will build successfully
3. ✅ Deploy APK to Google Play Store
4. ✅ Your UberMoto app will be ready for Android users!

## 📞 Support

If you continue having issues:
- Check Flutter documentation: https://flutter.dev/docs/get-started/install/macos#android-setup
- Android Studio setup: https://developer.android.com/studio
- Flutter doctor verbose: `flutter doctor -v`