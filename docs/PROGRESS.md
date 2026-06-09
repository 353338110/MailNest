# MailNest 开发进度

更新时间：2026-06-09

## 维护规则

- 每完成一个功能分支或 PR，必须更新本文件。
- 每个未完成大项单独实现、单独提交、单独 PR。
- 新页面必须保留正常返回路径；从列表、设置页进入二级页时使用保留导航栈的跳转。
- 用户体验优先级：可返回、可取消、危险操作需确认、敏感信息不展示不记录。

## 已完成

### PR #1：第一阶段项目骨架

链接：https://github.com/353338110/MailNest/pull/1

状态：已合并到 `main`

已完成内容：

- 初始化 Flutter 项目 `mailnest_app`。
- 生成 Android、iOS、Windows、macOS、Linux 平台结构。
- 明确未生成 Flutter Web 目录。
- 应用标识调整为 `com.funmaster.mailnest`。
- 配置 Material Design 3、浅色主题、深色主题。
- 配置 Riverpod、go_router、Drift、SQLite、SecureStorage。
- 配置 Flutter 官方 l10n。
- 创建 11 种语言 ARB 文件，并补充 `zh` fallback。
- 创建引导页、首页、设置页、翻译设置页、添加邮箱页。
- 添加 QQ、网易、Gmail、Outlook、自定义邮箱入口。
- 普通邮箱账号可填写 IMAP/SMTP 配置并保存。
- 密码、授权码通过 SecureStorage 保存，数据库只保存 `secret_ref`。
- 创建 `MailProvider`、`OAuthService`、`TranslationService` 抽象。
- 创建 Gmail/Outlook TODO Provider，不做真实 OAuth。
- 创建 GitHub Actions、Dependabot、PR 模板、Issue 模板和基础文档。
- 修正首页到添加账号、设置、翻译设置的导航栈，二级页面可返回。

### PR #2：账号管理 CRUD

链接：https://github.com/353338110/MailNest/pull/2

状态：已合并到 `main`

已完成内容：

- 账号列表点击可进入编辑页。
- 新增账号编辑路由 `/accounts/:accountId/edit`。
- 编辑页复用账号表单，邮箱地址只读。
- 编辑时密码/授权码可留空，表示保留当前 SecureStorage secret。
- 首页账号菜单支持编辑、启用/停用、删除。
- 删除账号前显示确认弹窗。
- 删除账号时同步删除 SecureStorage 中的 secret/token 引用。
- 补齐账号操作相关多语言文案。

### PR #3：IMAP/SMTP 连接测试

链接：https://github.com/353338110/MailNest/pull/3

状态：已合并到 `main`

已完成内容：

- 新增 `MailConnectionTester`。
- 支持 IMAP `LOGIN` 连接测试。
- 支持 SMTP `AUTH LOGIN` 连接测试。
- 支持 SSL/TLS 和 STARTTLS。
- 添加/编辑账号页新增“测试连接”按钮。
- 新账号测试使用当前输入的密码/授权码。
- 编辑账号时密码框留空会读取 SecureStorage 中已有 secret 测试。
- 测试结果通过 snackbar 提示。
- 不记录密码、授权码、Token 或认证响应。
- 增加连接测试结果模型测试。


### PR #4：邮箱视图导航

链接：https://github.com/353338110/MailNest/pull/6

状态：已创建，CI 待验证，待合并到 `main`

已完成内容：

- 首页从单纯账号列表改为邮箱工作台。
- 支持统一收件箱入口。
- 支持按账号查看本地邮件头列表。
- 支持按账号下 Inbox、Sent、Drafts、Trash 文件夹查看。
- 支持未读、星标、已发送、草稿箱、垃圾箱基础筛选。
- 在真实邮件头同步完成前，使用基于账号的本地轻量邮件头样例驱动视图。
- 保留账号添加、编辑、启用/停用、删除入口和确认流程。
- 桌面使用左侧导航加右侧列表布局；移动端保持同页返回路径，不进入无法返回的子页面。
- 不实现邮件详情正文、附件、发信、远程搜索。
- 增加邮箱视图过滤 repository 测试。

### PR #5：加密配置导出

链接：https://github.com/353338110/MailNest/pull/5

状态：已合并到 `main`

已完成内容：

- 设置页新增“备份与迁移”入口，并通过保留导航栈的二级页面进入，页面可返回。
- 新增加密配置导出页面，可输入并确认导出密码。
- 导出账号配置、IMAP/SMTP 配置、用户设置、语言设置、翻译设置。
- 使用用户输入密码通过 PBKDF2-HMAC-SHA256 派生 AES-256-GCM 密钥加密导出文件。
- 导出密码只在内存中用于密钥派生，不保存到数据库、SecureStorage 或导出文件。
- 导出账号 secret/token 时只写入加密 payload，不在 UI、日志或未加密 envelope 中展示。
- 默认不读取、不导出邮件正文、邮件头缓存、附件缓存、搜索索引。
- 导出文件名使用 `mailnest-backup-YYYYMMDD.enc`。
- 不实现导入功能，导入保留为后续 PR。
- 增加配置导出 service 测试，覆盖 payload 边界、文件名和密文不含明文账号数据。

### PR #13：本地搜索和 FTS

链接：https://github.com/353338110/MailNest/pull/8

状态：已创建，CI 通过，待合并到 `main`

已完成内容：

- 新增本地邮件缓存表，为后续同步 PR 写入本地邮件数据提供查询目标。
- 新增 SQLite FTS5 索引，覆盖发件人、收件人、主题、摘要、已缓存正文。
- 新增本地搜索 repository 和 Drift 查询方法，只查询本机 SQLite 缓存。
- 首页新增搜索入口，使用保留导航栈的二级页面跳转。
- 新增搜索结果页，支持返回、输入搜索、清空搜索、加载/空结果/错误状态。
- 搜索页提示未同步历史邮件时只能搜索本地已同步内容。
- 不做远程全量搜索。

### PR #22：多平台构建 CI

链接：https://github.com/353338110/MailNest/pull/4

状态：已合并到 `main`

已完成内容：

- 保留 PR Check 的 `dart format`、`flutter analyze`、`flutter test` 基础检查。
- 将 Flutter workflow 切换到 `master` channel，以匹配当前 Dart dev SDK 约束。
- CI workflow 增加 `workflow_dispatch` 手动触发。
- CI workflow 增加 Linux、Android、Windows、macOS、iOS 分阶段构建 job。
- Linux/Android 构建使用 Ubuntu runner。
- Windows 构建使用 Windows runner。
- macOS/iOS 构建使用 macOS runner。
- iOS 构建使用 `--no-codesign`，避免 CI 依赖签名证书。
- 手动触发 CI 时可按平台选择是否运行重平台构建。

## 已验证

最近一次验证命令：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

验证结果：通过。

## 未完成

### 邮件基础同步

- IMAP 文件夹列表同步。
- 本地保存文件夹列表。
- 最近 30 天邮件头同步。
- 增量同步游标。
- 邮件列表真实数据展示。
- 统一收件箱接入真实数据源。
- 按账号查看真实邮件。
- 按文件夹查看真实邮件。
- 未读、星标、已发送、草稿箱、垃圾箱等基础视图接入真实状态。

### 邮件详情与 MIME

- 邮件详情页。
- 按 UID 拉取完整邮件。
- MIME 解析。
- 纯文本正文展示。
- HTML 正文展示。
- base64、quoted-printable 解码。
- 远程图片默认拦截。
- “加载远程图片”交互。
- 外部链接使用系统浏览器打开。

### 附件

- 附件元信息展示。
- 附件类型图标。
- 附件下载。
- 附件本地缓存。
- 使用系统方式打开附件。
- 附件缓存清理。

### 写邮件与发信

- 写邮件页面。
- SMTP 发信。
- 回复、回复全部、转发。
- 添加收件人、抄送、密送。
- 添加/删除附件。
- 本地发送记录。
- 尝试 IMAP APPEND 保存到 Sent 文件夹。

### 草稿

- 本地草稿。
- 自动保存草稿。
- 手动保存草稿。
- 删除草稿。
- 编辑草稿。
- 发送草稿。

### 配置导入导出

- 解密导入配置。
- 导入冲突处理。
- 导入后测试连接。
- 导出同步设置。

### 搜索

- 远程全量搜索。

### Gmail

- Gmail OAuth 授权。
- Token 保存和刷新。
- Gmail 邮件列表。
- Gmail 邮件详情。
- Gmail 发信。

### Outlook

- Outlook OAuth 授权。
- Token 保存和刷新。
- Outlook 邮件列表。
- Outlook 邮件详情。
- Outlook 发信。

### 翻译

- 邮件详情页翻译结果展示。
- 写邮件页翻译入口。
- 真实翻译 Provider。
- 翻译隐私确认流程。
- 用户自定义 API Key。
- 翻译结果缓存，可选。

### 桌面和移动端体验

- 桌面三栏布局。
- 中等宽度两栏布局。
- 小窗口退化为移动端导航。
- 移动端 Drawer 或 NavigationDrawer。
- 键盘快捷键。
- 右键菜单。
- 更完整的返回、取消、确认、加载状态。

### CI 与发布

- Release workflow。
- SemVer tag 发布流程。

## 后续 PR 队列

建议按以下顺序继续，每项一个 PR：

1. `codex/mail-folder-sync`：IMAP 文件夹列表同步和本地保存。
2. `codex/mail-header-sync`：最近 30 天邮件头同步和邮件列表真实数据。
3. `codex/mail-detail-mime`：邮件详情、正文拉取、MIME 解析。
4. `codex/html-rendering-privacy`：HTML 渲染、远程图片拦截、外部链接处理。
5. `codex/attachments-cache`：附件列表、下载、缓存和打开。
6. `codex/composer-smtp-send`：写邮件和 SMTP 发信。
7. `codex/reply-forward`：回复、回复全部、转发。
8. `codex/drafts`：本地草稿。
9. `codex/sent-records`：发送记录和 Sent 文件夹保存。
10. `codex/backup-import`：配置导入和冲突处理。
11. `codex/desktop-layout`：桌面三栏和响应式布局完善。
12. `codex/mobile-navigation`：移动端 Drawer/NavigationDrawer。
13. `codex/gmail-oauth`：Gmail OAuth。
14. `codex/gmail-mail-provider`：Gmail 邮件列表、详情和发信。
15. `codex/outlook-oauth`：Outlook OAuth。
16. `codex/outlook-mail-provider`：Outlook 邮件列表、详情和发信。
17. `codex/translation-ui`：邮件详情和写信翻译 UI。
18. `codex/translation-provider`：真实翻译服务和隐私确认。
19. `codex/release-workflow`：发布流程和 tag 自动化。

## 注意事项

- 当前需求文档 `MailNest 项目规划与需求文档.docx` 仍未跟踪，默认不纳入代码 PR。
- 合并 PR 前需要重新确认 `gh` 可访问 GitHub，并检查 CI 状态。
