const mailSyncRangeSettingKey = 'user.mail_sync_range';

enum MailSyncRange {
  days30(30, '30'),
  days90(90, '90'),
  days180(180, '180'),
  days365(365, '365'),
  all(null, 'all');

  const MailSyncRange(this.days, this.storageValue);

  final int? days;
  final String storageValue;

  static const defaultRange = MailSyncRange.days30;

  DateTime? since(DateTime now) {
    final value = days;
    if (value == null) {
      return null;
    }
    return now.toUtc().subtract(Duration(days: value));
  }

  static MailSyncRange fromStorageValue(String? value) {
    return MailSyncRange.values.firstWhere(
      (range) => range.storageValue == value,
      orElse: () => defaultRange,
    );
  }
}
