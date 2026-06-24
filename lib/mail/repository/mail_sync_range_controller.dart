import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import '../models/mail_sync_range.dart';

final mailSyncRangeControllerProvider =
    NotifierProvider<MailSyncRangeController, MailSyncRange>(
      MailSyncRangeController.new,
    );

class MailSyncRangeController extends Notifier<MailSyncRange> {
  @override
  MailSyncRange build() {
    _loadSavedRange();
    return MailSyncRange.defaultRange;
  }

  Future<void> selectRange(MailSyncRange range) async {
    state = range;
    final database = ref.read(appDatabaseProvider);
    await database.saveSetting(
      AppSettingsCompanion(
        key: const Value(mailSyncRangeSettingKey),
        value: Value(range.storageValue),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await database.clearMailSyncCursors();
  }

  Future<void> _loadSavedRange() async {
    final setting = await ref
        .read(appDatabaseProvider)
        .getSetting(mailSyncRangeSettingKey);
    if (setting == null) {
      return;
    }
    state = MailSyncRange.fromStorageValue(setting.value);
  }
}
