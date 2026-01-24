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
