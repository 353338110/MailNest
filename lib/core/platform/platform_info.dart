import 'package:flutter/foundation.dart';

/// Centralizes platform checks so business code does not branch on OS details.
class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => kIsWeb;

  TargetPlatform get targetPlatform => defaultTargetPlatform;

  bool get isDesktop {
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }
}
