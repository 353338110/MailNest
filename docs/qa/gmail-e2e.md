# Gmail 真实账号端到端验收

更新时间：2026-06-29

## 前置条件

- 使用专用 Gmail 测试账号，不使用个人主账号。
- Google OAuth Client 已配置 MailNest 使用的桌面 loopback redirect URI 和移动端 deeplink redirect URI。
- 在 Gmail 添加账号页填写 Google OAuth Client ID；如果 Google 返回 `client_secret is missing`，同时填写桌面 OAuth Client Secret。
- 也可启动或构建应用时传入 `--dart-define=GMAIL_OAUTH_CLIENT_ID=<Google OAuth Client ID>` 和 `--dart-define=GMAIL_OAUTH_CLIENT_SECRET=<Google OAuth Client Secret>` 预填。
- 测试账号中准备至少 5 封邮件：普通纯文本、HTML 邮件、含附件邮件、已读邮件、未读邮件。
- 测试账号中准备至少 2 个自定义 label，用于移动/同步验证。
- 本地测试前确认 SQLite、日志和截图中不包含 access token、refresh token、client secret 或授权码。

## 必跑流程

1. 添加 Gmail 账号，完成系统浏览器 OAuth 授权。
2. 确认账号列表显示 Gmail 授权已连接，SQLite 只保存 `oauthTokenRef`。
3. 执行邮件同步，确认 Gmail labels 映射为文件夹并显示在账号下。
4. 打开统一收件箱，确认 Gmail 邮件列表可见，账号标识正确。
5. 打开 Gmail 邮件详情，确认 raw MIME 正文解析正常，HTML/纯文本邮件均可读。
6. 打开含附件邮件，确认附件元信息显示正确，下载动作不会暴露 token。
7. 发送一封 Gmail 邮件，确认收件账号收到邮件，Gmail 已发送中可见。
8. 新建、更新、删除一封草稿，确认 Gmail Draft API 和本地草稿状态一致。
9. 对同一封邮件执行标记已读/未读、星标/取消星标、移动 label、删除到废纸篓。
10. 重新同步，确认本地列表状态与 Gmail 网页端一致。

## Token 与重新授权

1. 使用过期 access token 和有效 refresh token 启动应用，同步应自动刷新 token 并继续。
2. 让 Gmail API 首次返回 401，Provider 应强制刷新一次 token 并重试原请求。
3. 撤销 Google 账号授权或移除 refresh token 后重新同步，UI 应提示重新授权 Gmail。
4. 重新授权时必须使用同一个 Gmail 地址；地址不一致时应拒绝保存并提示。
5. 刷新失败、重新授权失败和同步失败提示不得包含 access token、refresh token、授权码或完整请求体。

## 通过标准

- Gmail 同步、详情、发信、草稿和邮件操作均可在真实账号上跑通。
- token 过期可自动恢复；刷新失败会进入明确的重新授权路径。
- 失败账号不阻塞其他账号同步。
- 本地数据库和日志只出现 token 引用，不出现 token 明文。
- 验收完成后在 `docs/PROGRESS.md` 记录日期、平台、账号类型和结果。
