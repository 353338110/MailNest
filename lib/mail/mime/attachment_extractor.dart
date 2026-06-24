import '../body/email_body_parser.dart';
import '../provider/mail_connection_tester.dart';

class MimeAttachmentExtractor {
  const MimeAttachmentExtractor();

  List<int> extractBytes({
    required String rawMessage,
    required String attachmentId,
  }) {
    final normalized = rawMessage.replaceAll('\r\n', '\n');
    final splitIndex = normalized.indexOf('\n\n');
    final headerText = splitIndex == -1
        ? normalized
        : normalized.substring(0, splitIndex);
    final bodyText = splitIndex == -1
        ? ''
        : normalized.substring(splitIndex + 2);
    final root = _parsePart(MimeHeaders.parse(headerText), bodyText);
    var attachmentIndex = 0;

    final part = _findPart(root, attachmentId, () {
      attachmentIndex += 1;
      return attachmentIndex;
    });
    if (part == null) {
      throw MailProtocolException(
        'Attachment with ID $attachmentId not found in message',
      );
    }

    return SimpleEmailBodyParser.decodeTransfer(
      part.body,
      part.headers.value('content-transfer-encoding'),
    );
  }

  _AttachmentMimePart? _findPart(
    _AttachmentMimePart part,
    String attachmentId,
    int Function() nextAttachmentIndex,
  ) {
    if (part.children.isNotEmpty) {
      for (final child in part.children) {
        final result = _findPart(child, attachmentId, nextAttachmentIndex);
        if (result != null) {
          return result;
        }
      }
      return null;
    }

    if (!_isAttachmentLike(part)) {
      return null;
    }
    final expectedId = 'att-${nextAttachmentIndex()}';
    return expectedId == attachmentId ? part : null;
  }

  bool _isAttachmentLike(_AttachmentMimePart part) {
    final contentType = part.headers.contentType;
    final disposition = part.headers.disposition;
    final fileName = disposition.fileName ?? contentType.params['name'];
    final contentId = _cleanAngle(part.headers.value('content-id'));
    return fileName != null ||
        disposition.kind == 'attachment' ||
        disposition.kind == 'inline' ||
        contentId != null;
  }

  _AttachmentMimePart _parsePart(MimeHeaders headers, String body) {
    final contentType = headers.contentType;
    if (!contentType.mimeType.startsWith('multipart/')) {
      return _AttachmentMimePart(
        headers: headers,
        body: body,
        children: const [],
      );
    }

    final boundary = contentType.params['boundary'];
    if (boundary == null || boundary.isEmpty) {
      return _AttachmentMimePart(
        headers: headers,
        body: body,
        children: const [],
      );
    }

    final children = <_AttachmentMimePart>[];
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
      children.add(
        _parsePart(
          MimeHeaders.parse(partText.substring(0, splitIndex)),
          partText.substring(splitIndex + 2),
        ),
      );
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

    return _AttachmentMimePart(headers: headers, body: '', children: children);
  }

  static String? _cleanAngle(String? value) {
    if (value == null) {
      return null;
    }
    return value.trim().replaceAll(RegExp(r'^<|>$'), '');
  }
}

class _AttachmentMimePart {
  const _AttachmentMimePart({
    required this.headers,
    required this.body,
    required this.children,
  });

  final MimeHeaders headers;
  final String body;
  final List<_AttachmentMimePart> children;
}
