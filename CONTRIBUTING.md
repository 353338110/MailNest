# Contributing

Use small pull requests with clear Conventional Commit messages.

Before opening a PR, run:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Do not commit secrets, email content, authorization codes, passwords, or tokens.
