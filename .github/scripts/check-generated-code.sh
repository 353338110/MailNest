#!/usr/bin/env bash
set -euo pipefail

dart run build_runner build
flutter gen-l10n

git diff --exit-code -- \
  lib/core/database/app_database.g.dart \
  lib/l10n/generated
