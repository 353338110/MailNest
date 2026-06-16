# MailNest 开发进度

更新时间：2026-06-15

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

### 写信、草稿、发送记录

- PR #7：本地草稿，已合并。
- PR #11：发送记录和 Sent 文件夹保存，已合并。

### OAuth 与翻译入口

- PR #16：Gmail OAuth，已合并。
- PR #17：邮件详情和写信翻译 UI，已合并。
- 本 PR：真实翻译服务和隐私确认，支持可配置 HTTPS Provider、自定义 API Key 和安全存储。
- 本 PR：Outlook OAuth 授权，支持系统浏览器授权、桌面 loopback 回调、移动端 deeplink 回调和 token 安全存储。

### 本轮修复与增强

- 本 PR：多账号分组管理，支持首页新增、编辑、删除空分组，以及账号批量移动分组。
- 本 PR：邮件正文兼容渲染，已支持安全清洗、HTML 表格/按钮/链接渲染、内联图片、远程图片加载、GBK/GB2312 等常见编码解码。
- 本 PR：固定宽度 HTML 邮件按原始画布整体缩放，避免放大或窄屏后表格、页脚和验证码卡片重新排版。
- 本 PR：邮件详情头部格式优化，补齐主题、发件人、代发、收件人、日期等展示，并修复发件人/标题解码。
- 本 PR：写信页接入 SMTP 发信，发送成功后保存本地 Sent 记录并清理草稿。
- 本 PR：打开邮件后本地立即标记已读，并尽力同步 IMAP `\Seen` 标记。
- 本 PR：已发送邮件支持展开查看完整正文，正文从本地保存的 RFC822 内容解码。
- 本 PR：添加账号页的分组字段改为可输入下拉选项，支持选择已有分组或输入新分组并在保存时自动创建。

### 邮件详情与 HTML

- PR #21：远程图片默认加载，不再默认阻止；保留显式关闭远程图片时的“加载图片”操作入口。
- 本 PR：统一远程图片默认加载策略，修正旧的“默认阻止”文案和显示状态默认值。

### 附件

- 本 PR：附件下载功能，支持从 IMAP 服务器下载附件到本地缓存。
- 本 PR：附件类型图标，根据 MIME 类型和文件扩展名显示对应图标（图片、PDF、文档、压缩包等）。
- 本 PR：附件本地缓存管理，支持查看缓存大小、清理全部缓存、清理 30 天前的旧缓存。
- 本 PR：使用系统方式打开附件，下载后可用系统默认应用打开。

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

## 已验证

最近一次功能 PR 合并前，本地和 GitHub Actions 均通过：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

说明：测试中仍可能输出 Drift 多数据库 warning，目前不影响通过结果，后续可单独清理测试 provider 覆写。

## 未完成

### 附件

- 附件下载失败占位和重试体验。
- 附件 MIME 解析（当前使用占位实现）。

### 邮件同步

- 更完整的真实同步状态持久化。
- 多文件夹增量同步策略完善。
- Gmail/Outlook 邮件列表同步。

### 邮件详情与 HTML

- 远程图片加载失败占位和重试体验。

### 写邮件与发信

- 回复、回复全部、转发。
- 添加/删除附件。
- 发送草稿的远端草稿箱同步。

### 配置导入导出

- 导入后测试连接。
- 导出同步设置。

### 搜索

- 远程全量搜索。

### Gmail

- Gmail 邮件列表。
- Gmail 邮件详情。
- Gmail 发信。

### 翻译

- 翻译结果缓存，可选。

### 桌面和移动端体验

- 键盘快捷键。
- 右键菜单。
- 更完整的取消、确认、加载状态。

### CI 与发布

- Release workflow。
- SemVer tag 发布流程。

## 后续 PR 队列

建议按以下顺序继续，每项一个 PR：

1. `codex/attachments-polish`：附件 MIME 解析、下载失败占位和重试体验。
2. `codex/reply-forward`：回复、回复全部、转发。
3. `codex/compose-attachments`：写邮件添加/删除附件和 SMTP 附件发送。
4. `codex/sync-state`：同步状态持久化、多文件夹增量同步和 UIDVALIDITY 处理。
5. `codex/mail-actions`：删除、星标、标记未读、移动文件夹和批量操作。
6. `codex/gmail-mail-provider`：Gmail 邮件列表、详情和发信。
7. `codex/desktop-mobile-polish`：键盘快捷键、右键菜单和更完整的加载/确认状态。
8. `codex/release-workflow`：发布流程和 tag 自动化。

## 开放 PR

- 当前 GitHub 无开放 PR。
- 本 PR：PR 状态整理，并确认远程图片默认加载策略。

## 注意事项

- 当前需求文档 `MailNest 项目规划与需求文档.docx` 仍未跟踪，默认不纳入代码 PR。
- 合并 PR 前需要重新确认 `gh` 可访问 GitHub，并检查 CI 状态。
- 远程图片策略以用户最新要求为准：默认加载远程图片；仅在显式关闭远程图片时显示“加载图片”入口。
