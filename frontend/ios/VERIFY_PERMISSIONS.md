# Verify Full Disk Access

## Check if Full Disk Access is Actually Enabled

1. **Open System Settings** → **Privacy & Security** → **Full Disk Access**
2. **Verify Terminal.app is listed and the toggle is ON** (green/enabled)
3. If it's not there or disabled:
   - Click the **+** button
   - Add `/Applications/Utilities/Terminal.app`
   - Make sure the toggle is ON
   - **Restart Terminal completely** (Cmd+Q, then reopen)

## Test Git Access

After verifying permissions, test if git works:

```bash
cd /tmp
mkdir test-git && cd test-git
git init
```

If this fails with "Operation not permitted", Full Disk Access is not working.

## Alternative: Use Different Terminal

If Terminal still doesn't work, try:
- **iTerm2** (if installed) - grant it Full Disk Access instead
- **VS Code integrated terminal** - might have different permissions

## Why Git Works in Setup Script But Not CocoaPods

The setup script might have run before permissions were lost, or in a different context. CocoaPods invokes git as a subprocess which might have stricter permission checks.

## Solution

1. **Double-check Full Disk Access** in System Settings
2. **Restart Terminal** completely
3. **Test git** manually (see above)
4. If still blocked, try granting Full Disk Access to **iTerm** or another terminal app
