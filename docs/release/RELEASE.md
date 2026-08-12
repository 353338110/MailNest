# MailNest Release Process

MailNest releases are created from SemVer tags that match `vMAJOR.MINOR.PATCH`, such as `v0.1.0` or `v0.2.0`.

## Release Triggers

- Automatic: push a tag like `v0.1.0` or `v0.2.0`; the workflow validates the exact `vMAJOR.MINOR.PATCH` format before publishing.
- Manual: run the `Release` workflow and provide an existing tag.

The workflow creates a GitHub Release and uploads a release notes artifact. It does not merge branches, create tags, sign binaries, notarize builds, or publish to app stores.

## Version Requirements

Before creating a release tag, update `pubspec.yaml` so the package version before `+build` matches the tag without the leading `v`.

Examples:

- Tag `v0.1.0` requires `version: 0.1.0+<build>`.
- Tag `v0.2.0` requires `version: 0.2.0+<build>`.

## Pre-Release Checks

Run these commands before tagging:

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Platform Release Strategy

MailNest uses staged platform releases until signing, notarization, and store delivery are configured for every target.

- Android: build and sign APK/AAB from the release tag, then distribute through an internal track before wider rollout.
- iOS: archive from the release tag and distribute through TestFlight before App Store release.
- macOS: archive, sign, notarize, and distribute after manual verification on supported macOS versions.
- Windows: build the release bundle or installer from the release tag, then verify on supported Windows versions.
- Linux: build the release bundle from the release tag, then verify on the target package format before publishing.

## Tagging

Create and push an annotated tag only after the release branch has been reviewed and merged:

```sh
git tag -a v0.1.0 -m "MailNest v0.1.0"
git push origin v0.1.0
```

For manual reruns, open GitHub Actions, select `Release`, and enter the existing tag.
