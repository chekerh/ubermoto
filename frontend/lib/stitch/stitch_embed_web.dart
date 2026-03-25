import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// True when compiled for browser (HTML renderer).
bool stitchHtmlEmbedAvailable() => true;

/// Loads a bundled Stitch `code.html` via same-origin `/assets/...` URL.
///
/// **Limitation:** No `StitchBridge` / injected JS — navigation and API hooks from
/// [StitchViewer] do not run on web. Use for visual QA (MCP, screenshots) and
/// simple in-page links; use iOS/Android for full Stitch integration.
Widget stitchHtmlEmbed({
  required String assetPath,
  required Key key,
}) {
  return _StitchHtmlIFrame(key: key, assetPath: assetPath);
}

class _StitchHtmlIFrame extends StatefulWidget {
  const _StitchHtmlIFrame({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<_StitchHtmlIFrame> createState() => _StitchHtmlIFrameState();
}

class _StitchHtmlIFrameState extends State<_StitchHtmlIFrame> {
  late final String _viewType = 'stitch_iframe_${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    final iframe = web.HTMLIFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..src = _assetUrl(widget.assetPath);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

String _assetUrl(String assetPath) {
  final origin = Uri.base.origin;
  return '$origin/assets/$assetPath';
}
