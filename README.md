# MailNest

MailNest is a local-first, privacy-focused multi-account email client built with Flutter.

It helps users manage multiple email accounts in one clean inbox while keeping account settings, credentials, email cache, and attachments stored locally on the device.

## First-stage scope

- Flutter app for Android, iOS, Windows, macOS, and Linux.
- Material Design 3 UI.
- Local account metadata stored in SQLite through Drift.
- Passwords, app passwords, and future tokens stored through secure storage.
- Gmail and Outlook entry points are present, but real OAuth is intentionally deferred.
- No backend service and no Flutter Web target.

## Development

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Privacy baseline

MailNest does not store account secrets in SQLite and does not send email content to third-party translation services by default.
