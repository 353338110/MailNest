import 'package:flutter/foundation.dart';

import 'email_body_renderer.dart';

enum EmailRenderStrategy { flutterBasic, webView, plainTextFallback }

class EmailBodyRendererFactory {
  const EmailBodyRendererFactory();

  EmailBodyRenderer create({
    required TargetPlatform platform,
    required bool webViewAvailable,
  }) {
    // First-stage desktop support must not depend on WebView availability.
    // Mobile WebView rendering can be added behind this factory later.
    return const BasicEmailBodyRenderer();
  }
}
