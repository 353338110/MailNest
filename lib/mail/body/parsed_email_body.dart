import 'email_attachment.dart';
import 'inline_image.dart';

/// Unified body parse result used by renderers and future translation flows.
class ParsedEmailBody {
  const ParsedEmailBody({
    this.plainText,
    this.html,
    this.inlineImages = const [],
    this.attachments = const [],
    this.charset,
    this.contentType,
    this.transferEncoding,
    this.hasRemoteImages = false,
    this.hasInlineImages = false,
    this.hasUnsupportedParts = false,
    this.isEncrypted = false,
    this.isSigned = false,
    this.parseFailed = false,
    this.parseError,
    this.rawPreview,
  });

  final String? plainText;
  final String? html;
  final List<InlineImage> inlineImages;
  final List<EmailAttachment> attachments;
  final String? charset;
  final String? contentType;
  final String? transferEncoding;
  final bool hasRemoteImages;
  final bool hasInlineImages;
  final bool hasUnsupportedParts;
  final bool isEncrypted;
  final bool isSigned;
  final bool parseFailed;
  final String? parseError;
  final String? rawPreview;

  bool get hasReadableBody =>
      (plainText?.trim().isNotEmpty ?? false) ||
      (html?.trim().isNotEmpty ?? false);
}
