/// Cleans untrusted email HTML before rendering.
abstract class EmailHtmlSanitizer {
  String sanitize({required String html, required bool allowRemoteImages});

  String toPlainText(String html);
}

class BasicEmailHtmlSanitizer implements EmailHtmlSanitizer {
  const BasicEmailHtmlSanitizer();

  static final _blockedTags = RegExp(
    r'<\s*(script|style|iframe|object|embed|form|input|button|textarea|select|meta|link)'
    r'[\s\S]*?<\s*/\s*\1\s*>|<\s*(script|style|iframe|object|embed|form|input|button|textarea|select|meta|link)[^>]*\/?\s*>',
    caseSensitive: false,
  );
  static final _htmlComments = RegExp(r'<!--[\s\S]*?-->');
  static final _eventAttributes = RegExp(
    r'''\s+on[a-z]+\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)''',
    caseSensitive: false,
  );
  static final _dangerousUrls = RegExp(
    r'''(href|src)\s*=\s*("|\')\s*(javascript:|vbscript:|data:text/html)''',
    caseSensitive: false,
  );
  static final _styleAttribute = RegExp(
    r'''\sstyle\s*=\s*("([^"]*)"|'([^']*)')''',
    caseSensitive: false,
  );
  @override
  String sanitize({required String html, required bool allowRemoteImages}) {
    var sanitized = html
        .replaceAll(_htmlComments, ' ')
        .replaceAll(_blockedTags, ' ')
        .replaceAll(_eventAttributes, '')
        .replaceAllMapped(_styleAttribute, (match) {
          final style = match.group(2) ?? match.group(3) ?? '';
          final safeStyle = _sanitizeStyle(style);
          return safeStyle.isEmpty ? '' : ' style="$safeStyle"';
        });
    sanitized = sanitized.replaceAllMapped(_dangerousUrls, (match) {
      return '${match.group(1)}=${match.group(2)}#blocked';
    });
    return sanitized;
  }

  @override
  String toPlainText(String html) {
    final withoutScripts = html
        .replaceAll(
          RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style[\s\S]*?</style>', caseSensitive: false),
          ' ',
        );
    final withBreaks = withoutScripts
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</\s*(p|div|pre|li|tr|h[1-6])\s*>', caseSensitive: false),
          '\n',
        );
    final text = withBreaks.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return _decodeHtmlEntities(text)
        .replaceAll(RegExp(r'\s+\n'), '\n')
        .replaceAll(RegExp(r'\n\s+'), '\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
  }

  String _sanitizeStyle(String style) {
    final allowed = <String>[];
    for (final declaration in style.split(';')) {
      final separator = declaration.indexOf(':');
      if (separator <= 0) {
        continue;
      }
      final property = declaration.substring(0, separator).trim().toLowerCase();
      final value = declaration.substring(separator + 1).trim();
      if (!_allowedStyleProperties.contains(property)) {
        continue;
      }
      final loweredValue = value.toLowerCase();
      if (loweredValue.contains('expression') ||
          loweredValue.contains('javascript:') ||
          loweredValue.contains('position:fixed') ||
          loweredValue.contains('position:absolute')) {
        continue;
      }
      allowed.add('$property: $value');
    }
    return allowed.join('; ');
  }

  String _decodeHtmlEntities(String value) {
    var decoded = value
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1) ?? '');
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1) ?? '', radix: 16);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    decoded = decoded.replaceAll('&amp;', '&');

    return decoded;
  }
}

const _allowedStyleProperties = {
  'color',
  'background-color',
  'background',
  'font-size',
  'font-weight',
  'font-style',
  'font-family',
  'text-align',
  'text-decoration',
  'line-height',
  'margin',
  'margin-top',
  'margin-bottom',
  'margin-left',
  'margin-right',
  'padding',
  'padding-top',
  'padding-bottom',
  'padding-left',
  'padding-right',
  'border',
  'border-top',
  'border-bottom',
  'border-left',
  'border-right',
  'border-collapse',
  'border-spacing',
  'border-radius',
  'width',
  'min-width',
  'max-width',
  'height',
  'min-height',
  'max-height',
  'display',
  'vertical-align',
  'text-indent',
  'letter-spacing',
  'word-spacing',
};
