#!/bin/bash

# UberMoto Frontend Deployment Preparation Script
# Prepares frontend builds for web and mobile deployment

echo "📱 UberMoto Frontend Deployment Preparation"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✅ $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

cd frontend

# Check Flutter environment
echo "🔍 Checking Flutter Environment..."

# Verify Flutter installation
flutter --version > /dev/null 2>&1
print_status $? "Flutter is installed"

# Check Flutter doctor
echo "Running Flutter doctor..."
flutter doctor --suppress-analytics > /dev/null 2>&1
flutter_doctor_status=$?

if [ $flutter_doctor_status -eq 0 ]; then
    echo -e "${GREEN}✅ Flutter doctor passed${NC}"
else
    echo -e "${YELLOW}⚠️  Flutter doctor found issues - review output above${NC}"
fi

# Install dependencies
echo ""
echo "📦 Installing Dependencies..."
flutter pub get > /dev/null 2>&1
print_status $? "Dependencies installed"

# Build web version
echo ""
echo "🌐 Building Web Version..."
flutter build web --release --suppress-analytics > /dev/null 2>&1
print_status $? "Web build completed"

# Check web build output
if [ -d "build/web" ]; then
    web_size=$(du -sh build/web | cut -f1)
    echo -e "${GREEN}✅ Web build created - Size: $web_size${NC}"

    # Check for required files
    if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
        echo -e "${GREEN}✅ Web build contains required files${NC}"
    else
        echo -e "${RED}❌ Web build missing required files${NC}"
    fi
else
    echo -e "${RED}❌ Web build failed - build/web directory not found${NC}"
fi

# Build Android APK (if Android SDK available)
echo ""
echo "🤖 Building Android APK..."
flutter build apk --release --suppress-analytics > /dev/null 2>&1
android_status=$?

if [ $android_status -eq 0 ]; then
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        apk_size=$(stat -f%z build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ Android APK built - Size: $apk_size bytes${NC}"
        echo "   APK location: build/app/outputs/flutter-apk/app-release.apk"
    else
        echo -e "${YELLOW}⚠️  Android APK build completed but file not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Android APK build failed - Android SDK may not be configured${NC}"
fi

# Build iOS (if on macOS with Xcode)
echo ""
echo "🍎 Building iOS App..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release --no-codesign --suppress-analytics > /dev/null 2>&1
    ios_status=$?

    if [ $ios_status -eq 0 ]; then
        echo -e "${GREEN}✅ iOS build completed${NC}"
        echo "   iOS build location: build/ios/iphoneos/Runner.app"
    else
        echo -e "${YELLOW}⚠️  iOS build failed - Xcode may not be configured${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  iOS build skipped - Not on macOS${NC}"
fi

# Generate app icons and splash screens
echo ""
echo "🎨 Checking App Assets..."

# Check for launcher icons
if [ -f "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" ] || [ -f "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" ]; then
    echo -e "${GREEN}✅ App icons configured${NC}"
else
    echo -e "${YELLOW}⚠️  App icons may not be configured${NC}"
fi

# Validate configuration files
echo ""
echo "⚙️  Validating Configuration..."

# Check pubspec.yaml for required fields
if grep -q "version:" pubspec.yaml && grep -q "name:" pubspec.yaml; then
    echo -e "${GREEN}✅ Pubspec.yaml contains required fields${NC}"
else
    echo -e "${RED}❌ Pubspec.yaml missing required fields${NC}"
fi

# Check for environment configuration
if [ -f "lib/config/app_config.dart" ]; then
    echo -e "${GREEN}✅ App configuration file exists${NC}"
else
    echo -e "${RED}❌ App configuration file missing${NC}"
fi

# Generate deployment documentation
echo ""
echo "📚 Generating Deployment Documentation..."

cat > DEPLOYMENT_README.md << 'EOF'
# UberMoto Frontend Deployment Guide

## Web Deployment (Firebase Hosting)

### Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project created
- Authenticated with Firebase: `firebase login`

### Deployment Steps
```bash
# Initialize Firebase (first time only)
firebase init hosting

# Select your Firebase project
# Set public directory to: build/web
# Configure as single-page app: Yes

# Deploy to Firebase
firebase deploy --only hosting

# Or deploy specific site
firebase deploy --only hosting:your-site-name
```

### Custom Domain Setup
1. Go to Firebase Console > Hosting
2. Click "Add custom domain"
3. Enter your domain and follow DNS setup instructions

## Mobile Deployment

### Android (Google Play Store)

#### Prerequisites
- Google Play Console account
- Android app signing key
- App metadata (description, screenshots, etc.)

#### Build Release APK
```bash
# Build signed APK
flutter build apk --release

# Or build app bundle (recommended)
flutter build appbundle --release
```

#### Play Store Submission
1. Go to Google Play Console
2. Create new app or update existing
3. Upload APK/AAB file
4. Fill app details (description, screenshots, etc.)
5. Set pricing and distribution
6. Submit for review

### iOS (App Store)

#### Prerequisites
- Apple Developer account
- Xcode configured
- App Store Connect account
- Distribution certificate and provisioning profile

#### Build for iOS
```bash
# Build for iOS
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# Archive and upload via Xcode
# Product > Archive > Distribute App > App Store Connect
```

#### App Store Submission
1. Go to App Store Connect
2. Create new app or update existing
3. Upload build via Xcode or Transporter
4. Fill app information and screenshots
5. Submit for review

## Environment Configuration

### Web Environment Variables
Create `.env` file in web deployment:
```javascript
// web/index.html or Firebase functions
window.UBERMOTO_CONFIG = {
  API_BASE_URL: 'https://your-api-domain.com',
  GOOGLE_MAPS_API_KEY: 'your-maps-api-key',
  SENTRY_DSN: 'your-sentry-dsn',
  ANALYTICS_ID: 'your-ga-id'
};
```

### Mobile Environment Variables
Use `--dart-define` for mobile builds:
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-api-domain.com \
  --dart-define=GOOGLE_MAPS_API_KEY=your-maps-api-key \
  --dart-define=SENTRY_DSN=your-sentry-dsn
```

## Monitoring Setup

### Google Analytics
1. Create GA4 property
2. Add measurement ID to app
3. Configure custom events for UberMoto actions

### Sentry Error Tracking
1. Create Sentry project
2. Add DSN to app configuration
3. Configure error boundaries and user feedback

## Testing Deployments

### Web Testing
```bash
# Test locally before deployment
flutter run -d web-server

# Test Firebase hosting locally
firebase serve --only hosting
```

### Mobile Testing
```bash
# Test Android on device
flutter run -d android-device

# Test iOS on device
flutter run -d ios-device
```

## Performance Optimization

### Web Optimizations
- Enable gzip compression in Firebase hosting
- Configure CDN caching headers
- Optimize bundle size with code splitting
- Use service workers for caching

### Mobile Optimizations
- Configure ProGuard for Android
- Enable bitcode for iOS
- Optimize image assets
- Configure app thinning

## Rollback Procedures

### Web Rollback
```bash
# Firebase hosting versions
firebase hosting:rollback

# Or redeploy previous version
git checkout previous-commit-hash
firebase deploy --only hosting
```

### Mobile Rollback
- Use Play Store/App Store rollback features
- Submit new version with fixes
- Communicate with users about updates
EOF

print_status 0 "Frontend deployment documentation generated"

# Create Firebase configuration if needed
echo ""
echo "🔥 Checking Firebase Configuration..."

if [ ! -f "firebase.json" ]; then
    echo -e "${YELLOW}⚠️  Firebase not configured${NC}"
    echo "Run 'firebase init hosting' to set up Firebase hosting"
else
    echo -e "${GREEN}✅ Firebase configuration found${NC}"
fi

echo ""
echo "🎯 Frontend Deployment Preparation Complete!"
echo ""
echo "📦 Build Artifacts Created:"
echo "   Web: build/web/ (Size: $(du -sh build/web 2>/dev/null | cut -f1 || echo 'unknown'))"
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "   Android: build/app/outputs/flutter-apk/app-release.apk"
fi
if [[ "$OSTYPE" == "darwin"* ]] && [ -d "build/ios/iphoneos" ]; then
    echo "   iOS: build/ios/iphoneos/Runner.app"
fi
echo ""
echo "🚀 Ready for manual deployment:"
echo "   Web: Deploy to Firebase Hosting"
echo "   Android: Submit APK to Google Play Store"
echo "   iOS: Submit to Apple App Store"
echo ""
echo "📚 See DEPLOYMENT_README.md for detailed instructions"