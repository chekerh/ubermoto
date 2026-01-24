# Final CocoaPods Setup Instructions

## Current Status

The Podfile is correctly configured to:
- ✅ Fetch MapLibre directly from GitHub (ios-v5.12.2 tag)
- ✅ Fetch MapLibreAnnotationExtension from GitHub (master branch)
- ✅ Set iOS deployment target to 15.0 (Firebase requirement)
- ✅ Include IndoorAtlas specs repo as backup source

## Remaining Issue: macOS Permissions

CocoaPods cannot write to cache directories due to macOS security restrictions.

## Solution: Grant Terminal Full Disk Access

This is the most reliable fix:

1. **Open System Settings** (or System Preferences on older macOS)
2. Go to **Privacy & Security** → **Full Disk Access**
3. Click the **+** button to add an application
4. Navigate to `/Applications/Utilities/Terminal.app` and add it
   - Or if using iTerm: `/Applications/iTerm.app`
5. **Restart Terminal** completely (quit and reopen)
6. Run:

```bash
cd frontend/ios
pod install
```

## Alternative: Use Custom Cache with Proper Permissions

If Full Disk Access doesn't work:

```bash
# Create cache directory in a location you own
mkdir -p ~/tmp/CocoaPodsCache
chmod 755 ~/tmp/CocoaPodsCache

# Set environment variable and install
export CP_CACHE_DIR=~/tmp/CocoaPodsCache
cd frontend/ios
pod install
```

## Verification

After successful `pod install`, you should see:
- ✅ All pods downloaded and installed
- ✅ No "Operation not permitted" errors
- ✅ Podfile.lock created
- ✅ Pods directory created

## If Still Having Issues

Check macOS security logs:
```bash
# Check Console.app for permission errors
# Look for "CocoaPods" or "Operation not permitted" messages
```

Or try running with verbose output:
```bash
cd frontend/ios
pod install --verbose
```
