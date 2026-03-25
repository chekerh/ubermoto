import 'package:flutter/widgets.dart';

/// Web-only HTML embed; on VM/mobile this is false and [StitchViewer] uses [WebViewController].
bool stitchHtmlEmbedAvailable() => false;

/// Unused on non-web; never call when [stitchHtmlEmbedAvailable] is false.
Widget stitchHtmlEmbed({
  required String assetPath,
  required Key key,
}) =>
    const SizedBox.shrink();
