import 'dart:typed_data';

/// A local attachment included with an outgoing message.
class OutgoingAttachment {
  const OutgoingAttachment({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  int get size => bytes.length;
}
