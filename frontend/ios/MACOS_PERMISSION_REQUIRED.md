# macOS Full Disk Access Required

## Why This Is Necessary

macOS is blocking CocoaPods (and git) from creating files in system directories like `/tmp` and `~/Library/Caches`. This is a security feature that requires explicit permission.

**There is no workaround** - you must grant Full Disk Access to Terminal.

## Quick Fix (5 minutes)

1. **Open System Settings** (or System Preferences)
2. Go to **Privacy & Security** → **Full Disk Access**
3. Click the **lock icon** (bottom left) and enter your password
4. Click the **+** button
5. Navigate to `/Applications/Utilities/Terminal.app` and add it
   - If using iTerm: `/Applications/iTerm.app`
6. **Restart Terminal completely** (quit and reopen)
7. Run:

```bash
cd frontend/ios
pod install
```

## Why Other Methods Don't Work

- ❌ Custom cache directories (`CP_CACHE_DIR`) - Still blocked
- ❌ Project-local cache - Still blocked  
- ❌ `sudo` commands - Don't help with Full Disk Access
- ❌ Different terminal locations - Same permission issue

**Only Full Disk Access works** because CocoaPods needs to:
- Clone git repositories to `/tmp`
- Create cache files
- Write podspec files
- All of these require Full Disk Access on modern macOS

## Verification

After granting Full Disk Access and restarting Terminal, you should see:
- ✅ `pod install` completes without "Operation not permitted" errors
- ✅ Git clones succeed
- ✅ Cache files are created

## Alternative: Use Xcode

If you absolutely cannot grant Full Disk Access, you can try:
1. Open the project in Xcode
2. Let Xcode handle pod installation automatically
3. But this still may require permissions

**Bottom line:** Full Disk Access is the standard solution for CocoaPods on macOS and is safe to grant to Terminal.
