# Critical: Full Disk Access Not Working

## Current Status

CocoaPods cannot read or write files, indicating Full Disk Access is not properly enabled or Terminal needs to be restarted.

## Immediate Action Required

### Step 1: Verify Full Disk Access

1. Open **System Settings** (or System Preferences)
2. Go to **Privacy & Security** → **Full Disk Access**
3. **Check if Terminal.app is listed**
4. **Verify the toggle is ON** (green/enabled)
5. If not listed or disabled:
   - Click the **lock icon** (bottom left) and enter your password
   - Click **+** button
   - Navigate to `/Applications/Utilities/Terminal.app`
   - Add it
   - **Make sure the toggle is ON**

### Step 2: Restart Terminal

1. **Quit Terminal completely** (Cmd+Q, don't just close window)
2. **Wait 5 seconds**
3. **Reopen Terminal**
4. Navigate back: `cd /Users/mac/ubermoto/frontend/ios`

### Step 3: Test Permissions

Run this test:
```bash
cd /tmp
mkdir test-perm && cd test-perm
echo "test" > test.txt
cat test.txt
rm test.txt
cd .. && rmdir test-perm
```

If this fails with "Operation not permitted", Full Disk Access is still not working.

### Step 4: Download MapLibreAnnotationExtension

Once permissions work, run:
```bash
cd frontend/ios
./setup_maplibre.sh
```

This will download both MapLibre and MapLibreAnnotationExtension.

### Step 5: Install Pods

```bash
pod install
```

## Why This Is Happening

macOS is blocking ALL file operations (read and write) because Terminal doesn't have Full Disk Access. This is a system-level security restriction that cannot be bypassed.

## If Still Not Working

1. Try granting Full Disk Access to **iTerm** (if you have it)
2. Or use **VS Code integrated terminal** (might have different permissions)
3. Or check macOS security logs in Console.app for specific errors

## Current Configuration

- ✅ MapLibre source downloaded locally
- ✅ Local podspecs created
- ✅ Podfile configured correctly
- ❌ MapLibreAnnotationExtension needs to be downloaded
- ❌ Full Disk Access not working (blocking all operations)

Once Full Disk Access works, everything should proceed normally.
