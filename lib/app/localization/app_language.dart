import 'package:flutter/material.dart';

/// A user-selectable app language supported by the first MailNest release.
enum AppLanguage {
  system(null, 'System'),
  zhCN(Locale('zh', 'CN'), '简体中文'),
  zhTW(Locale('zh', 'TW'), '繁體中文'),
  en(Locale('en'), 'English'),
  de(Locale('de'), 'Deutsch'),
  it(Locale('it'), 'Italiano'),
  ja(Locale('ja'), '日本語'),
  ko(Locale('ko'), '한국어'),
  fr(Locale('fr'), 'Français'),
  es(Locale('es'), 'Español'),
  pt(Locale('pt'), 'Português'),
  ru(Locale('ru'), 'Русский');

  const AppLanguage(this.locale, this.displayName);

  final Locale? locale;
  final String displayName;
}
