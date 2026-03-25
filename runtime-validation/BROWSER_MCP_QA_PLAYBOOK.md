# Browser MCP — interactive QA playbook

Use **Cursor’s IDE Browser MCP** (`cursor-ide-browser`) to drive the app like a tester: navigate, snapshot the DOM, click buttons, fill forms, and assert behavior.

## 1. Enable the MCP server

1. Open **Cursor Settings → MCP**.
2. Ensure **Cursor IDE Browser** is enabled (built-in / already configured in many setups).
3. Tool descriptors live under your Cursor project MCP folder (e.g. `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_fill`, `browser_tabs`, etc.).

Agents should **read the tool schema** before calling (per Cursor MCP instructions).

## 2. Start the stack for UI testing

### Backend

```bash
cd backend
cp .env.example .env.local   # edit MONGODB_URI, JWT_SECRET, PORT
npm ci && rm -rf dist && npm run build
npm run seed:catalog        # optional: demo catalog (same MONGODB_URI)
PORT=3001 NODE_ENV=development node dist/main.js
```

### Flutter Web (best target for browser MCP)

```bash
cd frontend
flutter pub get
# Match API port if not 3001 (e.g. backend on 3010):
flutter run -d web-server --web-port 8080 --web-hostname localhost \
  --dart-define=BACKEND_PORT=3010
```

Then open **`http://localhost:8080`** in the automated browser.

**Web vs mobile Stitch:** `webview_flutter` on web does not support `setJavaScriptMode` / `StitchBridge` / injected JS the way iOS/Android do. This repo uses an **HTML iframe** (`stitch_embed_web.dart`) on web that loads `/assets/stitch/.../code.html`. You get real splash/login HTML and clicks *inside* the iframe, but **Flutter-side route bindings and API bridges do not run on web**. For full flows, test on a device or emulator.

**Splash navigation on web:** Double-tap is wrapped outside the iframe but **pointer events hit the iframe first**, so double-tap often does not reach Flutter. While `routeName` starts with `/splash`, the app shows an AppBar **forward** action and a small **FAB** (“Next screen (web)”) that call the same handler as double-tap.

**Semantics:** The IDE Browser snapshot may only show `Enable accessibility` + one `generic` (`flutter-view`); use **screenshots**, **coordinate clicks** on the FAB/AppBar arrow, or enable Flutter semantics in the target browser if available.

### CORS

Add `http://localhost:8080` to `FRONTEND_ORIGINS` (or rely on dev CORS defaults in `main.ts` for localhost) so browser calls to the API are allowed.

## 3. Recommended MCP workflow (agent or human)

1. **`browser_tabs`** — `action: list` → pick or create a tab.
2. **`browser_navigate`** — `url: http://localhost:8080` (or your web URL).
3. **`browser_snapshot`** — capture accessibility tree and element refs.
4. **`browser_click`** / **`browser_fill`** / **`browser_type`** — drive UI using refs from the snapshot.
5. **`browser_wait_for`** / **`browser_snapshot`** — wait for navigation or new content.
6. **`browser_console_messages`** / **`browser_network_requests`** — debug API failures.
7. **`browser_take_screenshot`** — optional evidence for reports.

**Locking:** follow MCP server rules: navigate → lock before interactions → unlock when done.

## 4. What to test (minimum matrix)

| Flow | Steps |
|------|--------|
| Startup / splash | App loads; no red screen |
| Language | Switch EN/AR if exposed |
| Register / login | Customer; token stored; home loads |
| Catalog | Categories/products visible after `npm run seed:catalog` |
| Error state | Stop API; confirm user-visible error (not silent hang) |
| Admin / driver | Separate logins if test users exist |

## 5. Limits

- MCP cannot replace real **iOS/Android** WebView quirks; use device farms or manual device QA for release.
- **Biometric / FCM** — not fully testable in browser MCP alone.

## 6. Relation to repo risks

This playbook directly addresses **“interactive UI unverified”** by giving agents and humans a **repeatable, tool-driven** way to exercise buttons and flows once Flutter web (or a hosted build) is running.
