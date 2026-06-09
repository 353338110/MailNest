import 'dart:convert';

import 'package:intl/intl.dart';

import '../models/mail_detail.dart';
import '../models/mail_header.dart';

class ParsedMimeMessage {
  const ParsedMimeMessage({
    required this.header,
    required this.body,
    required this.isHtml,
    required this.attachments,
    required this.rawHeaders,
  });

  final MailHeader header;
  final String body;
  final bool isHtml;
  final List<MailAttachmentInfo> attachments;
  final String rawHeaders;
}

class MimeParser {
  const MimeParser();

  ParsedMimeMessage parse({
    required String rawMessage,
    required String uid,
    required String folderId,
  }) {
    final normalized = rawMessage.replaceAll('\r\n', '\n');
    final splitIndex = normalized.indexOf('\n\n');
    final headerText = splitIndex == -1
        ? normalized
        : normalized.substring(0, splitIndex);
    final bodyText = splitIndex == -1
        ? ''
        : normalized.substring(splitIndex + 2);
    final headers = _parseHeaders(headerText);
    final part = _parsePart(headers, bodyText);
    final bodies = <_BodyCandidate>[];
    final attachments = <MailAttachmentInfo>[];
    _collectParts(part, bodies, attachments);
    final preferredBody = _selectBody(bodies);
    final subject = decodeHeader(headers.value('subject')).trim();
    final sender = decodeHeader(headers.value('from')).trim();

    return ParsedMimeMessage(
      header: MailHeader(
        id: uid,
        uid: int.tryParse(uid) ?? 0,
        subject: subject.isEmpty ? '(No subject)' : subject,
        sender: sender.isEmpty ? 'Unknown sender' : sender,
        receivedAt: _parseDate(headers.value('date')) ?? DateTime.now(),
        preview: _previewFrom(preferredBody?.text),
        hasAttachments: attachments.isNotEmpty,
      ),
      body: preferredBody?.text ?? '',
      isHtml: preferredBody?.isHtml ?? false,
      attachments: attachments,
      rawHeaders: headerText,
    );
  }

  static String decodeHeader(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final unfolded = value.replaceAll(RegExp(r'\r?\n[ \t]+'), ' ');
    final pattern = RegExp(r'=\?([^?]+)\?([bBqQ])\?([^?]*)\?=');
    return unfolded.replaceAllMapped(pattern, (match) {
      final charset = match.group(1) ?? 'utf-8';
      final encoding = match.group(2)?.toLowerCase();
      final encoded = match.group(3) ?? '';
      final bytes = encoding == 'b'
          ? _safeBase64Decode(encoded)
          : _decodeQuotedPrintableBytes(encoded.replaceAll('_', ' '));
      return _decodeBytes(bytes, charset);
    });
  }

  static _Headers _parseHeaders(String text) {
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
    return _Headers(headers);
  }

  static _MimePart _parsePart(_Headers headers, String body) {
    final contentType = _ContentType.parse(headers.value('content-type'));
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
      final partHeaders = _parseHeaders(partText.substring(0, splitIndex));
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

  static void _collectParts(
    _MimePart part,
    List<_BodyCandidate> bodies,
    List<MailAttachmentInfo> attachments,
  ) {
    if (part.children.isNotEmpty) {
      for (final child in part.children) {
        _collectParts(child, bodies, attachments);
      }
      return;
    }

    final contentType = _ContentType.parse(part.headers.value('content-type'));
    final disposition = _Disposition.parse(
      part.headers.value('content-disposition'),
    );
    final fileName = disposition.fileName ?? contentType.params['name'];
    final mimeType = contentType.mimeType;
    final bodyBytes = _decodeTransfer(
      part.body,
      part.headers.value('content-transfer-encoding'),
    );

    if (fileName != null || disposition.kind == 'attachment') {
      attachments.add(
        MailAttachmentInfo(
          id: 'att-${attachments.length + 1}',
          fileName: decodeHeader(fileName ?? 'attachment'),
          mimeType: mimeType,
          size: bodyBytes.length,
          contentId: _cleanAngle(part.headers.value('content-id')),
        ),
      );
      return;
    }

    if (mimeType == 'text/plain' || mimeType == 'text/html') {
      bodies.add(
        _BodyCandidate(
          text: _decodeBytes(bodyBytes, contentType.params['charset']),
          isHtml: mimeType == 'text/html',
        ),
      );
    }
  }

  static _BodyCandidate? _selectBody(List<_BodyCandidate> bodies) {
    if (bodies.isEmpty) {
      return null;
    }
    return bodies.firstWhere((body) => body.isHtml, orElse: () => bodies.first);
  }

  static List<int> _decodeTransfer(String body, String? encoding) {
    final normalized = body.trimRight();
    return switch ((encoding ?? '').toLowerCase().trim()) {
      'base64' => _safeBase64Decode(normalized.replaceAll(RegExp(r'\s+'), '')),
      'quoted-printable' => _decodeQuotedPrintableBytes(normalized),
      _ => latin1.encode(normalized),
    };
  }

  static List<int> _safeBase64Decode(String value) {
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

  static List<int> _decodeQuotedPrintableBytes(String value) {
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

  static String _decodeBytes(List<int> bytes, String? charset) {
    final normalized = (charset ?? 'utf-8').toLowerCase().replaceAll('"', '');
    try {
      return switch (normalized) {
        'us-ascii' || 'ascii' => ascii.decode(bytes, allowInvalid: true),
        'iso-8859-1' || 'latin1' || 'latin-1' => latin1.decode(bytes),
        _ => utf8.decode(bytes, allowMalformed: true),
      };
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalized = value.replaceFirst(RegExp(r'^[A-Za-z]{3},\s*'), '');
    final parsed = DateTime.tryParse(value) ?? DateTime.tryParse(normalized);
    if (parsed != null) {
      return parsed;
    }
    for (final pattern in const [
      'd MMM yyyy HH:mm:ss Z',
      'd MMM yyyy HH:mm Z',
      'dd MMM yyyy HH:mm:ss Z',
      'dd MMM yyyy HH:mm Z',
    ]) {
      try {
        return DateFormat(pattern, 'en_US').parseUtc(normalized);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static String? _previewFrom(String? body) {
    final normalized = body
        ?.replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized.length <= 140
        ? normalized
        : '${normalized.substring(0, 140)}...';
  }

  static String? _cleanAngle(String? value) {
    if (value == null) {
      return null;
    }
    return value.trim().replaceAll(RegExp(r'^<|>$'), '');
  }
}

class _Headers {
  const _Headers(this._values);

  final Map<String, List<String>> _values;

  String? value(String name) => _values[name.toLowerCase()]?.join('\n');
}

class _MimePart {
  const _MimePart({
    required this.headers,
    required this.body,
    required this.children,
  });

  final _Headers headers;
  final String body;
  final List<_MimePart> children;
}

class _BodyCandidate {
  const _BodyCandidate({required this.text, required this.isHtml});

  final String text;
  final bool isHtml;
}

class _ContentType {
  const _ContentType({required this.mimeType, required this.params});

  final String mimeType;
  final Map<String, String> params;

  static _ContentType parse(String? value) {
    final parsed = _parseHeaderValue(value);
    return _ContentType(
      mimeType: (parsed.$1.isEmpty ? 'text/plain' : parsed.$1).toLowerCase(),
      params: parsed.$2,
    );
  }
}

class _Disposition {
  const _Disposition({required this.kind, this.fileName});

  final String kind;
  final String? fileName;

  static _Disposition parse(String? value) {
    final parsed = _parseHeaderValue(value);
    return _Disposition(
      kind: parsed.$1.toLowerCase(),
      fileName: parsed.$2['filename'],
    );
  }
}

(String, Map<String, String>) _parseHeaderValue(String? value) {
  if (value == null || value.isEmpty) {
    return ('', const {});
  }
  final parts = value.split(';');
  final params = <String, String>{};
  for (final rawPart in parts.skip(1)) {
    final equals = rawPart.indexOf('=');
    if (equals <= 0) {
      continue;
    }
    final name = rawPart.substring(0, equals).trim().toLowerCase();
    final rawValue = rawPart.substring(equals + 1).trim();
    params[name] = _unquote(rawValue);
  }
  return (parts.first.trim(), params);
}

String _unquote(String value) {
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
