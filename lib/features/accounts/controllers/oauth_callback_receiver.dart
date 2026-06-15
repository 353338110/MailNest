import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';

import '../../../core/platform/platform_info.dart';

abstract class OAuthCallbackReceiver {
  Future<OAuthCallbackWaiter> start(Uri redirectUri);
}

class OAuthCallbackWaiter {
  const OAuthCallbackWaiter({
    required this.redirectUri,
    required this.callback,
    required this.close,
  });

  final Uri redirectUri;
  final Future<Uri> callback;
  final Future<void> Function() close;
}

class PlatformOAuthCallbackReceiver implements OAuthCallbackReceiver {
  const PlatformOAuthCallbackReceiver({
    this.platformInfo = const PlatformInfo(),
    this.appLinks,
  });

  final PlatformInfo platformInfo;
  final AppLinks? appLinks;

  @override
  Future<OAuthCallbackWaiter> start(Uri redirectUri) {
    if (platformInfo.isDesktop) {
      return LoopbackOAuthCallbackReceiver().start(redirectUri);
    }

    return AppLinkOAuthCallbackReceiver(
      appLinks: appLinks ?? AppLinks(),
    ).start(redirectUri);
  }
}

class AppLinkOAuthCallbackReceiver implements OAuthCallbackReceiver {
  const AppLinkOAuthCallbackReceiver({required this.appLinks});

  final AppLinks appLinks;

  @override
  Future<OAuthCallbackWaiter> start(Uri redirectUri) async {
    final controller = StreamController<Uri>();
    late final StreamSubscription<Uri> subscription;

    subscription = appLinks.uriLinkStream.listen((uri) {
      if (_matchesRedirect(uri, redirectUri) && !controller.isClosed) {
        controller.add(uri);
      }
    }, onError: controller.addError);

    return OAuthCallbackWaiter(
      redirectUri: redirectUri,
      callback: controller.stream.first,
      close: () async {
        await subscription.cancel();
        await controller.close();
      },
    );
  }
}

class LoopbackOAuthCallbackReceiver implements OAuthCallbackReceiver {
  const LoopbackOAuthCallbackReceiver();

  @override
  Future<OAuthCallbackWaiter> start(Uri redirectUri) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final boundRedirectUri = redirectUri.replace(port: server.port);
    final completer = Completer<Uri>();

    unawaited(
      server.first
          .then((request) async {
            final uri = request.requestedUri;
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.html
              ..write(
                '<!doctype html><title>MailNest</title>'
                '<p>Authorization received. You can close this window.</p>',
              );
            await request.response.close();
            if (!completer.isCompleted) {
              completer.complete(uri);
            }
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          }),
    );

    return OAuthCallbackWaiter(
      redirectUri: boundRedirectUri,
      callback: completer.future,
      close: () => server.close(force: true),
    );
  }
}

bool _matchesRedirect(Uri value, Uri redirectUri) {
  return value.scheme == redirectUri.scheme &&
      value.host == redirectUri.host &&
      value.path == redirectUri.path;
}
