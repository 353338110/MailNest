# Changelog

## Unreleased

### Account & OAuth

- Gmail OAuth with system browser authorization and loopback/deeplink callback.
- Outlook OAuth with system browser authorization, desktop loopback callback, and mobile deeplink callback.
- Automatic token refresh for Gmail and Outlook; UI prompts re-authorization on refresh failure.
- Gmail OAuth scope expanded to support read, send, and modify operations.
- Trim whitespace and newlines from pasted authorization codes for QQ/NetEase mailboxes.

### Mail Sync

- Multi-folder sync for all discovered folders; single folder failure does not block other folders or accounts.
- Configurable sync range in settings: 30 days, 90 days, 180 days, 1 year, or all mail.
- Changing sync range clears sync cursors so next sync backfills history.
- Sync status persisted locally with account, folder, status, error, start time, and end time.
- Sync failure status displayed in mail list header.
- Automatic cursor reset and single retry on UIDVALIDITY or cursor-invalid errors.
- Outlook mail list and detail sync via Microsoft Graph.

### Mail List & Detail

- Long-press to enter multi-select mode with batch delete, mark read/unread, and star.
- Keyboard shortcuts in mail list: delete, mark read/unread, star.
- Right-click context menu: open, mark, star, delete.
- Account identifier shown in unified inbox and grouped inbox views.
- Small-window navigation: tap mail list item to open detail page with back entry.
- Sent mail view supports expandable full body (decoded from locally saved RFC822 content).

### Mail Body Rendering

- Safe HTML sanitization (scripts, event attributes, dangerous links removed).
- HTML table, button, and link rendering.
- Inline images (cid) and remote image loading.
- Remote images loaded by default; explicit toggle to disable.
- Remote image load failure shows placeholder with retry entry.
- GBK, GB2312, GB18030, Latin-1, and UTF-8 charset decoding.
- Fixed-width HTML emails scaled from original canvas to avoid reflow in tables, footers, and verification cards.
- Mail detail header format improved: subject, sender, on-behalf-of, recipients, date.

### Attachments

- Download attachments from IMAP server to local cache.
- Batch "Download All" with progress, success/failure count, and stop button.
- Individual attachment download with progress and cancel entry.
- Provider-level byte progress and cancel for attachment downloads: each attachment card shows byte-level progress bar and percentage; cancel button triggers immediate Provider-level cancellation.
- Attachment type icons based on MIME type and file extension.
- Local attachment cache management: view cache size, clear all, clear caches older than 30 days.
- Open attachments with system default application.
- Attachment byte extraction uses dedicated MIME parser supporting nested multipart, base64, quoted-printable, and inline/attachment `att-N` ordering.
- Chinese filename and multi-attachment MIME extraction regression tests.

### Compose, Drafts & Send

- SMTP send with attachment support.
- Outlook send via Graph `sendMail` with saved sent mail.
- Compose page supports add/remove/select multiple local attachments; selection failure shows explicit error.
- Reply, Reply All, and Forward from mail detail page, reusing compose page.
- Reply All excludes current account, deduplicates recipients, and fills CC from MIME detail.
- Draft attachments persisted locally; restored when reopening draft; cleaned up after send or delete.
- Remote draft sync: IMAP APPENDUID to Drafts, Gmail Draft API, Microsoft Graph drafts.
- Remote draft cleaned up when local draft is sent or deleted.

### Search

- Remote full-text search: IMAP `UID SEARCH`, Gmail query, Microsoft Graph `$search`.
- Falls back to local FTS when remote search fails.

### Translation

- Translation service with configurable HTTPS provider, custom API key, and secure storage.
- Privacy confirmation before sending content to translation service.
- Translation result cache keyed by content hash, source language, target language, and provider config.
- Translation cache clear entry in translation settings page.
- Config backup exports translation settings only, not cached translation content.

### Account Groups

- Multi-account group management: create, edit, delete empty groups from home page.
- Batch move accounts between groups.
- Account group field in add-account page supports selecting existing groups or typing a new group name.

### Config Import/Export

- Encrypted config import: `.enc` file decryption, import preview, account conflict skip/overwrite.
- Passwords and OAuth tokens written to SecureStorage on import; SQLite stores references only.
- Sync range setting exported and imported.
- Compatible with current nested backup format and legacy flat format.
- "Test Connection" entry available after successful import.

### Gmail Provider

- Full Gmail REST API provider: label list, metadata sync, raw MIME detail parsing, send, delete, read/unread, star, and move via label/modify/trash API.
- Gmail message ID stored in local `messageId`; existing `uid` uses stable hash.
- 401 response triggers forced token refresh and single retry; refresh failure throws re-authorization exception.
- Unit tests for label mapping, metadata sync, raw MIME parsing, send, 401 retry, and refresh failure.

### Outlook Provider

- Full Microsoft Graph provider: folder list, mail header list, mail detail, send, read/unread, and delete.
- Access token auto-refresh on expiry; 401 response triggers refresh and retry.
- Refresh token missing or refresh failure throws re-authorization exception.
- Outlook OAuth token stored in SecureStorage only; SQLite stores token reference.
- Unit tests for Graph mapping, token refresh, and re-authorization exception.

### Desktop & Mobile UX

- Mail delete confirmation dialog.
- Single and batch mail operations show running progress indicator and prevent duplicate triggers.
- Mobile drawer removes stale folder future-feature entries; folders displayed under account.
- Folder expand/collapse text uses generated `AppLocalizations`.

### Release

- Added a tag/manual GitHub Release workflow for SemVer tags such as `v0.1.0` and `v0.2.0`.
- Documented the staged release strategy for Android, iOS, macOS, Windows, and Linux.

## 0.1.0

- Created the first-stage Flutter project structure.
- Added Material Design 3 app shell, routing, l10n, account setup, Drift schema, secure storage wrapper, and provider abstractions.
