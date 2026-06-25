# MailNest

MailNest is a local-first, privacy-focused multi-account email client built with Flutter.

It helps users manage multiple email accounts in one clean inbox while keeping account settings, credentials, email cache, and attachments stored locally on the device.

## Current scope

- Flutter app for Android, iOS, Windows, macOS, and Linux.
- Material Design 3 UI with desktop three-column layout and mobile responsive layout.
- Multi-account management with grouping, IMAP/SMTP, Gmail OAuth, and Outlook OAuth.
- Mail sync with configurable range, multi-folder incremental sync, and sync status tracking.
- Mail list with search (local FTS + remote full-text), multi-select, keyboard shortcuts, and context menu.
- Mail detail with safe HTML rendering, inline/remote images, attachments, reply/forward, and translation.
- Compose with local and remote draft sync, attachments, SMTP and Outlook/Gmail send.
- Encrypted config import/export with secure token handling.
- Local account metadata stored in SQLite through Drift.
- Passwords, app passwords, and OAuth tokens stored through secure storage — never in SQLite.
- No backend service and no Flutter Web target.

## Development

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### OAuth client IDs

Gmail OAuth requires a Google OAuth desktop/mobile client ID. Enter it on the
Gmail add-account page, or prefill the field at build/run time:

```sh
flutter run -d macos --dart-define=GMAIL_OAUTH_CLIENT_ID=your-google-client-id
```

Use the same `--dart-define` with `flutter build ...` for packaged builds when
you want packaged builds to prefill the field.

## Releases

MailNest releases use SemVer tags such as `v0.1.0` and `v0.2.0`.

Pushing a matching tag, or manually running the `Release` workflow with an existing tag, creates a GitHub Release with release notes and the current staged platform publishing strategy. The workflow does not automatically merge branches or publish to app stores.

See [docs/release/RELEASE.md](docs/release/RELEASE.md) for the release checklist, version requirements, and platform rollout strategy.

## Privacy baseline

MailNest does not store account secrets in SQLite and does not send email content to third-party translation services by default.
