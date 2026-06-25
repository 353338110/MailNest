# 邮件正文兼容与渲染模块

## 目标

邮件详情页不直接处理 MIME、HTML 清洗、字符集转换或平台渲染差异。正文处理统一拆分到 `lib/mail/body/`，页面只接收 `ParsedEmailBody` 并交给 `EmailBodyRenderer` 渲染。

## 分层

- `EmailBodyParser`：解析原始 RFC822/MIME 内容，输出 `ParsedEmailBody`。
- `EmailCharsetDecoder`：处理 UTF-8、Latin-1、GB2312/GBK/GB18030 等字符集解码。
- `EmailHtmlSanitizer`：移除脚本、事件属性和危险链接；远程图片由渲染选项控制，当前默认加载。
- `EmailBodyRenderer`：按选项渲染正文，支持纯文本优先、远程图片开关和降级展示。
- `EmailBodyRendererFactory`：封装平台渲染策略，后续可在移动端接 WebView，桌面端保持 Flutter 降级。
- `EmailBodyFallbackView`：解析失败、加密邮件或不支持格式时的友好降级。

## 第一阶段范围

- 支持 `text/plain`、`text/html`、`multipart/alternative`、`multipart/mixed`、基础 `multipart/related` 元信息。
- 支持附件和 cid 内嵌图片模型。
- HTML 默认安全清洗，不执行脚本，远程图片默认加载。
- 复杂 HTML 先降级为清洗后的可读纯文本。
- 邮件详情页提供“加载图片”“以纯文本查看”“翻译”入口。

## 后续扩展

- 接入完整 MIME 解析库。
- 接入 Flutter HTML 或 WebView 渲染器。
- 完善 cid 图片替换与附件下载。
- 增加更多字符集和复杂 HTML 邮件测试集。
- 支持签名验证、S/MIME/PGP 解密。
