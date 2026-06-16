import 'dart:async';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SystemBrowser {
  static const _callbackStream = EventChannel(
    'com.funmaster.mailnest/oauth_callbacks',
  );

  Stream<Uri> get callbackUris {
    return _callbackStream
        .receiveBroadcastStream()
        .where((value) => value is String)
        .cast<String>()
        .map(Uri.parse);
  }

  Future<bool> open(Uri uri) async {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
