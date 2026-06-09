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
  String get gmailOAuthTitle => '使用 Google 登录';

  @override
  String get gmailOAuthSystemBrowserNotice =>
      'MailNest 会在系统浏览器中打开 Google 授权，Token 只保存到安全存储。';

  @override
  String get authorizeGmail => '授权 Gmail';

  @override
  String get reauthorizeGmail => '重新授权 Gmail';

  @override
  String get gmailOAuthConnected => 'Gmail 授权已连接。';

  @override
  String get gmailReauthorizeHelp => '如果 Google 访问权限被撤销或 Token 刷新失败，请重新授权。';

  @override
  String get gmailAuthorizationSaved => 'Gmail 授权已保存。';

  @override
  String get gmailAuthorizationCanceled => 'Gmail 授权已取消。';

  @override
  String gmailAuthorizationFailed(String reason) {
    return 'Gmail 授权失败：$reason';
  }

  @override
  String get gmailReauthorizeEmailMismatch => '请使用同一个 Gmail 地址重新授权。';

  @override
  String get gmailReauthorizationRequired => '需要重新授权 Gmail。';

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
  String get unknownError => '未知错误';

  @override
  String get searchMail => '搜索邮件';

  @override
  String get searchMailHint => '发件人、收件人、主题、摘要或已缓存正文';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get localSearchLocalOnlyNotice =>
      '搜索只覆盖已同步到本设备的邮件。尚未同步到本地的邮件不会出现在结果中。';

  @override
  String get searchMailEmptyPrompt => '搜索本地已同步邮件。';

  @override
  String get searchMailFailed => '搜索失败，请重试。';

  @override
  String noLocalSearchResults(String query) {
    return '没有找到“$query”的本地结果。';
  }

  @override
  String localSearchResultCount(int count) {
    return '$count 条本地结果';
  }

  @override
  String get noSubject => '（无主题）';

  @override
  String get backupAndMigration => '备份与迁移';

  @override
  String get backupAndMigrationSubtitle => '导出加密配置备份。';

  @override
  String get exportConfiguration => '导出配置';

  @override
  String get backupExportDescription =>
      '创建包含账号配置、服务器设置和应用偏好的加密备份。导入功能将在后续版本添加。';

  @override
  String get backupIncludes => '导出内容';

  @override
  String get backupIncludesAccounts => '账号配置';

  @override
  String get backupIncludesServerSettings => 'IMAP 和 SMTP 配置';

  @override
  String get backupIncludesUserSettings => '用户设置';

  @override
  String get backupIncludesLanguageSettings => '语言设置';

  @override
  String get backupIncludesTranslationSettings => '翻译设置';

  @override
  String get backupExcludes => '默认不导出';

  @override
  String get backupExcludesMailBodies => '邮件正文';

  @override
  String get backupExcludesHeaderCache => '邮件头缓存';

  @override
  String get backupExcludesAttachmentCache => '附件缓存';

  @override
  String get backupExcludesSearchIndex => '搜索索引';

  @override
  String get exportPassword => '导出密码';

  @override
  String get confirmExportPassword => '确认导出密码';

  @override
  String get exportPasswordsDoNotMatch => '两次输入的密码不一致。';

  @override
  String get exportPasswordNotSaved => '此密码只用于加密导出文件，MailNest 不会保存。';

  @override
  String get exportBackup => '导出备份';

  @override
  String get exportingBackup => '正在导出...';

  @override
  String backupExported(String fileName) {
    return '备份已导出：$fileName';
  }

  @override
  String backupExportedTo(String filePath) {
    return '已保存到 $filePath';
  }

  @override
  String get backupExportFailed => '备份导出失败。';

  @override
  String get composeMail => '写邮件';

  @override
  String get drafts => '草稿箱';

  @override
  String get editDraft => '编辑草稿';

  @override
  String get saveDraft => '保存草稿';

  @override
  String get draftSaved => '草稿已保存。';

  @override
  String get savingDraft => '正在保存草稿...';

  @override
  String get draftAutosaveReady => '自动保存已就绪。';

  @override
  String draftLastSaved(String time) {
    return '上次保存于 $time';
  }

  @override
  String get deleteDraft => '删除草稿';

  @override
  String get deleteDraftTitle => '删除草稿？';

  @override
  String get deleteDraftMessage => '要从此设备删除这封本地草稿吗？';

  @override
  String get draftDeleted => '草稿已删除。';

  @override
  String get draftNotFound => '未找到草稿。';

  @override
  String get emptyDraft => '请先填写内容再保存草稿。';

  @override
  String get fromAccount => '发件账号';

  @override
  String get noAccountSelected => '未选择账号';

  @override
  String get toRecipients => '收件人';

  @override
  String get ccRecipients => '抄送';

  @override
  String get bccRecipients => '密送';

  @override
  String get subject => '主题';

  @override
  String get messageBody => '正文';

  @override
  String get noDraftsYet => '还没有草稿。';

  @override
  String get untitledDraft => '无主题草稿';

  @override
  String toLine(String recipients) {
    return '收件人：$recipients';
  }

  @override
  String get sentMessages => '已发送';

  @override
  String get noSentMessagesYet => '还没有已发送邮件。';

  @override
  String sentToRecipients(String recipients) {
    return '收件人：$recipients';
  }

  @override
  String get chooseSentFolder => '选择 Sent 文件夹';

  @override
  String get sentFolderOnlyLocalRecord => '这封邮件仅保存了本地发送记录。';

  @override
  String get sentFolderSavePending => '正在保存到 Sent';

  @override
  String sentFolderSaved(String folderName) {
    return '已保存到 $folderName';
  }

  @override
  String get sentFolderSelectionRequired => '请选择 Sent 文件夹';

  @override
  String get sentFolderSaveFailed => 'Sent 文件夹保存失败';

  @override
  String sentFolderAppendSucceeded(String folderName) {
    return '已保存到 $folderName。';
  }

  @override
  String sentFolderAppendFailed(String reason) {
    return '无法保存到 Sent：$reason';
  }

  @override
  String get inbox => '收件箱';

  @override
  String get folders => '文件夹';

  @override
  String get accounts => '账号';

  @override
  String get composeEmail => '写邮件';

  @override
  String get composeFutureNotice => '写邮件功能将在后续版本提供。';

  @override
  String get foldersFutureNotice => '邮件同步加入后将支持文件夹导航。';

  @override
  String get mailDetail => '邮件详情';

  @override
  String get attachments => '附件';

  @override
  String get emptyMessageBody => '这封邮件没有可读正文。';

  @override
  String get htmlShownAsSource => '当前以源码文本显示 HTML。不会加载远程图片。';

  @override
  String get messageLoadFailed => '无法加载邮件。';

  @override
  String get noCachedMessages => '暂无已缓存邮件。';
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
  String get gmailOAuthTitle => '使用 Google 登录';

  @override
  String get gmailOAuthSystemBrowserNotice =>
      'MailNest 会在系统浏览器中打开 Google 授权，Token 只保存到安全存储。';

  @override
  String get authorizeGmail => '授权 Gmail';

  @override
  String get reauthorizeGmail => '重新授权 Gmail';

  @override
  String get gmailOAuthConnected => 'Gmail 授权已连接。';

  @override
  String get gmailReauthorizeHelp => '如果 Google 访问权限被撤销或 Token 刷新失败，请重新授权。';

  @override
  String get gmailAuthorizationSaved => 'Gmail 授权已保存。';

  @override
  String get gmailAuthorizationCanceled => 'Gmail 授权已取消。';

  @override
  String gmailAuthorizationFailed(String reason) {
    return 'Gmail 授权失败：$reason';
  }

  @override
  String get gmailReauthorizeEmailMismatch => '请使用同一个 Gmail 地址重新授权。';

  @override
  String get gmailReauthorizationRequired => '需要重新授权 Gmail。';

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
  String get unknownError => '未知错误';

  @override
  String get searchMail => '搜索邮件';

  @override
  String get searchMailHint => '发件人、收件人、主题、摘要或已缓存正文';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get localSearchLocalOnlyNotice =>
      '搜索只覆盖已同步到本设备的邮件。尚未同步到本地的邮件不会出现在结果中。';

  @override
  String get searchMailEmptyPrompt => '搜索本地已同步邮件。';

  @override
  String get searchMailFailed => '搜索失败，请重试。';

  @override
  String noLocalSearchResults(String query) {
    return '没有找到“$query”的本地结果。';
  }

  @override
  String localSearchResultCount(int count) {
    return '$count 条本地结果';
  }

  @override
  String get noSubject => '（无主题）';

  @override
  String get backupAndMigration => '备份与迁移';

  @override
  String get backupAndMigrationSubtitle => '导出加密配置备份。';

  @override
  String get exportConfiguration => '导出配置';

  @override
  String get backupExportDescription =>
      '创建包含账号配置、服务器设置和应用偏好的加密备份。导入功能将在后续版本添加。';

  @override
  String get backupIncludes => '导出内容';

  @override
  String get backupIncludesAccounts => '账号配置';

  @override
  String get backupIncludesServerSettings => 'IMAP 和 SMTP 配置';

  @override
  String get backupIncludesUserSettings => '用户设置';

  @override
  String get backupIncludesLanguageSettings => '语言设置';

  @override
  String get backupIncludesTranslationSettings => '翻译设置';

  @override
  String get backupExcludes => '默认不导出';

  @override
  String get backupExcludesMailBodies => '邮件正文';

  @override
  String get backupExcludesHeaderCache => '邮件头缓存';

  @override
  String get backupExcludesAttachmentCache => '附件缓存';

  @override
  String get backupExcludesSearchIndex => '搜索索引';

  @override
  String get exportPassword => '导出密码';

  @override
  String get confirmExportPassword => '确认导出密码';

  @override
  String get exportPasswordsDoNotMatch => '两次输入的密码不一致。';

  @override
  String get exportPasswordNotSaved => '此密码只用于加密导出文件，MailNest 不会保存。';

  @override
  String get exportBackup => '导出备份';

  @override
  String get exportingBackup => '正在导出...';

  @override
  String backupExported(String fileName) {
    return '备份已导出：$fileName';
  }

  @override
  String backupExportedTo(String filePath) {
    return '已保存到 $filePath';
  }

  @override
  String get backupExportFailed => '备份导出失败。';

  @override
  String get sentMessages => 'Sent';

  @override
  String get noSentMessagesYet => 'No sent messages yet.';

  @override
  String sentToRecipients(String recipients) {
    return 'To: $recipients';
  }

  @override
  String get chooseSentFolder => 'Choose Sent folder';

  @override
  String get sentFolderOnlyLocalRecord =>
      'Only the local sent record is saved for this message.';

  @override
  String get sentFolderSavePending => 'Saving to Sent';

  @override
  String sentFolderSaved(String folderName) {
    return 'Saved to $folderName';
  }

  @override
  String get sentFolderSelectionRequired => 'Choose a Sent folder';

  @override
  String get sentFolderSaveFailed => 'Sent folder save failed';

  @override
  String sentFolderAppendSucceeded(String folderName) {
    return 'Saved to $folderName.';
  }

  @override
  String sentFolderAppendFailed(String reason) {
    return 'Could not save to Sent: $reason';
  }

  @override
  String get inbox => '收件箱';

  @override
  String get folders => '文件夹';

  @override
  String get accounts => '账号';

  @override
  String get composeEmail => '写邮件';

  @override
  String get composeFutureNotice => '写邮件功能将在后续版本提供。';

  @override
  String get foldersFutureNotice => '邮件同步加入后将支持文件夹导航。';

  @override
  String get mailDetail => '邮件详情';

  @override
  String get attachments => '附件';

  @override
  String get emptyMessageBody => '这封邮件没有可读正文。';

  @override
  String get htmlShownAsSource => '当前以源码文本显示 HTML。不会加载远程图片。';

  @override
  String get messageLoadFailed => '无法加载邮件。';

  @override
  String get noCachedMessages => '暂无已缓存邮件。';
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
  String get gmailOAuthTitle => '使用 Google 登入';

  @override
  String get gmailOAuthSystemBrowserNotice =>
      'MailNest 會在系統瀏覽器中開啟 Google 授權，Token 只儲存到安全儲存空間。';

  @override
  String get authorizeGmail => '授權 Gmail';

  @override
  String get reauthorizeGmail => '重新授權 Gmail';

  @override
  String get gmailOAuthConnected => 'Gmail 授權已連接。';

  @override
  String get gmailReauthorizeHelp => '如果 Google 存取權遭撤銷或 Token 重新整理失敗，請重新授權。';

  @override
  String get gmailAuthorizationSaved => 'Gmail 授權已儲存。';

  @override
  String get gmailAuthorizationCanceled => 'Gmail 授權已取消。';

  @override
  String gmailAuthorizationFailed(String reason) {
    return 'Gmail 授權失敗：$reason';
  }

  @override
  String get gmailReauthorizeEmailMismatch => '請使用同一個 Gmail 地址重新授權。';

  @override
  String get gmailReauthorizationRequired => '需要重新授權 Gmail。';

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
  String get unknownError => '未知錯誤';

  @override
  String get searchMail => '搜尋郵件';

  @override
  String get searchMailHint => '寄件人、收件人、主旨、摘要或已快取內文';

  @override
  String get clearSearch => '清除搜尋';

  @override
  String get localSearchLocalOnlyNotice =>
      '搜尋只涵蓋已同步到此裝置的郵件。尚未同步到本機的郵件不會出現在結果中。';

  @override
  String get searchMailEmptyPrompt => '搜尋本機已同步郵件。';

  @override
  String get searchMailFailed => '搜尋失敗，請重試。';

  @override
  String noLocalSearchResults(String query) {
    return '沒有找到「$query」的本機結果。';
  }

  @override
  String localSearchResultCount(int count) {
    return '$count 筆本機結果';
  }

  @override
  String get noSubject => '（無主旨）';

  @override
  String get backupAndMigration => '備份與遷移';

  @override
  String get backupAndMigrationSubtitle => '匯出加密設定備份。';

  @override
  String get exportConfiguration => '匯出設定';

  @override
  String get backupExportDescription =>
      '建立包含帳號設定、伺服器設定和應用程式偏好的加密備份。匯入功能將在後續版本加入。';

  @override
  String get backupIncludes => '匯出內容';

  @override
  String get backupIncludesAccounts => '帳號設定';

  @override
  String get backupIncludesServerSettings => 'IMAP 和 SMTP 設定';

  @override
  String get backupIncludesUserSettings => '使用者設定';

  @override
  String get backupIncludesLanguageSettings => '語言設定';

  @override
  String get backupIncludesTranslationSettings => '翻譯設定';

  @override
  String get backupExcludes => '預設不匯出';

  @override
  String get backupExcludesMailBodies => '郵件正文';

  @override
  String get backupExcludesHeaderCache => '郵件標頭快取';

  @override
  String get backupExcludesAttachmentCache => '附件快取';

  @override
  String get backupExcludesSearchIndex => '搜尋索引';

  @override
  String get exportPassword => '匯出密碼';

  @override
  String get confirmExportPassword => '確認匯出密碼';

  @override
  String get exportPasswordsDoNotMatch => '兩次輸入的密碼不一致。';

  @override
  String get exportPasswordNotSaved => '此密碼只用於加密匯出檔案，MailNest 不會保存。';

  @override
  String get exportBackup => '匯出備份';

  @override
  String get exportingBackup => '正在匯出...';

  @override
  String backupExported(String fileName) {
    return '備份已匯出：$fileName';
  }

  @override
  String backupExportedTo(String filePath) {
    return '已保存到 $filePath';
  }

  @override
  String get backupExportFailed => '備份匯出失敗。';

  @override
  String get sentMessages => '已傳送';

  @override
  String get noSentMessagesYet => '尚無已傳送郵件。';

  @override
  String sentToRecipients(String recipients) {
    return '收件人：$recipients';
  }

  @override
  String get chooseSentFolder => '選擇 Sent 資料夾';

  @override
  String get sentFolderOnlyLocalRecord => '這封郵件僅儲存了本機傳送記錄。';

  @override
  String get sentFolderSavePending => '正在儲存到 Sent';

  @override
  String sentFolderSaved(String folderName) {
    return '已儲存到 $folderName';
  }

  @override
  String get sentFolderSelectionRequired => '請選擇 Sent 資料夾';

  @override
  String get sentFolderSaveFailed => 'Sent 資料夾儲存失敗';

  @override
  String sentFolderAppendSucceeded(String folderName) {
    return '已儲存到 $folderName。';
  }

  @override
  String sentFolderAppendFailed(String reason) {
    return '無法儲存到 Sent：$reason';
  }

  @override
  String get inbox => '收件匣';

  @override
  String get folders => '資料夾';

  @override
  String get accounts => '帳號';

  @override
  String get composeEmail => '寫郵件';

  @override
  String get composeFutureNotice => '寫郵件功能將在後續版本提供。';

  @override
  String get foldersFutureNotice => '加入郵件同步後將支援資料夾導覽。';

  @override
  String get mailDetail => '郵件詳情';

  @override
  String get attachments => '附件';

  @override
  String get emptyMessageBody => '這封郵件沒有可讀內文。';

  @override
  String get htmlShownAsSource => '目前以原始碼文字顯示 HTML。不會載入遠端圖片。';

  @override
  String get messageLoadFailed => '無法載入郵件。';

  @override
  String get noCachedMessages => '暫無已快取郵件。';
}
