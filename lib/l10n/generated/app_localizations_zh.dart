// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MailNest';

  @override
  String get onboardingBody => '一个简洁、本地优先的多邮箱客户端。';

  @override
  String get getStarted => '开始使用';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get translationSettings => '翻译设置';

  @override
  String get translationPrivacyNote => 'MailNest 默认不会把邮件内容发送到第三方翻译服务。';

  @override
  String get translationMockOnly => '第一版只包含翻译入口和 Mock 服务。';

  @override
  String get addEmailAccount => '添加邮箱账号';

  @override
  String get noAccountsYet => '还没有邮箱账号。';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get displayName => '显示名称';

  @override
  String get username => '用户名';

  @override
  String get passwordOrAppPassword => '密码或授权码';

  @override
  String get imapSettings => 'IMAP 设置';

  @override
  String get smtpSettings => 'SMTP 设置';

  @override
  String get host => '服务器';

  @override
  String get port => '端口';

  @override
  String get security => '加密方式';

  @override
  String get useStartTls => '使用 STARTTLS';

  @override
  String get saveAccount => '保存账号';

  @override
  String get accountSaved => '账号已保存。';

  @override
  String get requiredField => '此项必填。';

  @override
  String get invalidPort => '请输入有效端口。';

  @override
  String get oauthFutureNotice => '真实 OAuth 授权将在后续版本支持。';

  @override
  String get ok => '确定';

  @override
  String get qqMail => 'QQ 邮箱';

  @override
  String get neteaseMail => '网易邮箱';

  @override
  String get customMail => '自定义邮箱';

  @override
  String get editAccount => '编辑账号';

  @override
  String get updateAccount => '更新账号';

  @override
  String get accountUpdated => '账号已更新。';

  @override
  String get accountNotFound => '未找到账号。';

  @override
  String get accountActions => '账号操作';

  @override
  String get enableAccount => '启用账号';

  @override
  String get disableAccount => '停用账号';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountTitle => '删除账号？';

  @override
  String deleteAccountMessage(String emailAddress) {
    return '要从此设备删除 $emailAddress 吗？保存的密钥也会一并移除。';
  }

  @override
  String get accountDeleted => '账号已删除。';

  @override
  String get cancel => '取消';

  @override
  String get leavePasswordUnchanged => '新密码或授权码（留空则保持不变）';

  @override
  String get testConnection => '测试连接';

  @override
  String get connectionTestSucceeded => 'IMAP 和 SMTP 连接测试通过。';

  @override
  String connectionTestFailed(String reason) {
    return '连接测试失败：$reason';
  }

  @override
  String get passwordRequiredForConnectionTest => '请先输入密码或授权码再测试。';

  @override
  String get backupAndMigration => '备份与迁移';

  @override
  String get importEncryptedConfigSubtitle => '导入加密的 .enc 配置文件。';

  @override
  String get importConfig => '导入配置';

  @override
  String get importConfigDescription => '选择加密的 MailNest 配置文件，并输入备份密码以导入账号和设置。';

  @override
  String get importConfigExclusionNote => '不会导入邮件正文、附件缓存和搜索索引。';

  @override
  String get chooseEncConfigFile => '选择 .enc 文件';

  @override
  String get backupPassword => '备份密码';

  @override
  String get decryptAndPreview => '解密并预览';

  @override
  String get unableToReadConfigFile => '无法读取所选配置文件。';

  @override
  String importConfigSucceeded(int importedAccounts, int skippedAccounts) {
    return '已导入 $importedAccounts 个账号，跳过 $skippedAccounts 个。请测试已导入账号的连接。';
  }

  @override
  String get importPreviewTitle => '导入预览';

  @override
  String importPreviewSummary(int accounts, int settings, int conflicts) {
    return '$accounts 个账号，$settings 项设置，$conflicts 个冲突。';
  }

  @override
  String get noImportConflicts => '未发现账号冲突。';

  @override
  String get importConflictPrompt => '请选择覆盖或跳过已使用相同邮箱地址的账号。';

  @override
  String get skip => '跳过';

  @override
  String get overwrite => '覆盖';

  @override
  String get unknownError => '未知错误';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => 'MailNest';

  @override
  String get onboardingBody => '一个简洁、本地优先的多邮箱客户端。';

  @override
  String get getStarted => '开始使用';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get translationSettings => '翻译设置';

  @override
  String get translationPrivacyNote => 'MailNest 默认不会把邮件内容发送到第三方翻译服务。';

  @override
  String get translationMockOnly => '第一版只包含翻译入口和 Mock 服务。';

  @override
  String get addEmailAccount => '添加邮箱账号';

  @override
  String get noAccountsYet => '还没有邮箱账号。';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get displayName => '显示名称';

  @override
  String get username => '用户名';

  @override
  String get passwordOrAppPassword => '密码或授权码';

  @override
  String get imapSettings => 'IMAP 设置';

  @override
  String get smtpSettings => 'SMTP 设置';

  @override
  String get host => '服务器';

  @override
  String get port => '端口';

  @override
  String get security => '加密方式';

  @override
  String get useStartTls => '使用 STARTTLS';

  @override
  String get saveAccount => '保存账号';

  @override
  String get accountSaved => '账号已保存。';

  @override
  String get requiredField => '此项必填。';

  @override
  String get invalidPort => '请输入有效端口。';

  @override
  String get oauthFutureNotice => '真实 OAuth 授权将在后续版本支持。';

  @override
  String get ok => '确定';

  @override
  String get qqMail => 'QQ 邮箱';

  @override
  String get neteaseMail => '网易邮箱';

  @override
  String get customMail => '自定义邮箱';

  @override
  String get editAccount => '编辑账号';

  @override
  String get updateAccount => '更新账号';

  @override
  String get accountUpdated => '账号已更新。';

  @override
  String get accountNotFound => '未找到账号。';

  @override
  String get accountActions => '账号操作';

  @override
  String get enableAccount => '启用账号';

  @override
  String get disableAccount => '停用账号';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountTitle => '删除账号？';

  @override
  String deleteAccountMessage(String emailAddress) {
    return '要从此设备删除 $emailAddress 吗？保存的密钥也会一并移除。';
  }

  @override
  String get accountDeleted => '账号已删除。';

  @override
  String get cancel => '取消';

  @override
  String get leavePasswordUnchanged => '新密码或授权码（留空则保持不变）';

  @override
  String get testConnection => '测试连接';

  @override
  String get connectionTestSucceeded => 'IMAP 和 SMTP 连接测试通过。';

  @override
  String connectionTestFailed(String reason) {
    return '连接测试失败：$reason';
  }

  @override
  String get passwordRequiredForConnectionTest => '请先输入密码或授权码再测试。';

  @override
  String get backupAndMigration => '备份与迁移';

  @override
  String get importEncryptedConfigSubtitle => '导入加密的 .enc 配置文件。';

  @override
  String get importConfig => '导入配置';

  @override
  String get importConfigDescription => '选择加密的 MailNest 配置文件，并输入备份密码以导入账号和设置。';

  @override
  String get importConfigExclusionNote => '不会导入邮件正文、附件缓存和搜索索引。';

  @override
  String get chooseEncConfigFile => '选择 .enc 文件';

  @override
  String get backupPassword => '备份密码';

  @override
  String get decryptAndPreview => '解密并预览';

  @override
  String get unableToReadConfigFile => '无法读取所选配置文件。';

  @override
  String importConfigSucceeded(int importedAccounts, int skippedAccounts) {
    return '已导入 $importedAccounts 个账号，跳过 $skippedAccounts 个。请测试已导入账号的连接。';
  }

  @override
  String get importPreviewTitle => '导入预览';

  @override
  String importPreviewSummary(int accounts, int settings, int conflicts) {
    return '$accounts 个账号，$settings 项设置，$conflicts 个冲突。';
  }

  @override
  String get noImportConflicts => '未发现账号冲突。';

  @override
  String get importConflictPrompt => '请选择覆盖或跳过已使用相同邮箱地址的账号。';

  @override
  String get skip => '跳过';

  @override
  String get overwrite => '覆盖';

  @override
  String get unknownError => '未知错误';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'MailNest';

  @override
  String get onboardingBody => '一個簡潔、本地優先的多信箱客戶端。';

  @override
  String get getStarted => '開始使用';

  @override
  String get settings => '設定';

  @override
  String get language => '語言';

  @override
  String get translationSettings => '翻譯設定';

  @override
  String get translationPrivacyNote => 'MailNest 預設不會把郵件內容傳送到第三方翻譯服務。';

  @override
  String get translationMockOnly => '第一版只包含翻譯入口和 Mock 服務。';

  @override
  String get addEmailAccount => '新增信箱帳號';

  @override
  String get noAccountsYet => '尚無信箱帳號。';

  @override
  String get emailAddress => '信箱地址';

  @override
  String get displayName => '顯示名稱';

  @override
  String get username => '使用者名稱';

  @override
  String get passwordOrAppPassword => '密碼或授權碼';

  @override
  String get imapSettings => 'IMAP 設定';

  @override
  String get smtpSettings => 'SMTP 設定';

  @override
  String get host => '伺服器';

  @override
  String get port => '連接埠';

  @override
  String get security => '加密方式';

  @override
  String get useStartTls => '使用 STARTTLS';

  @override
  String get saveAccount => '儲存帳號';

  @override
  String get accountSaved => '帳號已儲存。';

  @override
  String get requiredField => '此欄位必填。';

  @override
  String get invalidPort => '請輸入有效連接埠。';

  @override
  String get oauthFutureNotice => '真實 OAuth 授權將在後續版本支援。';

  @override
  String get ok => '確定';

  @override
  String get qqMail => 'QQ 信箱';

  @override
  String get neteaseMail => '網易信箱';

  @override
  String get customMail => '自訂信箱';

  @override
  String get editAccount => '編輯帳號';

  @override
  String get updateAccount => '更新帳號';

  @override
  String get accountUpdated => '帳號已更新。';

  @override
  String get accountNotFound => '找不到帳號。';

  @override
  String get accountActions => '帳號操作';

  @override
  String get enableAccount => '啟用帳號';

  @override
  String get disableAccount => '停用帳號';

  @override
  String get deleteAccount => '刪除帳號';

  @override
  String get deleteAccountTitle => '刪除帳號？';

  @override
  String deleteAccountMessage(String emailAddress) {
    return '要從此裝置刪除 $emailAddress 嗎？儲存的密鑰也會一併移除。';
  }

  @override
  String get accountDeleted => '帳號已刪除。';

  @override
  String get cancel => '取消';

  @override
  String get leavePasswordUnchanged => '新密碼或授權碼（留空則保持不變）';

  @override
  String get testConnection => '測試連線';

  @override
  String get connectionTestSucceeded => 'IMAP 和 SMTP 連線測試通過。';

  @override
  String connectionTestFailed(String reason) {
    return '連線測試失敗：$reason';
  }

  @override
  String get passwordRequiredForConnectionTest => '請先輸入密碼或授權碼再測試。';

  @override
  String get backupAndMigration => '備份與遷移';

  @override
  String get importEncryptedConfigSubtitle => '匯入加密的 .enc 設定檔。';

  @override
  String get importConfig => '匯入設定';

  @override
  String get importConfigDescription => '選擇加密的 MailNest 設定檔，並輸入備份密碼以匯入帳號和設定。';

  @override
  String get importConfigExclusionNote => '不會匯入郵件本文、附件快取和搜尋索引。';

  @override
  String get chooseEncConfigFile => '選擇 .enc 檔案';

  @override
  String get backupPassword => '備份密碼';

  @override
  String get decryptAndPreview => '解密並預覽';

  @override
  String get unableToReadConfigFile => '無法讀取所選設定檔。';

  @override
  String importConfigSucceeded(int importedAccounts, int skippedAccounts) {
    return '已匯入 $importedAccounts 個帳號，略過 $skippedAccounts 個。請測試已匯入帳號的連線。';
  }

  @override
  String get importPreviewTitle => '匯入預覽';

  @override
  String importPreviewSummary(int accounts, int settings, int conflicts) {
    return '$accounts 個帳號，$settings 項設定，$conflicts 個衝突。';
  }

  @override
  String get noImportConflicts => '未發現帳號衝突。';

  @override
  String get importConflictPrompt => '請選擇覆蓋或略過已使用相同信箱地址的帳號。';

  @override
  String get skip => '略過';

  @override
  String get overwrite => '覆蓋';

  @override
  String get unknownError => '未知錯誤';
}
