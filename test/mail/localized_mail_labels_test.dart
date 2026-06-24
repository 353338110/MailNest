import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/l10n/generated/app_localizations_en.dart';
import 'package:mailnest_app/l10n/generated/app_localizations_zh.dart';
import 'package:mailnest_app/mail/localized_mail_labels.dart';

void main() {
  test('uses Chinese labels for zh-CN mail folders and account toggles', () {
    final l10n = AppLocalizationsZhCn();

    expect(localizedSentMessages(l10n), '已发送');
    expect(localizedJunk(l10n), '垃圾邮件');
    expect(localizedExpandAccount(l10n), '展开账号');
    expect(localizedCollapseAccount(l10n), '收起账号');
  });

  test('keeps English labels for English locale', () {
    final l10n = AppLocalizationsEn();

    expect(localizedSentMessages(l10n), 'Sent');
    expect(localizedJunk(l10n), 'Junk');
    expect(localizedExpandAccount(l10n), 'Expand account');
    expect(localizedCollapseAccount(l10n), 'Collapse account');
  });
}
