import 'package:url_launcher/url_launcher.dart';

abstract class OAuthBrowser {
  Future<void> open(Uri uri);
}

class SystemOAuthBrowser implements OAuthBrowser {
  const SystemOAuthBrowser();

  @override
  Future<void> open(Uri uri) async {
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch) {
      throw StateError('Could not open the system browser.');
    }
  }
}
