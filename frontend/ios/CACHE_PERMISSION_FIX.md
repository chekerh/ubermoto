# CocoaPods Cache Permission Fix

## Issue
CocoaPods cannot write to `~/Library/Caches/CocoaPods` due to macOS permissions.

## Solution 1: Fix Permissions (Recommended)

Run these commands in Terminal:

```bash
# Remove existing cache (if it exists)
sudo rm -rf ~/Library/Caches/CocoaPods

# Create directory with proper permissions
sudo mkdir -p ~/Library/Caches/CocoaPods
sudo chown -R $(whoami):staff ~/Library/Caches/CocoaPods
sudo chmod -R 755 ~/Library/Caches/CocoaPods

# Verify permissions
ls -la ~/Library/Caches/ | grep CocoaPods
```

Then run:
```bash
cd frontend/ios
pod install
```

## Solution 2: Use Alternative Cache Location

If Solution 1 doesn't work (macOS security restrictions), use a custom cache location:

```bash
# Set custom cache directory
export CP_CACHE_DIR=~/tmp/CocoaPodsCache

# Create the directory
mkdir -p ~/tmp/CocoaPodsCache

# Run pod install
cd frontend/ios
pod install
```

## Solution 3: Grant Full Disk Access (macOS)

If the above solutions don't work, you may need to grant Terminal/iTerm full disk access:

1. Open **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Add Terminal (or iTerm if you use it)
3. Restart Terminal
4. Try Solution 1 again

## Verification

After fixing permissions, `pod install` should complete without "Operation not permitted" errors.
