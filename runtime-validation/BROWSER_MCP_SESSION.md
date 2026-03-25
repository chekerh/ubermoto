# Browser MCP session log (agent)

**Date:** 2026-03-25  
**Stack:** API on `localhost:3010` (existing terminal), Flutter `web-server` on `8080`, `--dart-define=BACKEND_PORT=3010`.

## Outcomes

| Step | Result |
|------|--------|
| Navigate `http://localhost:8080` | OK |
| Initial load | Previously **red screen** (`WebViewPlatform.instance`); fixed by **web iframe** path (see below) |
| Splash / Stitch HTML | **Visible** in screenshot (logo, language row, Get Started, loading bar) |
| Accessibility snapshot | Mostly **flutter-view** + “Enable accessibility”; few named controls for MCP `ref` clicks |
| Coordinate click on FAB / AppBar | Tool often reported **stale element** after `click` on `e1`; navigation to login **not confirmed** in this session |

## Code changes enabling web + QA

1. **`lib/stitch/stitch_embed_stub.dart` / `stitch_embed_web.dart`** — conditional import (`dart.library.html`): web loads Stitch HTML in an **iframe** (`/assets/.../code.html`).
2. **`stitch_viewer.dart`** — nullable `WebViewController?`, `_useWebEmbed`, `_controller!` at call sites; web embed branch; **FAB + AppBar IconButton** when web + splash for QA navigation.
3. **`main.dart`** — `nextRoute: '/login1'` on **uninitialized** auth splash (was missing; double-tap/FAB had nowhere to go).
4. **Removed** `webview_flutter_web` / direct `webview_flutter_platform_interface` (iframe replaces broken web WebView API for Stitch).
5. **`package:web`** dependency for iframe DOM types.

## Follow-up

- Confirm `Navigator.pushReplacementNamed('/login1')` via screenshot (login title) or network tab after FAB click once MCP stale-ref behavior is understood.
- Full login/register E2E on web still depends on Stitch HTML calling APIs without Flutter bridge (limited on web).
