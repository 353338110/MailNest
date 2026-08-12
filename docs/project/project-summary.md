# MailNest 项目总结

**更新时间：** 2026-06-25
**当前版本：** v0.1.0

---

## 项目概述

MailNest 是一个**本地优先、注重隐私**的多账号邮件客户端，使用 Flutter 构建，支持 Android、iOS、Windows、macOS 和 Linux 五大平台。

### 核心特性

- **本地优先**：账号配置、凭证、邮件缓存和附件均存储在本地设备
- **隐私保护**：账号密码和 OAuth token 存储在系统安全存储中，不存入 SQLite
- **多账号管理**：支持多账号分组管理、批量移动分组
- **多平台支持**：IMAP/SMTP 普通邮箱、Gmail OAuth、Outlook OAuth
- **Material Design 3**：现代化 UI 设计，支持桌面三栏布局和移动端响应式布局

### 技术栈

- **框架**：Flutter 3.12+
- **数据库**：SQLite + Drift ORM
- **状态管理**：Riverpod
- **安全存储**：flutter_secure_storage
- **路由**：go_router
- **国际化**：flutter_localizations + intl
- **本地化维护**：ARB 文案为源，生成的 `AppLocalizations` 文件随变更提交

---

## 架构设计

### 代码结构

```
lib/
├── app/                    # 应用层
│   ├── localization/       # 国际化配置
│   └── theme/              # 主题配置
├── core/                   # 核心基础设施
│   ├── database/           # Drift 数据库定义
│   ├── platform/           # 平台相关工具
│   └── secure_storage/     # 安全存储封装
├── features/               # 功能模块
│   ├── accounts/           # 账号管理
│   ├── backup/             # 配置导入导出
│   ├── drafts/             # 草稿箱
│   ├── home/               # 首页与导航
│   ├── mail/               # 邮件列表与详情
│   ├── onboarding/         # 引导页
│   ├── search/             # 本地搜索（FTS）
│   ├── sent/               # 已发送邮件
│   ├── settings/           # 设置页
│   └── translation/        # 翻译功能
├── mail/                   # 邮件核心层
│   ├── body/               # 邮件正文解析与渲染
│   ├── mime/               # MIME 解析
│   ├── models/             # 邮件数据模型
│   ├── provider/           # 邮件服务抽象层（IMAP/Graph）
│   ├── repository/         # 邮件仓储层
│   └── services/           # 邮件业务服务
└── translation/            # 翻译服务层
    ├── models/             # 翻译模型
    └── repository/         # 翻译服务仓储
```

### 分层设计

1. **表现层（Features）**：UI 页面和用户交互逻辑
2. **业务层（Mail Services）**：邮件同步、发送、缓存管理
3. **数据层（Repository + Provider）**：
   - Repository：统一数据访问接口
   - Provider：具体邮件服务实现（IMAP、Outlook Graph、Gmail）
4. **基础设施层（Core）**：数据库、安全存储、平台工具

---

## 已完成功能

### 第一阶段：基础与账号管理

✅ **账号管理**
- 账号新增、编辑、删除、启用/停用
- 普通 IMAP/SMTP 连接测试
- 账号密码和 OAuth token 安全存储
- 多账号分组管理（首页新增/编辑/删除空分组，账号批量移动分组）
- 添加账号时分组字段支持选择已有分组或输入新分组
- QQ/网易等授权码型邮箱会清理粘贴产生的空格和换行

✅ **OAuth 授权**
- Gmail OAuth 授权（系统浏览器 + loopback 回调）
- Outlook OAuth 授权（系统浏览器 + 桌面 loopback + 移动端 deeplink）
- Token 自动刷新，过期后提示重新授权

✅ **配置导入导出**
- 加密配置导出（AES-256-GCM）
- 加密配置导入（`.enc` 文件解密、导入预览、账号冲突跳过/覆盖）
- 导入时密码和 OAuth token 写入 SecureStorage
- 语言设置恢复

✅ **多平台构建 CI**
- GitHub Actions 自动构建
- Dependabot 依赖更新

---

### 第二阶段：邮件列表、同步与详情

✅ **邮件同步**
- IMAP 文件夹列表同步和本地保存
- 最近 30 天邮件头同步（IMAP）
- 可在设置页选择同步范围：30 天、90 天、180 天、1 年或全部邮件
- 修改同步范围后会清理同步游标，下次同步按新范围回填历史邮件
- 同步状态持久化，记录账号、文件夹、状态、错误、开始时间和结束时间
- 邮件列表头展示同步失败状态
- 已发现文件夹会独立增量同步，单个文件夹失败不阻塞其他文件夹或其他账号
- UIDVALIDITY/游标失效类错误会清理该文件夹游标并按当前同步范围重试一次
- 按 UID 拉取邮件正文和附件元信息
- Outlook 邮件列表、详情同步（基于 Microsoft Graph）

✅ **邮件列表**
- 邮箱视图导航（Inbox、Sent、Drafts 等）
- 邮件列表真实数据展示
- 统一收件箱和分组收件箱展示邮件所属账号标识
- 长按邮件可进入多选模式，支持批量删除、标记已读、标记未读和星标
- 本地 FTS 全文搜索
- 桌面三栏布局和响应式设计
- 移动端 Drawer/NavigationDrawer
- 小窗口下点击邮件列表项可进入详情页，并可返回列表

✅ **邮件详情**
- 邮件头部格式优化（主题、发件人、代发、收件人、日期）
- 发件人/标题字符集解码（修复乱码）
- 打开邮件后本地立即标记已读，并尽力同步 IMAP `\Seen` 标记
- 支持删除、星标/取消星标、标记已读/未读和移动文件夹，并同步本地缓存
- 已发送邮件支持展开查看完整正文（从本地 RFC822 解码）

✅ **邮件正文渲染**
- 安全 HTML 清洗（移除脚本、事件属性、危险链接）
- 支持 HTML 表格/按钮/链接渲染
- 支持 `text/plain`、`text/html`、`multipart/alternative`、`multipart/mixed`
- 内联图片（cid）和远程图片加载
- 远程图片默认加载策略（显式关闭远程图片时显示"加载图片"入口）
- 远程图片加载失败时显示占位和重试入口
- GBK/GB2312/GB18030/Latin-1/UTF-8 等常见编码解码
- 固定宽度 HTML 邮件按原始画布整体缩放（避免表格、页脚重新排版）

✅ **附件功能**
- 附件元信息缓存
- 附件从 IMAP 服务器下载到本地缓存
- 附件字节提取支持嵌套 multipart、base64、quoted-printable 和 inline/attachment 顺序一致的 `att-N` 定位
- 附件类型图标（图片、PDF、文档、压缩包等）
- 附件本地缓存管理（查看缓存大小、清理全部缓存、清理 30 天前旧缓存）
- 使用系统方式打开附件
- Provider 级附件传输取消和字节级进度百分比（PR #43）

---

### 第三阶段：写信、草稿、发送记录

✅ **本地草稿**
- 草稿新增、编辑、删除
- 草稿自动保存
- 写信附件随本地草稿持久化，重新打开草稿会恢复附件

✅ **发信功能**
- 写信页接入 SMTP 发信
- 写信页支持添加/删除本地附件
- 写信页支持多选附件，附件选择失败会明确提示
- SMTP 和 Outlook 发信均可携带附件
- 发送成功后保存本地 Sent 记录并清理草稿
- Outlook 发信通过 Graph `sendMail` 保存到已发送邮件
- 邮件详情页支持回复、回复全部和转发，复用写信页
- 回复/回复全部自动生成 `Re:` 主题，转发自动生成 `Fwd:` 主题，并填充引用正文
- 回复全部会排除当前账号、去重收件人，并从 MIME 详情解析 CC 填充抄送

✅ **发送记录**
- 本地发送记录列表
- 保存到 IMAP Sent 文件夹

---

### 第四阶段：翻译功能

✅ **翻译 UI**
- 邮件详情页和写信页翻译入口

✅ **翻译服务**
- 支持可配置 HTTPS Provider
- 自定义 API Key 和安全存储
- 隐私确认机制

---

### 第五阶段：Outlook 集成

✅ **Outlook Provider**（PR #19 已合并）
- 基于 Microsoft Graph 实现 `OutlookMailProvider`
- 支持文件夹列表、邮件头列表、邮件详情和发信
- 支持已读标记和删除接口
- Access token 过期时自动刷新
- Refresh token 缺失或刷新失败时提示重新授权
- 发信通过 Graph `sendMail` 保存到已发送邮件

---

### 第六阶段：发布流程

✅ **Release Workflow**（PR #23 已合并）
- 支持 `vMAJOR.MINOR.PATCH` 格式 SemVer tag 触发
- 支持手动输入已有 tag 触发发布
- 发布前校验 tag 与 `pubspec.yaml` 版本一致
- 发布前运行 format、analyze、test
- 生成 GitHub Release 和基础 release notes artifact
- 明确 Android、iOS、macOS、Windows、Linux 分阶段发布策略

---

## 未完成功能

### Gmail

- ❌ Gmail token 过期、刷新失败和重新授权提示的真实账号端到端手工验收

---

## 后续 PR 队列

建议按以下顺序继续，每项一个 PR：

1. **Gmail 真实账号验收**：验证 token 过期、刷新失败和重新授权提示

---

## 开发流程

### 本地开发

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### 维护规则

- 每完成一个功能分支或 PR，必须更新 `docs/PROGRESS.md`。
- 每个未完成大项单独实现、单独提交、单独 PR。
- 新页面必须保留正常返回路径；从列表、设置页进入二级页时使用保留导航栈的跳转。
- 用户体验优先级：可返回、可取消、危险操作需确认、敏感信息不展示不记录。

### 发布流程

- 使用 SemVer 版本标签，例如 `v0.1.0`、`v0.2.0`。
- 推送匹配 tag，或手动运行 `Release` workflow 创建 GitHub Release。
- Workflow 不自动合并分支或发布到应用商店。
- 详见 `docs/release/RELEASE.md`。

---

## 隐私基线

- MailNest **不在 SQLite 中存储账号密码和 OAuth token**，全部存储在系统安全存储中。
- MailNest **不默认将邮件内容发送到第三方翻译服务**，需用户显式配置并确认。
- 远程图片默认加载，但用户可显式关闭。

---

## 技术亮点

### 1. 安全存储设计

- 密码和 OAuth token 存储在 `flutter_secure_storage`（iOS Keychain / Android Keystore）
- SQLite 只保存 token 引用，不保存明文凭证

### 2. 邮件正文分层架构

- `EmailBodyParser`：解析原始 RFC822/MIME 内容
- `EmailCharsetDecoder`：处理多种字符集解码
- `EmailHtmlSanitizer`：移除脚本和危险内容
- `EmailBodyRenderer`：按选项渲染正文
- `EmailBodyFallbackView`：解析失败时的友好降级

### 3. 多 Provider 抽象

- 统一 `MailProvider` 接口
- 支持 IMAP/SMTP、Outlook Graph 和 Gmail REST API Provider

### 4. 本地 FTS 全文搜索

- 基于 Drift FTS5 实现
- 支持主题、发件人、收件人、正文全文搜索

### 5. 响应式布局

- 桌面端三栏布局（账号列表 - 邮件列表 - 邮件详情）
- 移动端单栏 + Drawer 导航

---

## 已验证

最近一次主分支合并前，本地已通过：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

说明：测试中仍可能输出 Drift 多数据库 warning，目前不影响通过结果，后续可单独清理测试 provider 覆写。

---

## 开放 PR

- 当前 GitHub 无开放 PR。

---

## 注意事项

- 当前需求文档 `MailNest 项目规划与需求文档.docx` 仍未跟踪，默认不纳入代码 PR。
- 合并 PR 前需要重新确认 `gh` 可访问 GitHub，并检查 CI 状态。
- 远程图片策略以用户最新要求为准：默认加载远程图片；仅在显式关闭远程图片时显示"加载图片"入口。

---

## 参考文档

- [README.md](README.md)：项目简介和开发指南
- [docs/PROGRESS.md](docs/PROGRESS.md)：详细开发进度和 PR 记录
- [docs/EMAIL_BODY_RENDERING.md](docs/EMAIL_BODY_RENDERING.md)：邮件正文渲染模块文档
- [docs/release/RELEASE.md](docs/release/RELEASE.md)：发布检查清单和平台发布策略

---

## 总结

MailNest 已实现完整的多账号邮件客户端核心能力：

- ✅ **账号管理**：多账号分组、多平台（IMAP/Gmail/Outlook）、OAuth 授权与 token 刷新
- ✅ **邮件同步**：多文件夹增量同步、可配置同步范围、同步状态持久化
- ✅ **邮件列表**：真实数据展示、本地+远程搜索、多选批量操作、键盘快捷键、右键菜单
- ✅ **邮件详情**：安全 HTML 渲染、附件下载/批量下载、回复/转发、翻译
- ✅ **写信与发信**：本地+远端草稿同步、SMTP/Gmail/Outlook 发信、附件支持
- ✅ **配置导入导出**：加密导入导出、安全 token 处理、同步范围导出
- ✅ **发布流程**：SemVer tag + GitHub Release workflow

剩余待完成：

1. Gmail 真实账号端到端手工验收
