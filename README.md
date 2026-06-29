# MailNest

[中文](#中文) | [English](#english)

MailNest is a local-first, privacy-focused multi-account email client built with Flutter.

MailNest 是一个本地优先、注重隐私的多账号邮件客户端。它把账号配置、凭证、邮件缓存和附件尽量保存在用户自己的设备上，不依赖自建后端服务。

---

## 中文

### 项目作用

MailNest 用来把多个邮箱账号集中到一个客户端中管理，适合需要同时处理个人邮箱、工作邮箱、Gmail、Outlook、QQ、网易或其他 IMAP/SMTP 邮箱的用户。

核心目标：

- **统一收件箱**：在一个界面查看多个账号、多个分组的邮件。
- **本地优先**：邮件缓存、附件、账号元数据保存在本机。
- **隐私优先**：密码、授权码、OAuth token 使用系统安全存储，不写入 SQLite。
- **多平台运行**：基于 Flutter，目标覆盖 Android、iOS、Windows、macOS 和 Linux。
- **无后端依赖**：客户端直接连接邮箱服务商，不需要 MailNest 自建服务器。

### 当前功能

- 多账号管理：新增、编辑、删除、启用/停用账号。
- 账号分组：按个人、工作或自定义分组管理账号。
- 邮箱协议：支持 IMAP/SMTP、Gmail OAuth、Outlook OAuth。
- 邮件同步：支持多文件夹增量同步、同步状态记录、失败提示和重新同步。
- 邮件列表：支持统一收件箱、账号/分组视图、本地全文搜索、多选操作。
- 邮件详情：支持安全 HTML 渲染、图片、附件、回复、转发、标记已读/未读、星标、移动和删除。
- 写信与草稿：支持本地草稿、附件、SMTP 发信、Gmail/Outlook 发信能力。
- 配置备份：支持加密导入/导出账号配置。
- 国际化：基于 ARB 文件维护多语言文案，并生成 Flutter `AppLocalizations`。

### 使用方式

#### 1. 准备环境

需要安装 Flutter SDK，并确认目标平台环境已经配置完成。

```sh
flutter doctor
flutter pub get
```

如果数据库或生成文件发生变化，运行：

```sh
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

#### 2. 启动应用

桌面端示例：

```sh
flutter run -d macos
```

也可以替换为其他已配置设备：

```sh
flutter devices
flutter run -d <device-id>
```

#### 3. 添加邮箱账号

在应用中进入 **添加邮箱账号**：

1. 选择邮箱类型：QQ 邮箱、网易邮箱、Gmail、Outlook 或自定义邮箱。
2. 普通邮箱填写 IMAP/SMTP 地址、端口、用户名和授权码或密码。
3. Gmail 使用 Google OAuth 授权。
4. Outlook 使用 Microsoft OAuth 授权。
5. 设置显示名称和账号分组。
6. 保存账号后执行同步。

#### 4. Gmail OAuth 配置

Gmail 需要在 Google Cloud Console 中创建 OAuth Client。桌面端通常应选择 **Desktop app / 桌面设备** 类型。

可以在添加 Gmail 账号页面手动填写 OAuth Client ID，也可以在运行或构建时预填：

```sh
flutter run -d macos \
  --dart-define=GMAIL_OAUTH_CLIENT_ID=your-google-client-id \
  --dart-define=GMAIL_OAUTH_CLIENT_SECRET=your-google-client-secret
```

说明：

- `GMAIL_OAUTH_CLIENT_ID` 必填。
- `GMAIL_OAUTH_CLIENT_SECRET` 对部分桌面 OAuth Client 是必需的。
- OAuth token 和可选 client secret 会写入系统安全存储，不写入 SQLite。
- 如果 Google 提示应用尚未完成验证，需要把测试账号加入 OAuth consent screen 的测试用户，或完成 Google 应用验证。

#### 5. 日常操作

- **同步邮件**：点击账号或分组旁的同步按钮。
- **查看账号**：在左侧账号区展开账号，进入 Inbox、Sent、Drafts、Trash 等文件夹。
- **查看分组**：分组视图中会显示当前收件箱来自哪个账号。
- **搜索邮件**：使用搜索入口进行本地全文搜索。
- **批量处理**：长按或多选邮件后执行删除、标记已读/未读、星标等操作。
- **写信**：进入写信页，选择发件账号，填写收件人、主题、正文和附件后发送。
- **附件**：在邮件详情中下载并用系统默认方式打开附件。
- **备份/恢复**：在设置中导出加密配置，或导入已有加密配置。

### 项目架构

```text
lib/
├── app/                    # 应用入口、主题、国际化配置
├── core/                   # 数据库、安全存储、平台能力等基础设施
├── features/               # 面向用户的功能模块和页面
│   ├── accounts/           # 账号管理、OAuth 授权
│   ├── backup/             # 配置导入导出
│   ├── drafts/             # 草稿功能
│   ├── home/               # 首页、导航、账号/分组视图
│   ├── mail/               # 邮件列表、详情、组件
│   ├── search/             # 搜索
│   ├── sent/               # 已发送邮件
│   ├── settings/           # 设置
│   └── translation/        # 翻译相关界面
├── l10n/                   # ARB 多语言文案和生成的本地化代码
├── mail/                   # 邮件核心领域层
│   ├── body/               # 正文解析与安全渲染
│   ├── errors/             # 邮件错误和安全错误展示
│   ├── mime/               # MIME 解析
│   ├── models/             # 邮件领域模型
│   ├── provider/           # IMAP、Gmail、Outlook 等服务商适配
│   ├── repository/         # 邮件数据访问和同步仓储
│   └── services/           # 邮件业务服务
└── translation/            # 翻译服务模型和仓储
```

分层说明：

- **表现层**：`lib/features/*`，负责页面、交互和状态展示。
- **业务层**：`lib/mail/services` 与相关 controller，负责同步、发送、解析和操作流程。
- **数据层**：`lib/mail/repository` 和 Drift 数据库，负责本地缓存、查询和状态持久化。
- **服务商适配层**：`lib/mail/provider`，封装 IMAP、Gmail、Outlook 等不同接口差异。
- **基础设施层**：`lib/core`，提供 SQLite、Secure Storage、平台工具等能力。
- **国际化层**：`lib/l10n`，通过 ARB 文件维护多语言文案。

### 开发与验证

常用命令：

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

发布前建议至少执行：

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### 发布

MailNest 使用 SemVer tag，例如 `v0.1.0`、`v0.2.0`。

推送匹配格式的 tag，或手动运行 GitHub Actions 中的 `Release` workflow，会创建 GitHub Release 和发布说明。发布流程不会自动合并分支，也不会自动发布到应用商店。

更多发布细节见 [docs/release/RELEASE.md](docs/release/RELEASE.md)。

### 隐私基线

- MailNest 不把账号密码、授权码或 OAuth token 存入 SQLite。
- 默认不把邮件正文发送给第三方翻译服务。
- 附件和邮件缓存保存在本机。
- 当前目标不包含 Flutter Web，也不提供云端同步后端。

---

## English

### What MailNest Does

MailNest is a local-first, privacy-focused email client for managing multiple mail accounts in one place. It is designed for users who need a unified inbox across personal, work, Gmail, Outlook, QQ, NetEase, or custom IMAP/SMTP accounts.

Main goals:

- **Unified inbox**: View accounts and account groups from one client.
- **Local-first storage**: Keep account metadata, mail cache, and attachments on the device.
- **Privacy-focused credentials**: Store passwords, app passwords, and OAuth tokens in secure storage, not SQLite.
- **Cross-platform app**: Built with Flutter for Android, iOS, Windows, macOS, and Linux.
- **No MailNest backend**: The client connects directly to mail providers.

### Features

- Account management: add, edit, delete, enable, and disable accounts.
- Account grouping: organize accounts by personal, work, or custom groups.
- Providers: IMAP/SMTP, Gmail OAuth, and Outlook OAuth.
- Sync: multi-folder incremental sync, sync status tracking, failure messages, and resync.
- Mail list: unified inbox, account/group views, local full-text search, and multi-select actions.
- Mail detail: safe HTML rendering, images, attachments, reply, forward, read/unread, star, move, and delete.
- Compose: local drafts, attachments, SMTP sending, Gmail sending, and Outlook sending.
- Backup: encrypted account configuration import/export.
- Localization: ARB-based strings with generated Flutter `AppLocalizations`.

### How To Use

#### 1. Prepare the environment

Install Flutter SDK and verify your target platform setup.

```sh
flutter doctor
flutter pub get
```

When generated files need to be refreshed, run:

```sh
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

#### 2. Run the app

Desktop example:

```sh
flutter run -d macos
```

For other configured devices:

```sh
flutter devices
flutter run -d <device-id>
```

#### 3. Add an email account

Open **Add email account** in the app:

1. Choose QQ Mail, NetEase Mail, Gmail, Outlook, or Custom Mail.
2. For regular mailboxes, enter IMAP/SMTP host, port, username, and password or app password.
3. For Gmail, complete Google OAuth authorization.
4. For Outlook, complete Microsoft OAuth authorization.
5. Set a display name and account group.
6. Save the account and start syncing.

#### 4. Gmail OAuth setup

Gmail requires an OAuth Client from Google Cloud Console. Desktop builds should usually use a **Desktop app** OAuth client type.

You can enter the OAuth Client ID on the Gmail account page, or prefill it at runtime/build time:

```sh
flutter run -d macos \
  --dart-define=GMAIL_OAUTH_CLIENT_ID=your-google-client-id \
  --dart-define=GMAIL_OAUTH_CLIENT_SECRET=your-google-client-secret
```

Notes:

- `GMAIL_OAUTH_CLIENT_ID` is required.
- `GMAIL_OAUTH_CLIENT_SECRET` may be required by some desktop OAuth clients.
- OAuth tokens and the optional client secret are stored through secure storage, not SQLite.
- If Google blocks access because the app is unverified, add the account as a test user in the OAuth consent screen or complete Google app verification.

#### 5. Daily operations

- **Sync mail**: Click the sync action near an account or group.
- **Browse accounts**: Expand an account in the sidebar and open Inbox, Sent, Drafts, Trash, and other folders.
- **Browse groups**: Group views show which account each message belongs to.
- **Search mail**: Use the search entry for local full-text search.
- **Batch actions**: Select messages and delete, mark read/unread, or star them.
- **Compose mail**: Pick a sender account, add recipients, subject, body, and attachments, then send.
- **Open attachments**: Download attachments from mail detail and open them with the system default app.
- **Backup and restore**: Export encrypted configuration or import an existing encrypted backup from Settings.

### Architecture

```text
lib/
├── app/                    # App entry, theme, localization wiring
├── core/                   # Database, secure storage, platform utilities
├── features/               # User-facing features and screens
│   ├── accounts/           # Account management and OAuth
│   ├── backup/             # Configuration import/export
│   ├── drafts/             # Drafts
│   ├── home/               # Home page, navigation, accounts/groups
│   ├── mail/               # Mail list, detail, widgets
│   ├── search/             # Search
│   ├── sent/               # Sent mail
│   ├── settings/           # Settings
│   └── translation/        # Translation UI
├── l10n/                   # ARB localization files and generated code
├── mail/                   # Core mail domain layer
│   ├── body/               # Body parsing and safe rendering
│   ├── errors/             # Mail errors and safe error messages
│   ├── mime/               # MIME parsing
│   ├── models/             # Mail domain models
│   ├── provider/           # IMAP, Gmail, Outlook adapters
│   ├── repository/         # Mail data access and sync repositories
│   └── services/           # Mail business services
└── translation/            # Translation models and repository
```

Layer responsibilities:

- **Presentation layer**: `lib/features/*` handles screens, interactions, and UI state.
- **Business layer**: `lib/mail/services` and controllers handle sync, send, parsing, and workflows.
- **Data layer**: `lib/mail/repository` and Drift persist local cache, queries, and sync state.
- **Provider layer**: `lib/mail/provider` isolates IMAP, Gmail, Outlook, and provider-specific APIs.
- **Infrastructure layer**: `lib/core` provides SQLite, secure storage, and platform tools.
- **Localization layer**: `lib/l10n` maintains multilingual copy through ARB files.

### Development

Common commands:

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Recommended release checks:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### Releases

MailNest uses SemVer tags such as `v0.1.0` and `v0.2.0`.

Pushing a matching tag, or manually running the `Release` workflow with an existing tag, creates a GitHub Release and release notes. The workflow does not automatically merge branches or publish to app stores.

See [docs/release/RELEASE.md](docs/release/RELEASE.md) for the release checklist, version requirements, and platform rollout strategy.

### Privacy Baseline

- MailNest does not store account passwords, app passwords, or OAuth tokens in SQLite.
- MailNest does not send email content to third-party translation services by default.
- Attachments and email cache are stored locally.
- Flutter Web and cloud backend sync are outside the current scope.
