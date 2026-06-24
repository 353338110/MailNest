import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import 'email_body_fallback.dart';
import 'email_html_sanitizer.dart';
import 'email_render_options.dart';
import 'parsed_email_body.dart';

abstract class EmailBodyRenderer {
  Widget build(
    BuildContext context, {
    required ParsedEmailBody body,
    required EmailRenderOptions options,
  });
}

class BasicEmailBodyRenderer implements EmailBodyRenderer {
  const BasicEmailBodyRenderer({
    this.sanitizer = const BasicEmailHtmlSanitizer(),
  });

  final EmailHtmlSanitizer sanitizer;

  @override
  Widget build(
    BuildContext context, {
    required ParsedEmailBody body,
    required EmailRenderOptions options,
  }) {
    final l10n = AppLocalizations.of(context);

    if (body.isEncrypted) {
      return EmailBodyFallbackView(body: body);
    }
    if (body.parseFailed) {
      return EmailBodyFallbackView(body: body, reason: body.parseError);
    }

    final plainText = body.plainText;
    if (options.preferPlainText && plainText?.trim().isNotEmpty == true) {
      return _TextBody(text: plainText!, selectable: options.enableSelection);
    }

    final html = body.html;
    if (html?.trim().isNotEmpty == true) {
      final sanitized = sanitizer.sanitize(
        html: html!,
        allowRemoteImages: options.allowRemoteImages,
      );
      final widgets = _HtmlBodyBuilder(
        html: sanitized,
        body: body,
        options: options,
      ).build(context);
      if (widgets.isNotEmpty) {
        final canvasWidth = _EmailHtmlCanvasWidth.detect(sanitized);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (body.hasRemoteImages && !options.allowRemoteImages)
              _InlineNotice(
                text: l10n.remoteImagesBlocked,
                actionLabel: l10n.loadRemoteImages,
                onAction: options.onLoadRemoteImages,
              ),
            if (body.isSigned) _InlineNotice(text: l10n.signedMessageNotice),
            _EmailHtmlCanvas(width: canvasWidth, children: widgets),
          ],
        );
      }
    }

    if (plainText?.trim().isNotEmpty == true) {
      return _TextBody(text: plainText!, selectable: options.enableSelection);
    }

    return EmailBodyFallbackView(body: body);
  }
}

class _EmailHtmlCanvas extends StatelessWidget {
  const _EmailHtmlCanvas({required this.width, required this.children});

  final double? width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final canvasWidth = width;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    if (canvasWidth == null) {
      return content;
    }

    final canvas = MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(width: canvasWidth, child: content),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (!availableWidth.isFinite || availableWidth >= canvasWidth) {
          return Align(alignment: Alignment.topCenter, child: canvas);
        }

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: canvas,
        );
      },
    );
  }
}

class _EmailHtmlCanvasWidth {
  const _EmailHtmlCanvasWidth._();

  static double? detect(String html) {
    final widths = <double>[
      ..._styleWidths(html),
      ..._attributeWidths(html),
    ].where(_isUsefulEmailWidth).toList(growable: false);
    if (widths.isEmpty) {
      return null;
    }
    return widths.reduce((a, b) => a > b ? a : b);
  }

  static Iterable<double> _styleWidths(String html) sync* {
    final matches = RegExp(
      r'(?:max-)?width\s*:\s*([0-9]+(?:\.[0-9]+)?)px',
      caseSensitive: false,
    ).allMatches(html);
    for (final match in matches) {
      final width = double.tryParse(match.group(1) ?? '');
      if (width != null) {
        yield width;
      }
    }
  }

  static Iterable<double> _attributeWidths(String html) sync* {
    final matches = RegExp(
      r'''\bwidth\s*=\s*["']?([0-9]+(?:\.[0-9]+)?)''',
      caseSensitive: false,
    ).allMatches(html);
    for (final match in matches) {
      final width = double.tryParse(match.group(1) ?? '');
      if (width != null) {
        yield width;
      }
    }
  }

  static bool _isUsefulEmailWidth(double width) {
    return width >= 320 && width <= 900;
  }
}

class _HtmlBodyBuilder {
  const _HtmlBodyBuilder({
    required this.html,
    required this.body,
    required this.options,
  });

  final String html;
  final ParsedEmailBody body;
  final EmailRenderOptions options;

  List<Widget> build(BuildContext context) {
    final widgets = <Widget>[];
    final tokens = RegExp(
      r'(<img\b[^>]*>|<a\b[^>]*>|</a>|<br\s*/?>|</?(body|center|p|div|pre|blockquote|h[1-6]|li|tr|table|ul|ol|strong|b|em|i|u|span|td|th|tbody|thead)[^>]*>)',
      caseSensitive: false,
    );
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyLarge?.copyWith(
      height: 1.5,
      color: theme.colorScheme.onSurfaceVariant,
    );
    var cursor = 0;
    final textBuffer = StringBuffer();
    final styleStack = <TextStyle>[];
    final blockStack = <_HtmlBlockStyle>[];
    final linkBlockStack = <bool>[];
    final linkUrlStack = <String?>[];
    List<Widget>? currentCellWidgets;
    List<_HtmlTableCell>? currentRowCells;
    _HtmlBlockStyle? currentCellStyle;
    var inListItem = false;

    void addRenderedBlock(Widget block) {
      final cellWidgets = currentCellWidgets;
      if (cellWidgets != null) {
        cellWidgets.add(block);
        return;
      }
      widgets.add(block);
    }

    void flushText({TextStyle? style}) {
      final text = _normalizeText(textBuffer.toString());
      textBuffer.clear();
      if (text.isEmpty) {
        return;
      }
      var effectiveStyle = defaultStyle;
      for (final stackedStyle in styleStack) {
        effectiveStyle = effectiveStyle?.merge(stackedStyle) ?? stackedStyle;
      }
      if (style != null) {
        effectiveStyle = effectiveStyle?.merge(style) ?? style;
      }
      final blockStyle = _mergedBlockStyle(blockStack);
      final linkUrl = _currentLinkUrl(linkUrlStack);
      final textWidget = linkUrl != null
          ? Text(text, style: effectiveStyle, textAlign: blockStyle.textAlign)
          : options.enableSelection
          ? SelectableText(
              text,
              style: effectiveStyle,
              textAlign: blockStyle.textAlign,
            )
          : Text(text, style: effectiveStyle, textAlign: blockStyle.textAlign);
      addRenderedBlock(
        _StyledHtmlBlock(
          style: blockStyle,
          linkUrl: linkUrl,
          child: textWidget,
        ),
      );
    }

    void closeCurrentCell() {
      flushText();
      final cellWidgets = currentCellWidgets;
      if (cellWidgets == null) {
        return;
      }
      currentRowCells?.add(
        _HtmlTableCell(
          widgets: List<Widget>.from(cellWidgets),
          style: currentCellStyle ?? const _HtmlBlockStyle(),
        ),
      );
      currentCellWidgets = null;
      currentCellStyle = null;
    }

    void closeCurrentRow() {
      closeCurrentCell();
      final cells = currentRowCells;
      if (cells == null || cells.isEmpty) {
        currentRowCells = null;
        return;
      }
      widgets.add(
        _StyledHtmlBlock(
          style: _mergedBlockStyle(blockStack),
          child: _HtmlTableRow(cells: List<_HtmlTableCell>.from(cells)),
        ),
      );
      currentRowCells = null;
    }

    for (final match in tokens.allMatches(html)) {
      final beforeText = _stripTags(html.substring(cursor, match.start));
      textBuffer.write(beforeText);
      final token = match.group(0) ?? '';
      final lower = token.toLowerCase();

      if (lower.startsWith('<img')) {
        flushText();
        addRenderedBlock(
          _StyledHtmlBlock(
            style: _mergedBlockStyle(blockStack),
            linkUrl: _currentLinkUrl(linkUrlStack),
            child: _buildImage(context, token),
          ),
        );
      } else if (lower.startsWith('<a')) {
        final isButton = _looksLikeButtonLink(token);
        flushText();
        if (isButton) {
          blockStack.add(_blockStyleFromTag(token));
        }
        linkBlockStack.add(isButton);
        linkUrlStack.add(_safeLinkUrl(_attribute(token, 'href')));
        styleStack.add(_linkTextStyle(token, isButton: isButton));
      } else if (lower == '</a>') {
        flushText();
        if (styleStack.isNotEmpty) styleStack.removeLast();
        if (linkUrlStack.isNotEmpty) linkUrlStack.removeLast();
        final hadBlock = linkBlockStack.isNotEmpty
            ? linkBlockStack.removeLast()
            : false;
        if (hadBlock && blockStack.isNotEmpty) {
          blockStack.removeLast();
        }
      } else if (lower.startsWith('<br')) {
        textBuffer.write('\n');
      } else if (lower.startsWith('<strong') || lower.startsWith('<b')) {
        styleStack.add(const TextStyle(fontWeight: FontWeight.bold));
      } else if (lower.startsWith('</strong') || lower.startsWith('</b')) {
        if (styleStack.isNotEmpty) styleStack.removeLast();
      } else if (lower.startsWith('<em') || lower.startsWith('<i')) {
        styleStack.add(const TextStyle(fontStyle: FontStyle.italic));
      } else if (lower.startsWith('</em') || lower.startsWith('</i')) {
        if (styleStack.isNotEmpty) styleStack.removeLast();
      } else if (lower.startsWith('<u')) {
        styleStack.add(const TextStyle(decoration: TextDecoration.underline));
      } else if (lower.startsWith('</u')) {
        if (styleStack.isNotEmpty) styleStack.removeLast();
      } else if (lower.startsWith('<h')) {
        flushText();
        final level = int.tryParse(lower.substring(2, 3)) ?? 1;
        styleStack.add(_headingStyle(theme, level));
      } else if (lower.startsWith('</h')) {
        flushText();
        if (styleStack.isNotEmpty) styleStack.removeLast();
      } else if (lower.startsWith('<li')) {
        inListItem = true;
        textBuffer.write('• ');
      } else if (lower.startsWith('</li')) {
        inListItem = false;
        flushText();
      } else if (lower.startsWith('<blockquote')) {
        flushText();
        styleStack.add(
          TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        );
      } else if (lower.startsWith('</blockquote')) {
        flushText();
        if (styleStack.isNotEmpty) styleStack.removeLast();
      } else if (lower.startsWith('<tr')) {
        flushText();
        closeCurrentRow();
        currentRowCells = <_HtmlTableCell>[];
      } else if (lower.startsWith('</tr')) {
        closeCurrentRow();
      } else if (lower.startsWith('<td') || lower.startsWith('<th')) {
        closeCurrentCell();
        currentRowCells ??= <_HtmlTableCell>[];
        currentCellWidgets = <Widget>[];
        currentCellStyle = _blockStyleFromTag(token);
        blockStack.add(currentCellStyle!);
      } else if (lower.startsWith('</td') || lower.startsWith('</th')) {
        if (blockStack.isNotEmpty) {
          blockStack.removeLast();
        }
        closeCurrentCell();
      } else if (_isBlockStart(lower)) {
        flushText();
        blockStack.add(_blockStyleFromTag(token));
      } else if (_isBlockEnd(lower)) {
        if (!inListItem) {
          flushText();
        }
        if (blockStack.isNotEmpty &&
            _isBlockEnd(lower) &&
            !_isTableSectionEnd(lower)) {
          blockStack.removeLast();
        }
      }
      cursor = match.end;
    }
    textBuffer.write(_stripTags(html.substring(cursor)));
    flushText();
    closeCurrentRow();
    return widgets;
  }

  _HtmlBlockStyle _mergedBlockStyle(List<_HtmlBlockStyle> stack) {
    var merged = const _HtmlBlockStyle();
    for (final style in stack) {
      merged = merged.merge(style);
    }
    return merged;
  }

  String? _currentLinkUrl(List<String?> urls) {
    for (final url in urls.reversed) {
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }

  TextStyle _headingStyle(ThemeData theme, int level) {
    return switch (level) {
      1 =>
        theme.textTheme.headlineLarge ??
            const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      2 =>
        theme.textTheme.headlineMedium ??
            const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      3 =>
        theme.textTheme.headlineSmall ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      4 =>
        theme.textTheme.titleLarge ??
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      5 =>
        theme.textTheme.titleMedium ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      _ =>
        theme.textTheme.titleSmall ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    };
  }

  Widget _buildImage(BuildContext context, String tag) {
    final src = _attribute(tag, 'src');
    if (src == null || src.isEmpty) {
      return const SizedBox.shrink();
    }

    final image = _imageForSource(src);
    final requestedSize = _imageSizeFromTag(tag);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: _SizedEmailImage(
        requestedSize: requestedSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image ?? _ImagePlaceholder(source: src),
        ),
      ),
    );
  }

  Widget? _imageForSource(String src) {
    if (src.startsWith('cid:')) {
      final contentId = src.substring(4).replaceAll(RegExp(r'^<|>$'), '');
      final inlineImage = body.inlineImages.firstWhereOrNull(
        (image) => image.contentId == contentId,
      );
      final bytes = inlineImage?.bytes;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      return Image.memory(
        Uint8List.fromList(bytes),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _ImagePlaceholder(source: src),
      );
    }

    if (src.startsWith('data:image/')) {
      final comma = src.indexOf(',');
      if (comma > 0 && src.substring(0, comma).contains(';base64')) {
        try {
          return Image.memory(
            base64Decode(src.substring(comma + 1)),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _ImagePlaceholder(source: src),
          );
        } on FormatException {
          return null;
        }
      }
    }

    if (src.startsWith('http://') || src.startsWith('https://')) {
      if (!options.allowRemoteImages) {
        return null;
      }
      return _RetryableRemoteImage(source: src);
    }
    return null;
  }

  String? _attribute(String tag, String name) {
    final escapedName = RegExp.escape(name);
    final match = RegExp(
      '''$escapedName\\s*=\\s*("([^"]*)"|'([^']*)'|([^\\s>]+))''',
      caseSensitive: false,
    ).firstMatch(tag);
    return match?.group(2) ?? match?.group(3) ?? match?.group(4);
  }

  String? _safeLinkUrl(String? value) {
    final url = value?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(_decodeHtmlEntities(url));
    if (parsed == null) {
      return null;
    }
    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      return parsed.toString();
    }
    if (parsed.scheme == 'mailto') {
      return parsed.toString();
    }
    return null;
  }

  Size? _imageSizeFromTag(String tag) {
    final width = _dimensionFromAttribute(_attribute(tag, 'width'));
    final height = _dimensionFromAttribute(_attribute(tag, 'height'));
    final style = _attribute(tag, 'style');
    final styleWidth = _dimensionFromStyle(style, 'width');
    final styleHeight = _dimensionFromStyle(style, 'height');
    final resolvedWidth = styleWidth ?? width;
    final resolvedHeight = styleHeight ?? height;
    if (resolvedWidth == null && resolvedHeight == null) {
      return null;
    }
    return Size(resolvedWidth ?? double.nan, resolvedHeight ?? double.nan);
  }

  double? _dimensionFromStyle(String? style, String property) {
    if (style == null || style.isEmpty) {
      return null;
    }
    final match = RegExp(
      '$property\\s*:\\s*([^;]+)',
      caseSensitive: false,
    ).firstMatch(style);
    return _dimensionFromAttribute(match?.group(1));
  }

  double? _dimensionFromAttribute(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty || trimmed == 'auto' || trimmed.endsWith('%')) {
      return null;
    }
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(trimmed);
    return double.tryParse(match?.group(1) ?? '');
  }

  bool _isBlockEnd(String tag) {
    return tag.startsWith('</p') ||
        tag.startsWith('</body') ||
        tag.startsWith('</center') ||
        tag.startsWith('</div') ||
        tag.startsWith('</pre') ||
        tag.startsWith('</blockquote') ||
        tag.startsWith('</h') ||
        tag.startsWith('</table');
  }

  bool _isBlockStart(String tag) {
    return tag.startsWith('<body') ||
        tag.startsWith('<center') ||
        tag.startsWith('<p') ||
        tag.startsWith('<div') ||
        tag.startsWith('<pre') ||
        tag.startsWith('<table');
  }

  bool _isTableSectionEnd(String tag) {
    return tag.startsWith('</tbody') || tag.startsWith('</thead');
  }

  _HtmlBlockStyle _blockStyleFromTag(String tag) {
    final style = _attribute(tag, 'style');
    final align = _attribute(tag, 'align');
    final isTableCell =
        tag.toLowerCase().startsWith('<td') ||
        tag.toLowerCase().startsWith('<th');
    final textAlign =
        _textAlignFromValue(_styleValue(style, 'text-align')) ??
        _textAlignFromValue(align) ??
        (isTableCell ? TextAlign.left : null) ??
        (tag.toLowerCase().startsWith('<center') ? TextAlign.center : null);
    final width = _safeBlockWidth(
      _dimensionFromStyle(style, 'max-width') ??
          _dimensionFromStyle(style, 'width') ??
          _dimensionFromAttribute(_attribute(tag, 'width')),
    );
    final padding = _edgeInsetsFromStyle(style, 'padding');
    final margin = _edgeInsetsFromStyle(style, 'margin');
    final background =
        _colorFromStyle(style, 'background-color') ??
        _colorFromStyle(style, 'background');
    final borderRadius = _dimensionFromStyle(style, 'border-radius');

    return _HtmlBlockStyle(
      textAlign: textAlign,
      width: width,
      padding: padding,
      margin: margin,
      backgroundColor: background,
      borderRadius: borderRadius,
    );
  }

  bool _looksLikeButtonLink(String tag) {
    final style = _attribute(tag, 'style');
    if (style == null || style.isEmpty) {
      return false;
    }
    return _styleValue(style, 'background-color') != null ||
        _styleValue(style, 'background') != null ||
        _styleValue(style, 'border-radius') != null ||
        _styleValue(style, 'padding') != null;
  }

  TextStyle _linkTextStyle(String tag, {required bool isButton}) {
    final style = _attribute(tag, 'style');
    return TextStyle(
      color: _colorFromStyle(style, 'color'),
      decoration: isButton ? null : TextDecoration.underline,
      fontWeight: _fontWeightFromStyle(style),
    );
  }

  FontWeight? _fontWeightFromStyle(String? style) {
    final value = _styleValue(style, 'font-weight')?.toLowerCase();
    if (value == null) {
      return null;
    }
    if (value == 'bold') {
      return FontWeight.bold;
    }
    final weight = int.tryParse(value);
    if (weight == null) {
      return null;
    }
    if (weight >= 700) {
      return FontWeight.bold;
    }
    if (weight >= 500) {
      return FontWeight.w600;
    }
    return FontWeight.normal;
  }

  double? _safeBlockWidth(double? width) {
    if (width == null || width >= 96) {
      return width;
    }
    // Some email templates use tiny table cells for tracking pixels or spacer
    // columns. Applying that width to text content makes normal copy render
    // vertically, so narrow block widths are ignored for Flutter text layout.
    return null;
  }

  TextAlign? _textAlignFromValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'center' => TextAlign.center,
      'left' => TextAlign.left,
      'start' => TextAlign.start,
      'right' => TextAlign.right,
      'end' => TextAlign.end,
      'justify' => TextAlign.justify,
      _ => null,
    };
  }

  EdgeInsets? _edgeInsetsFromStyle(String? style, String property) {
    final value = _styleValue(style, property);
    if (value == null) {
      return null;
    }
    final parts = value
        .split(RegExp(r'\s+'))
        .map(_dimensionFromAttribute)
        .whereType<double>()
        .toList(growable: false);
    if (parts.isEmpty) {
      return null;
    }
    if (parts.length == 1) {
      return EdgeInsets.all(parts[0]);
    }
    if (parts.length == 2) {
      return EdgeInsets.symmetric(vertical: parts[0], horizontal: parts[1]);
    }
    if (parts.length == 3) {
      return EdgeInsets.fromLTRB(parts[1], parts[0], parts[1], parts[2]);
    }
    return EdgeInsets.fromLTRB(parts[3], parts[0], parts[1], parts[2]);
  }

  Color? _colorFromStyle(String? style, String property) {
    final value = _styleValue(style, property);
    if (value == null) {
      return null;
    }
    final hex = RegExp(r'#([0-9a-fA-F]{6})').firstMatch(value)?.group(1);
    if (hex != null) {
      return Color(int.parse('ff$hex', radix: 16));
    }
    return null;
  }

  String? _styleValue(String? style, String property) {
    if (style == null || style.isEmpty) {
      return null;
    }
    final match = RegExp(
      '$property\\s*:\\s*([^;]+)',
      caseSensitive: false,
    ).firstMatch(style);
    return match?.group(1)?.trim();
  }

  String _stripTags(String value) {
    return _decodeHtmlEntities(value.replaceAll(RegExp(r'<[^>]+>'), ' '));
  }

  String _normalizeText(String value) {
    return value
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
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

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) {
        return value;
      }
    }
    return null;
  }
}

class _HtmlBlockStyle {
  const _HtmlBlockStyle({
    this.textAlign,
    this.width,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
  });

  final TextAlign? textAlign;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;

  bool get isEmpty =>
      textAlign == null &&
      width == null &&
      padding == null &&
      margin == null &&
      backgroundColor == null &&
      borderRadius == null;

  _HtmlBlockStyle merge(_HtmlBlockStyle other) {
    return _HtmlBlockStyle(
      textAlign: other.textAlign ?? textAlign,
      width: other.width ?? width,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
    );
  }
}

class _StyledHtmlBlock extends StatelessWidget {
  const _StyledHtmlBlock({
    required this.style,
    required this.child,
    this.linkUrl,
  });

  final _HtmlBlockStyle style;
  final Widget child;
  final String? linkUrl;

  @override
  Widget build(BuildContext context) {
    if (style.isEmpty) {
      final linkedChild = _LinkedHtmlContent(linkUrl: linkUrl, child: child);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.small),
        child: linkUrl == null
            ? linkedChild
            : Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                heightFactor: 1,
                child: linkedChild,
              ),
      );
    }

    final alignment = switch (style.textAlign) {
      TextAlign.center => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };
    final content = Container(
      width: style.width,
      margin: style.margin ?? const EdgeInsets.only(bottom: AppSpacing.small),
      padding: style.padding,
      decoration: style.backgroundColor == null
          ? null
          : BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(style.borderRadius ?? 0),
            ),
      child: child,
    );

    return Align(
      alignment: alignment,
      child: _LinkedHtmlContent(linkUrl: linkUrl, child: content),
    );
  }
}

class _LinkedHtmlContent extends StatelessWidget {
  const _LinkedHtmlContent({required this.linkUrl, required this.child});

  final String? linkUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final url = linkUrl;
    if (url == null || url.isEmpty) {
      return child;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: () => _openUrl(url), child: child),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // Link activation should never break reading the email body.
    }
  }
}

class _HtmlTableCell {
  const _HtmlTableCell({required this.widgets, required this.style});

  final List<Widget> widgets;
  final _HtmlBlockStyle style;
}

class _HtmlTableRow extends StatelessWidget {
  const _HtmlTableRow({required this.cells});

  final List<_HtmlTableCell> cells;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < cells.length; index++) ...[
            Expanded(child: _HtmlTableCellView(cell: cells[index])),
            if (index != cells.length - 1)
              const SizedBox(width: AppSpacing.medium),
          ],
        ],
      ),
    );
  }
}

class _HtmlTableCellView extends StatelessWidget {
  const _HtmlTableCellView({required this.cell});

  final _HtmlTableCell cell;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (cell.style.textAlign) {
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.right || TextAlign.end => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };
    return Column(crossAxisAlignment: alignment, children: cell.widgets);
  }
}

class _SizedEmailImage extends StatelessWidget {
  const _SizedEmailImage({required this.requestedSize, required this.child});

  final Size? requestedSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;
        final requestedWidth = requestedSize?.width;
        final requestedHeight = requestedSize?.height;
        final hasWidth = requestedWidth != null && requestedWidth.isFinite;
        final hasHeight = requestedHeight != null && requestedHeight.isFinite;

        final constrainedWidth = hasWidth
            ? requestedWidth.clamp(1.0, maxWidth).toDouble()
            : null;
        final scale = hasWidth && requestedWidth > 0 && constrainedWidth != null
            ? constrainedWidth / requestedWidth
            : 1.0;
        final constrainedHeight = hasHeight
            ? (requestedHeight * scale).clamp(1.0, double.infinity).toDouble()
            : null;

        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(
              width: constrainedWidth,
              height: constrainedHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _RetryableRemoteImage extends StatefulWidget {
  const _RetryableRemoteImage({required this.source});

  final String source;

  @override
  State<_RetryableRemoteImage> createState() => _RetryableRemoteImageState();
}

class _RetryableRemoteImageState extends State<_RetryableRemoteImage> {
  int _attempt = 0;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.source,
      key: ValueKey('${widget.source}:$_attempt'),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return _ImagePlaceholder(
          source: widget.source,
          onRetry: () => setState(() => _attempt += 1),
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.source, this.onRetry});

  final String source;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            const Icon(Icons.image_not_supported_outlined),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                source.startsWith('http')
                    ? AppLocalizations.of(context).remoteImagesBlocked
                    : AppLocalizations.of(context).emptyMessageBody,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppSpacing.small),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextBody extends StatelessWidget {
  const _TextBody({required this.text, required this.selectable});

  final String text;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5);
    if (selectable) {
      return SelectableText(text, style: style);
    }
    return Text(text, style: style);
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              const Icon(Icons.privacy_tip_outlined),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(text),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
        ),
      ),
    );
  }
}
