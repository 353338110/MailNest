class MailHtmlDocument {
  const MailHtmlDocument._();

  static String renderable(String html) {
    final document = _hasDocument(html) ? html : _wrapDocument(html);
    return _injectHeadContent(document, _headContent);
  }

  static const _headContent = '''
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body {
    margin: 0;
    padding: 0;
    background: #ffffff;
  }
  body {
    overflow-wrap: anywhere;
    -webkit-text-size-adjust: 100%;
  }
  img, video {
    max-width: 100% !important;
    height: auto !important;
  }
  table {
    max-width: 100% !important;
  }
</style>
''';

  static bool _hasDocument(String html) {
    return RegExp(r'<\s*(html|body)\b', caseSensitive: false).hasMatch(html);
  }

  static String _wrapDocument(String body) {
    return '<!doctype html><html><head></head><body>$body</body></html>';
  }

  static String _injectHeadContent(String html, String content) {
    final headOpen = RegExp(r'<head\b[^>]*>', caseSensitive: false);
    final headMatch = headOpen.firstMatch(html);
    if (headMatch != null) {
      return html.replaceRange(headMatch.end, headMatch.end, content);
    }

    final htmlOpen = RegExp(r'<html\b[^>]*>', caseSensitive: false);
    final htmlMatch = htmlOpen.firstMatch(html);
    if (htmlMatch != null) {
      return html.replaceRange(
        htmlMatch.end,
        htmlMatch.end,
        '<head>$content</head>',
      );
    }

    return _wrapDocument('$content$html');
  }
}
