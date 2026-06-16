import 'dart:convert';

import 'email_attachment.dart';
import 'email_charset_decoder.dart';
import 'inline_image.dart';
import 'parsed_email_body.dart';

abstract class EmailBodyParser {
  Future<ParsedEmailBody> parse({required String rawMessage});
}

class SimpleEmailBodyParser implements EmailBodyParser {
  const SimpleEmailBodyParser({
    this.charsetDecoder = const BasicEmailCharsetDecoder(),
  });

  final EmailCharsetDecoder charsetDecoder;

  @override
  Future<ParsedEmailBody> parse({required String rawMessage}) async {
    try {
      final normalized = rawMessage.replaceAll('\r\n', '\n');
      final splitIndex = normalized.indexOf('\n\n');
      final headerText = splitIndex == -1
          ? normalized
          : normalized.substring(0, splitIndex);
      final bodyText = splitIndex == -1
          ? ''
          : normalized.substring(splitIndex + 2);
      final headers = MimeHeaders.parse(headerText);
      final rootPart = _parsePart(headers, bodyText);
      final collector = _BodyCollector();
      await _collectParts(rootPart, collector);

      return ParsedEmailBody(
        plainText: collector.plainText,
        html: collector.html,
        inlineImages: collector.inlineImages,
        attachments: collector.attachments,
        charset: collector.charset,
        contentType: collector.contentType ?? headers.contentType.mimeType,
        transferEncoding: collector.transferEncoding,
        hasRemoteImages: _hasRemoteImages(collector.html),
        hasInlineImages: collector.inlineImages.isNotEmpty,
        hasUnsupportedParts: collector.hasUnsupportedParts,
        isEncrypted: headers.contentType.mimeType == 'multipart/encrypted',
        isSigned: headers.contentType.mimeType == 'multipart/signed',
        rawPreview: _rawPreview(rawMessage),
      );
    } on Object catch (error) {
      return ParsedEmailBody(
        parseFailed: true,
        parseError: error.runtimeType.toString(),
        rawPreview: _rawPreview(rawMessage),
      );
    }
  }

  Future<void> _collectParts(_MimePart part, _BodyCollector collector) async {
    final contentType = part.headers.contentType;
    if (contentType.mimeType == 'multipart/encrypted') {
      collector.hasUnsupportedParts = true;
      collector.isEncrypted = true;
      return;
    }
    if (contentType.mimeType == 'multipart/signed') {
      collector.isSigned = true;
    }

    if (part.children.isNotEmpty) {
      if (contentType.mimeType == 'multipart/alternative') {
        await _collectAlternative(part.children, collector);
      } else {
        for (final child in part.children) {
          await _collectParts(child, collector);
        }
      }
      return;
    }

    final disposition = part.headers.disposition;
    final fileName = disposition.fileName ?? contentType.params['name'];
    final mimeType = contentType.mimeType;
    final transferEncoding = part.headers.value('content-transfer-encoding');
    final bodyBytes = decodeTransfer(part.body, transferEncoding);
    final contentId = _cleanAngle(part.headers.value('content-id'));
    final charset = contentType.params['charset'];

    if (mimeType == 'text/plain' || mimeType == 'text/html') {
      final decoded = await charsetDecoder.decode(
        bytes: bodyBytes,
        charset: charset,
      );
      collector.charset ??= charset;
      collector.contentType ??= mimeType;
      collector.transferEncoding ??= transferEncoding;
      if (mimeType == 'text/html') {
        collector.html ??= decoded;
      } else {
        collector.plainText ??= decoded;
      }
      return;
    }

    final isInline = disposition.kind == 'inline' || contentId != null;
    if (fileName != null || disposition.kind == 'attachment' || isInline) {
      final attachment = EmailAttachment(
        id: 'att-${collector.attachments.length + 1}',
        filename: fileName == null ? null : await decodeHeader(fileName),
        mimeType: mimeType,
        size: bodyBytes.length,
        contentId: contentId,
        isInline: isInline,
      );
      collector.attachments.add(attachment);
      if (isInline && contentId != null && mimeType.startsWith('image/')) {
        collector.inlineImages.add(
          InlineImage(
            contentId: contentId,
            mimeType: mimeType,
            filename: attachment.filename,
            size: bodyBytes.length,
            bytes: bodyBytes,
          ),
        );
      }
      return;
    }

    if (mimeType.isNotEmpty && mimeType != 'text/plain') {
      collector.hasUnsupportedParts = true;
    }
  }

  Future<void> _collectAlternative(
    List<_MimePart> parts,
    _BodyCollector collector,
  ) async {
    final htmlParts = <_MimePart>[];
    final plainParts = <_MimePart>[];
    for (final part in parts) {
      final mimeType = part.headers.contentType.mimeType;
      if (mimeType == 'text/html') {
        htmlParts.add(part);
      } else if (mimeType == 'text/plain') {
        plainParts.add(part);
      } else if (mimeType.startsWith('multipart/')) {
        htmlParts.add(part);
      }
    }

    final tempCollector = _BodyCollector();
    for (final part in htmlParts) {
      await _collectParts(part, tempCollector);
    }

    if (tempCollector.html != null && tempCollector.html!.trim().isNotEmpty) {
      collector.html = tempCollector.html;
      collector.charset ??= tempCollector.charset;
      collector.contentType ??= tempCollector.contentType;
      collector.transferEncoding ??= tempCollector.transferEncoding;
      collector.inlineImages.addAll(tempCollector.inlineImages);
      collector.attachments.addAll(tempCollector.attachments);
    }

    for (final part in plainParts) {
      await _collectParts(part, collector);
    }
  }

  _MimePart _parsePart(MimeHeaders headers, String body) {
    final contentType = headers.contentType;
    if (!contentType.mimeType.startsWith('multipart/')) {
      return _MimePart(headers: headers, body: body, children: const []);
    }

    final boundary = contentType.params['boundary'];
    if (boundary == null || boundary.isEmpty) {
      return _MimePart(headers: headers, body: body, children: const []);
    }

    final children = <_MimePart>[];
    final boundaryLine = '--$boundary';
    final endBoundaryLine = '--$boundary--';
    final lines = body.split('\n');
    final current = StringBuffer();
    var inPart = false;

    void addCurrent() {
      final partText = current.toString();
      current.clear();
      final splitIndex = partText.indexOf('\n\n');
      if (splitIndex == -1) {
        return;
      }
      final partHeaders = MimeHeaders.parse(partText.substring(0, splitIndex));
      final partBody = partText.substring(splitIndex + 2);
      children.add(_parsePart(partHeaders, partBody));
    }

    for (final line in lines) {
      final trimmed = line.trimRight();
      if (trimmed == boundaryLine || trimmed == endBoundaryLine) {
        if (inPart) {
          addCurrent();
        }
        if (trimmed == endBoundaryLine) {
          inPart = false;
          break;
        }
        inPart = true;
        continue;
      }
      if (inPart) {
        current.writeln(line);
      }
    }
    if (inPart && current.isNotEmpty) {
      addCurrent();
    }

    return _MimePart(headers: headers, body: '', children: children);
  }

  static Future<String> decodeHeader(String? value) async {
    if (value == null || value.isEmpty) {
      return '';
    }

    final decoder = const BasicEmailCharsetDecoder();
    final unfolded = value.replaceAll(RegExp(r'\r?\n[ \t]+'), ' ');
    final pattern = RegExp(r'=\?([^?]+)\?([bBqQ])\?([^?]*)\?=');
    final buffer = StringBuffer();
    var lastEnd = 0;
    var previousWasEncodedWord = false;
    for (final match in pattern.allMatches(unfolded)) {
      final separator = unfolded.substring(lastEnd, match.start);
      if (!previousWasEncodedWord || separator.trim().isNotEmpty) {
        buffer.write(separator);
      }
      final charset = match.group(1) ?? 'utf-8';
      final encoding = match.group(2)?.toLowerCase();
      final encoded = match.group(3) ?? '';
      final bytes = encoding == 'b'
          ? safeBase64Decode(encoded)
          : decodeQuotedPrintableBytes(encoded.replaceAll('_', ' '));
      buffer.write(await decoder.decode(bytes: bytes, charset: charset));
      lastEnd = match.end;
      previousWasEncodedWord = true;
    }
    buffer.write(unfolded.substring(lastEnd));
    return buffer.toString();
  }

  /// Decodes and normalizes an address header for display.
  ///
  /// This keeps the mailbox address visible while decoding the display name.
  /// It intentionally avoids logging or returning raw parser failures because
  /// address headers may contain private account details.
  static Future<String> decodeAddressHeader(String? value) async {
    final decoded = (await decodeHeader(value)).trim();
    if (decoded.isEmpty) {
      return '';
    }

    final match = RegExp(r'^\s*"?([^"<]*)"?\s*<([^>]+)>').firstMatch(decoded);
    if (match == null) {
      return decoded.replaceAll(RegExp(r'^"|"$'), '').trim();
    }

    final name = (match.group(1) ?? '')
        .replaceAll(r'\"', '"')
        .replaceAll(RegExp(r'^"|"$'), '')
        .trim();
    final email = (match.group(2) ?? '').trim();
    if (name.isEmpty) {
      return email;
    }
    return '$name <$email>';
  }

  static List<int> decodeTransfer(String body, String? encoding) {
    final normalized = body.trimRight();
    return switch ((encoding ?? '').toLowerCase().trim()) {
      'base64' => safeBase64Decode(normalized.replaceAll(RegExp(r'\s+'), '')),
      'quoted-printable' => decodeQuotedPrintableBytes(normalized),
      _ => latin1.encode(normalized),
    };
  }

  static List<int> safeBase64Decode(String value) {
    try {
      final padding = value.length % 4;
      final padded = padding == 0
          ? value
          : value.padRight(value.length + 4 - padding, '=');
      return base64.decode(padded);
    } on FormatException {
      return latin1.encode(value);
    }
  }

  static List<int> decodeQuotedPrintableBytes(String value) {
    final output = <int>[];
    final text = value.replaceAll(RegExp(r'=\r?\n'), '');
    for (var index = 0; index < text.length; index++) {
      final char = text.codeUnitAt(index);
      if (char == 0x3d && index + 2 < text.length) {
        final hex = text.substring(index + 1, index + 3);
        final byte = int.tryParse(hex, radix: 16);
        if (byte != null) {
          output.add(byte);
          index += 2;
          continue;
        }
      }
      output.add(char);
    }
    return output;
  }

  static bool _hasRemoteImages(String? html) {
    if (html == null) {
      return false;
    }
    return RegExp(
      r'''<img\b[^>]*\bsrc\s*=\s*("|\')https?:\/\/''',
      caseSensitive: false,
    ).hasMatch(html);
  }

  static String? _cleanAngle(String? value) {
    if (value == null) {
      return null;
    }
    return value.trim().replaceAll(RegExp(r'^<|>$'), '');
  }

  static String _rawPreview(String rawMessage) {
    final normalized = rawMessage.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized.length <= 1200
        ? normalized
        : '${normalized.substring(0, 1200)}...';
  }
}

class MimeHeaders {
  const MimeHeaders(this._values);

  final Map<String, List<String>> _values;

  String? value(String name) => _values[name.toLowerCase()]?.join('\n');

  MimeContentType get contentType =>
      MimeContentType.parse(value('content-type'));

  MimeDisposition get disposition =>
      MimeDisposition.parse(value('content-disposition'));

  static MimeHeaders parse(String text) {
    final headers = <String, List<String>>{};
    String? currentName;
    final currentValue = StringBuffer();

    void flush() {
      final name = currentName;
      if (name == null) {
        return;
      }
      headers
          .putIfAbsent(name.toLowerCase(), () => <String>[])
          .add(currentValue.toString());
      currentValue.clear();
    }

    for (final line in text.split('\n')) {
      if ((line.startsWith(' ') || line.startsWith('\t')) &&
          currentName != null) {
        currentValue.write('\n$line');
        continue;
      }
      flush();
      final colon = line.indexOf(':');
      if (colon <= 0) {
        currentName = null;
        continue;
      }
      currentName = line.substring(0, colon);
      currentValue.write(line.substring(colon + 1).trimLeft());
    }
    flush();
    return MimeHeaders(headers);
  }
}

class MimeContentType {
  const MimeContentType({required this.mimeType, required this.params});

  final String mimeType;
  final Map<String, String> params;

  static MimeContentType parse(String? value) {
    final parsed = parseHeaderValue(value);
    return MimeContentType(
      mimeType: (parsed.$1.isEmpty ? 'text/plain' : parsed.$1).toLowerCase(),
      params: parsed.$2,
    );
  }
}

class MimeDisposition {
  const MimeDisposition({required this.kind, this.fileName});

  final String kind;
  final String? fileName;

  static MimeDisposition parse(String? value) {
    final parsed = parseHeaderValue(value);
    return MimeDisposition(
      kind: parsed.$1.toLowerCase(),
      fileName: parsed.$2['filename'],
    );
  }
}

(String, Map<String, String>) parseHeaderValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ('', const <String, String>{});
  }

  final parts = value.split(';');
  final main = parts.first.trim();
  final params = <String, String>{};
  for (final part in parts.skip(1)) {
    final separator = part.indexOf('=');
    if (separator <= 0) {
      continue;
    }
    final key = part.substring(0, separator).trim().toLowerCase();
    final rawValue = part.substring(separator + 1).trim();
    params[key] = rawValue.replaceAll(RegExp(r'^"|"$'), '');
  }
  return (main, params);
}

class _MimePart {
  const _MimePart({
    required this.headers,
    required this.body,
    required this.children,
  });

  final MimeHeaders headers;
  final String body;
  final List<_MimePart> children;
}

class _BodyCollector {
  String? plainText;
  String? html;
  String? charset;
  String? contentType;
  String? transferEncoding;
  bool hasUnsupportedParts = false;
  bool isEncrypted = false;
  bool isSigned = false;
  final attachments = <EmailAttachment>[];
  final inlineImages = <InlineImage>[];
}
