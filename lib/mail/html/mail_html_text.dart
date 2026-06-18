class MailHtmlText {
  const MailHtmlText._();

  static String toReadableText(String html) {
    final withoutUnsafeBlocks = html
        .replaceAll(
          RegExp(
            r'<(script|style|head|svg)\b[^>]*>.*?</\1>',
            caseSensitive: false,
            dotAll: true,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(r'<!--.*?-->', caseSensitive: false, dotAll: true),
          ' ',
        );

    final withImageAltText = withoutUnsafeBlocks.replaceAllMapped(
      RegExp(r'<img\b[^>]*>', caseSensitive: false),
      (match) {
        final alt = _attribute(match.group(0) ?? '', 'alt');
        return alt == null || alt.trim().isEmpty ? ' ' : ' $alt ';
      },
    );

    final withLineBreaks = withImageAltText
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(
            r'</?(p|div|section|article|header|footer|table|thead|tbody|tr|td|th|ul|ol|li|h[1-6]|blockquote|a|button)\b[^>]*>',
            caseSensitive: false,
          ),
          '\n',
        );

    final withoutTags = withLineBreaks.replaceAll(
      RegExp(r'<[^>]+>', caseSensitive: false),
      ' ',
    );
    final decoded = _decodeEntities(withoutTags);
    return _normalizeWhitespace(decoded);
  }

  static String? _attribute(String tag, String name) {
    final pattern = RegExp(
      '$name\\s*=\\s*([\\\'"])(.*?)\\1',
      caseSensitive: false,
      dotAll: true,
    );
    return pattern.firstMatch(tag)?.group(2);
  }

  static String _decodeEntities(String value) {
    return value.replaceAllMapped(RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);'), (
      match,
    ) {
      final entity = match.group(1)!;
      if (entity.startsWith('#x') || entity.startsWith('#X')) {
        final codePoint = int.tryParse(entity.substring(2), radix: 16);
        return codePoint == null
            ? match.group(0)!
            : String.fromCharCode(codePoint);
      }
      if (entity.startsWith('#')) {
        final codePoint = int.tryParse(entity.substring(1));
        return codePoint == null
            ? match.group(0)!
            : String.fromCharCode(codePoint);
      }
      return switch (entity) {
        'amp' => '&',
        'apos' => "'",
        'gt' => '>',
        'lt' => '<',
        'nbsp' => ' ',
        'quot' => '"',
        _ => match.group(0)!,
      };
    });
  }

  static String _normalizeWhitespace(String value) {
    return value
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t\r\f]+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .join('\n\n')
        .trim();
  }
}
