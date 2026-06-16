/// A cid: image embedded inside an email body.
class InlineImage {
  const InlineImage({
    required this.contentId,
    required this.mimeType,
    this.filename,
    this.size,
    this.localPath,
    this.bytes,
  });

  final String contentId;
  final String mimeType;
  final String? filename;
  final int? size;
  final String? localPath;
  final List<int>? bytes;
}
