# MailNest 开发进度

更新时间：2026-07-07

## 维护规则

- 每完成一个功能分支或 PR，必须更新本文件。
- 每个未完成大项单独实现、单独提交、单独 PR。
- 新页面必须保留正常返回路径；从列表、设置页进入二级页时使用保留导航栈的跳转。
- 用户体验优先级：可返回、可取消、危险操作需确认、敏感信息不展示不记录。

## 已完成

### 第一阶段基础与账号

- PR #1：第一阶段项目骨架，已合并。
- PR #2：账号新增、编辑、删除、启用/停用，已合并。
- PR #3：普通 IMAP/SMTP 连接测试，已合并。
- PR #4：多平台构建 CI，已合并。
- PR #5：加密配置导出，已合并。
- PR #9：Dependabot，`actions/checkout` 4 -> 6，已合并。
- PR #10：Dependabot，`drift_flutter` 0.2.8 -> 0.3.0，已合并。

### 邮箱列表、同步与详情

- PR #6：邮箱视图导航，已合并。
- PR #8：本地搜索和 FTS，已合并。
- PR #12：桌面三栏和响应式布局，已合并。
- PR #13：移动端 Drawer/NavigationDrawer，已合并。
- PR #15：最近 30 天邮件头同步和邮件列表真实数据，已合并。
- PR #14：邮件详情、按 UID 拉取正文、基础 MIME 解析和附件元信息缓存，已合并。
- 本 PR：小窗口点击邮件列表项可进入详情页，详情页提供返回入口。
- 本 PR：统一收件箱和分组收件箱展示邮件所属账号标识。
- 本 PR：设置页增加“邮件同步范围”，支持 30 天、90 天、180 天、1 年和全部邮件；修改范围后清理同步游标以便回填历史邮件。
- 本 PR：同步状态持久化到本地，记录账号、文件夹、状态、错误、开始时间和结束时间，并在列表头展示失败状态。
- 本 PR：同步从仅 inbox 扩展为同步已发现文件夹；单个文件夹失败会记录失败状态，不阻塞同账号其他文件夹或其他账号。
- 本 PR：检测到 UIDVALIDITY/游标失效类错误时，会清理该文件夹游标并按当前同步范围重试一次。
- 本 PR：邮件详情页支持删除、星标/取消星标、标记已读/未读和移动文件夹，并同步更新本地缓存。
- 本 PR：邮件列表支持长按进入多选模式，可批量删除、标记已读、标记未读和星标。

### 写信、草稿、发送记录

- PR #7：本地草稿，已合并。
- PR #11：发送记录和 Sent 文件夹保存，已合并。
- 本 PR：写信页支持添加/删除本地附件，SMTP 和 Outlook 发信均可携带附件。
- 本 PR：邮件详情页支持回复、回复全部和转发，复用写信页生成 `Re:`/`Fwd:` 主题和引用正文。
- 本 PR：回复全部会排除当前账号、去重收件人，并从 MIME 详情解析 CC 参与抄送填充。
- 本 PR：写信附件随本地草稿持久化，重新打开草稿会恢复附件；发送或删除草稿后同步清理草稿附件数据。
- 本 PR：附件选择支持多选，选择失败会在写信页明确提示，附件大小在列表中持续展示。

### OAuth 与翻译入口

- PR #16：Gmail OAuth，已合并。
- 本 PR：Gmail OAuth scope 扩展为支持读取、发信和邮件修改，供 Gmail Provider 执行同步、发信、删除、标记和移动操作。
- PR #17：邮件详情和写信翻译 UI，已合并。
- 本 PR：真实翻译服务和隐私确认，支持可配置 HTTPS Provider、自定义 API Key 和安全存储。
- 本 PR：Outlook OAuth 授权，支持系统浏览器授权、桌面 loopback 回调、移动端 deeplink 回调和 token 安全存储。
- 本 PR：添加邮箱时对 QQ/网易等授权码型邮箱清理复制粘贴产生的空格和换行。

### 本轮修复与增强

- 本 PR：添加邮箱账号页改为分区卡片式流程，拆分服务商选择、账号信息、授权/凭据、连接设置和保存操作。
- 本 PR：添加账号页新增顶部说明卡片、服务商选中态、统一安全存储提示，并保持 Gmail/Outlook OAuth 与 IMAP/SMTP 原有保存逻辑不变。
- 本 PR：主界面 UX/UI 卡片化优化，统一主题圆角、卡片、导航、输入框和 FAB 视觉规则。
- 本 PR：首页桌面三栏/中屏两栏改为独立卡片式工作区，左侧导航、邮件列表和详情面板层级更清晰。
- 本 PR：移动端 AppBar 保留搜索和写信高频入口，Drawer 增加品牌区、账号分组和账号分区。
- 本 PR：邮件列表改为卡片式列表，强化未读邮件强调、账号标识 chip、选中态和同步错误/空态/加载态。
- 本 PR：邮件详情内容区改为阅读卡片，桌面未选中邮件时提供搜索和写信入口。
- 本 PR：新增邮箱加载状态多语言文案，并提交 `flutter gen-l10n` 生成文件。
- 本 PR：清理过期“后续版本/后续 PR”提示，移动端抽屉不再展示无效的文件夹未来功能入口。
- 本 PR：邮件文件夹和账号展开/收起文案统一使用生成的 `AppLocalizations`，删除临时本地化 helper，并提交生成后的 l10n 文件。
- 本 PR：多账号分组管理，支持首页新增、编辑、删除空分组，以及账号批量移动分组。
- 本 PR：邮件正文兼容渲染，已支持安全清洗、HTML 表格/按钮/链接渲染、内联图片、远程图片加载、GBK/GB2312 等常见编码解码。
- 本 PR：固定宽度 HTML 邮件按原始画布整体缩放，避免放大或窄屏后表格、页脚和验证码卡片重新排版。
- 本 PR：邮件详情头部格式优化，补齐主题、发件人、代发、收件人、日期等展示，并修复发件人/标题解码。
- 本 PR：写信页接入 SMTP 发信，发送成功后保存本地 Sent 记录并清理草稿。
- 本 PR：打开邮件后本地立即标记已读，并尽力同步 IMAP `\Seen` 标记。
- 本 PR：已发送邮件支持展开查看完整正文，正文从本地保存的 RFC822 内容解码。
- 本 PR：添加账号页的分组字段改为可输入下拉选项，支持选择已有分组或输入新分组并在保存时自动创建。
- 本 PR：邮件列表支持键盘快捷键（删除、标记已读/未读、星标）和右键菜单（打开、标记、星标、删除）。
- 本 PR：清理 widget 测试中的 Drift 多数据库 warning。
- 本 PR：主界面、邮件详情和添加账号页进一步收口为 Apple Mail 风格，降低强色块，统一浅灰背景、白色面板、细边框、低阴影和蓝色轻强调。
- 本 PR：邮件删除、移动、标记已读/未读、星标、批量选择等操作文案迁入多语言资源，避免界面中英文/中文硬编码混杂。

### 邮件详情与 HTML

- PR #21：远程图片默认加载，不再默认阻止；保留显式关闭远程图片时的“加载图片”操作入口。
- 本 PR：统一远程图片默认加载策略，修正旧的“默认阻止”文案和显示状态默认值。
- 本 PR：远程图片加载失败时显示占位和“重试”入口，可重新触发图片加载。

### 附件

- 本 PR：附件下载功能，支持从 IMAP 服务器下载附件到本地缓存。
- 本 PR：附件类型图标，根据 MIME 类型和文件扩展名显示对应图标（图片、PDF、文档、压缩包等）。
- 本 PR：附件本地缓存管理，支持查看缓存大小、清理全部缓存、清理 30 天前的旧缓存。
- 本 PR：使用系统方式打开附件，下载后可用系统默认应用打开。
- 本 PR：附件字节提取改为独立 MIME 解析器，支持嵌套 multipart、base64、quoted-printable 和 inline/attachment 顺序一致的 `att-N` 定位。
- 本 PR：附件区增加”全部下载”，批量下载显示进度、成功/失败计数，并允许停止后续附件下载。
- 本 PR：单个附件下载中显示明确进度和取消入口；下载成功后当前详情页即时显示完成状态。
- 本 PR：补充中文文件名、多附件顺序定位的 MIME 附件提取回归测试。
- PR #43：Provider 级附件传输取消和字节级进度百分比，已合并。

### 配置导入导出

- 本 PR：加密配置导入，支持 `.enc` 文件解密、导入预览、账号冲突跳过/覆盖和语言设置恢复。
- 本 PR：导入账号时密码和 OAuth token 写入 SecureStorage，SQLite 只保存引用。

### 文件夹同步

- PR #20：IMAP 文件夹列表同步和本地保存，首页账号下优先展示真实远端文件夹，未同步时回退标准文件夹，已合并。

### PR #19：Outlook 邮件列表、详情和发信

链接：已合并

状态：已合并

已完成内容：

- 基于 Microsoft Graph 实现 `OutlookMailProvider`。
- 支持 Outlook/Microsoft 365 文件夹列表、邮件头列表、邮件详情和发信。
- 支持已读标记和删除接口，复用统一 `MailProvider` 边界。
- 从 SecureStorage 中的 OAuth token 引用读取 Outlook token，不把 token 存入 SQLite。
- Access token 过期时使用 refresh token 刷新，Graph 返回 401 时刷新并重试一次。
- Refresh token 缺失或刷新失败时抛出重新授权异常，供 UI 提示重新授权。
- 发信通过 Graph `sendMail` 保存到已发送邮件，不记录邮件正文。
- 增加 Outlook Graph 映射、token 刷新和重新授权异常测试。
- Outlook OAuth token 仅写入 SecureStorage，SQLite 只保存 token 引用。

### Gmail Provider

状态：已合并

已完成内容：

- 替换 `GmailMailProvider` 占位实现。
- 基于 Gmail REST API 实现 label 列表、邮件 metadata 同步、raw MIME 详情解析和发信。
- Gmail 发信复用现有 RFC822 构造逻辑，支持正文和附件编码。
- Gmail 邮件删除、已读/未读、星标和移动通过 Gmail label/modify/trash API 执行。
- 同步仓库和邮件仓库按账号 provider 路由到 IMAP、Gmail 或 Outlook provider。
- Gmail message id 存入本地 `messageId`，现有 `uid` 使用稳定 hash 生成，详情和操作优先用远端 message id。
- 增加 Gmail label 映射、metadata 同步、raw MIME 解析和发信测试。
- 本 PR：Gmail API 返回 401 时会强制刷新 token 并重试一次；刷新失败时抛出重新授权异常。
- 本 PR：新增 Gmail 401 重试和刷新失败单元测试。
- 本 PR：新增 `docs/qa/gmail-e2e.md` 真实账号端到端验收清单。
- 本 PR：Gmail 重新授权异常在同步失败状态中保留为明确重新连接账号提示，不再被通用 IMAP/SMTP 认证失败文案覆盖。
- 本 PR：新增 Gmail 重新授权错误净化和同步失败持久化回归测试。

### PR #23：发布流程和 tag 自动化

链接：待创建

状态：本 PR 实现中

已完成内容：

- 新增 `Release` GitHub Actions workflow。
- 支持 `vMAJOR.MINOR.PATCH` 格式 SemVer tag 触发，例如 `v0.1.0`、`v0.2.0`。
- 支持手动输入已有 tag 触发发布。
- 发布前校验 tag 与 `pubspec.yaml` 版本一致。
- 发布前运行 format、analyze、test。
- 生成 GitHub Release 和基础 release notes artifact。
- 明确 Android、iOS、macOS、Windows、Linux 分阶段发布策略。
- 不引入自动合并或自动商店发布。

## 已验证

最近一次主分支合并前，本地已通过：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

说明：测试中仍可能输出 Drift 多数据库 warning，目前不影响通过结果，后续可单独清理测试 provider 覆写。

本 PR 本地已通过：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test test/mail/mail_error_sanitizer_test.dart test/mail/mail_sync_repository_test.dart test/mail/gmail_mail_provider_test.dart
```

主界面 UX/UI 优化本地已通过：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
git diff --check
```

## 未完成

### Gmail

- Gmail token 过期、刷新失败和重新授权提示的真实账号端到端手工验收。
  - 当前本地单元测试已覆盖错误净化和同步失败状态；真实账号验收仍需要专用 Gmail 测试账号和 Google OAuth Client ID。

## 后续 PR 队列

建议按以下顺序继续，每项一个 PR：

1. Gmail 真实账号端到端验收：验证 token 过期、刷新失败和重新授权提示。
2. v0.1.0 发布前健康检查：确认 CI、release workflow、`pubspec.yaml` 版本和发布文档一致。

## 开放 PR

- 当前 GitHub 无开放 PR。

## 注意事项

- 当前需求文档 `MailNest 项目规划与需求文档.docx` 仍未跟踪，默认不纳入代码 PR。
- 合并 PR 前需要重新确认 `gh` 可访问 GitHub，并检查 CI 状态。
- 远程图片策略以用户最新要求为准：默认加载远程图片；仅在显式关闭远程图片时显示“加载图片”入口。
