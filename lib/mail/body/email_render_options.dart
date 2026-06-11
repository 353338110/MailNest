/// Controls how a parsed email body is rendered for one detail view.
class EmailRenderOptions {
  const EmailRenderOptions({
    this.allowRemoteImages = false,
    this.allowExternalLinks = true,
    this.preferPlainText = false,
    this.enableSelection = true,
    this.showOriginal = true,
    this.showTranslated = false,
    this.onLoadRemoteImages,
  });

  final bool allowRemoteImages;
  final bool allowExternalLinks;
  final bool preferPlainText;
  final bool enableSelection;
  final bool showOriginal;
  final bool showTranslated;
  final void Function()? onLoadRemoteImages;

  EmailRenderOptions copyWith({
    bool? allowRemoteImages,
    bool? allowExternalLinks,
    bool? preferPlainText,
    bool? enableSelection,
    bool? showOriginal,
    bool? showTranslated,
    void Function()? onLoadRemoteImages,
  }) {
    return EmailRenderOptions(
      allowRemoteImages: allowRemoteImages ?? this.allowRemoteImages,
      allowExternalLinks: allowExternalLinks ?? this.allowExternalLinks,
      preferPlainText: preferPlainText ?? this.preferPlainText,
      enableSelection: enableSelection ?? this.enableSelection,
      showOriginal: showOriginal ?? this.showOriginal,
      showTranslated: showTranslated ?? this.showTranslated,
      onLoadRemoteImages: onLoadRemoteImages ?? this.onLoadRemoteImages,
    );
  }
}
