enum SentAppendStatus {
  pending,
  appended,
  sentFolderSelectionRequired,
  appendFailed;

  String get storageValue {
    return switch (this) {
      SentAppendStatus.pending => 'pending',
      SentAppendStatus.appended => 'appended',
      SentAppendStatus.sentFolderSelectionRequired =>
        'sent_folder_selection_required',
      SentAppendStatus.appendFailed => 'append_failed',
    };
  }

  static SentAppendStatus fromStorageValue(String value) {
    return SentAppendStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => SentAppendStatus.pending,
    );
  }
}
