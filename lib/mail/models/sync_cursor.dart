/// Provider-specific sync cursor. IMAP can use UID data; API providers can use tokens.
class SyncCursor {
  const SyncCursor({this.lastUid, this.pageToken, this.syncedAt});

  final int? lastUid;
  final String? pageToken;
  final DateTime? syncedAt;
}
