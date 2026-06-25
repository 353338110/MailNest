import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/l10n/generated/app_localizations_en.dart';
import 'package:mailnest_app/l10n/generated/app_localizations_zh.dart';

void main() {
  test('uses Chinese labels for zh-CN mail folders and account toggles', () {
    final l10n = AppLocalizationsZhCn();

    expect(l10n.sentMessages, '已发送');
    expect(l10n.junk, '垃圾邮件');
    expect(l10n.expandAccount, '展开账号');
    expect(l10n.collapseAccount, '收起账号');
  });

  test('keeps English labels for English locale', () {
    final l10n = AppLocalizationsEn();

    expect(l10n.sentMessages, 'Sent');
    expect(l10n.junk, 'Junk');
    expect(l10n.expandAccount, 'Expand account');
    expect(l10n.collapseAccount, 'Collapse account');
  });
}
