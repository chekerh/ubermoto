# CocoaPods Installation Fix Instructions

## Problem
CocoaPods cannot create the cache directory due to macOS permissions.

## Solution

Run these commands in your terminal (you'll need to enter your password for sudo):

```bash
# Fix CocoaPods cache permissions
sudo chown -R $(whoami) ~/Library/Caches/CocoaPods

# If the directory doesn't exist, create it first
sudo mkdir -p ~/Library/Caches/CocoaPods
sudo chown -R $(whoami) ~/Library/Caches/CocoaPods
sudo chmod 755 ~/Library/Caches/CocoaPods

# Then navigate to ios folder and install pods
cd frontend/ios
pod install
```

## Alternative: Use Different Cache Location

If the above doesn't work, you can set a custom cache location:

```bash
export CP_CACHE_DIR=~/tmp/CocoaPods
mkdir -p ~/tmp/CocoaPods
cd frontend/ios
pod install
```

## Current Podfile Configuration

The Podfile is now configured to:
1. Use IndoorAtlas specs repo for MapLibre (version 5.12.2+)
2. Fetch MapLibreAnnotationExtension from GitHub

Once permissions are fixed, `pod install` should complete successfully.
