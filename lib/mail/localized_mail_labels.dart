import '../l10n/generated/app_localizations.dart';

String localizedSentMessages(AppLocalizations l10n) {
  return l10n.localeName == 'zh_CN' ? '已发送' : l10n.sentMessages;
}

String localizedJunk(AppLocalizations l10n) {
  return switch (l10n.localeName) {
    'zh' || 'zh_CN' => '垃圾邮件',
    'zh_TW' => '垃圾郵件',
    _ => 'Junk',
  };
}

String localizedExpandAccount(AppLocalizations l10n) {
  return switch (l10n.localeName) {
    'zh' || 'zh_CN' => '展开账号',
    'zh_TW' => '展開帳號',
    _ => 'Expand account',
  };
}

String localizedCollapseAccount(AppLocalizations l10n) {
  return switch (l10n.localeName) {
    'zh' || 'zh_CN' => '收起账号',
    'zh_TW' => '收合帳號',
    _ => 'Collapse account',
  };
}
