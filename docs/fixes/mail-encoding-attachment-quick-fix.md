# 邮件乱码与附件下载修复

## 修复内容

### 1. 邮件乱码修复
- **改进 iconv 解码**：修正 Process.run 调用，使用临时文件传递数据
- **自动清除乱码缓存**：检测到乱码时清除缓存，强制重新解码
- **优化乱码检测**：使用正则模式匹配，避免误判

### 2. 附件下载修复  
- **附件携带上下文**：`MailAttachmentInfo` 新增 `accountId`、`folderId`、`messageUid` 字段
- **从缓存填充上下文**：加载附件时自动填充上下文信息
- **优先使用内部上下文**：下载时优先使用附件对象内的上下文

## 使用方法

打开显示乱码的邮件，应用会：
1. 检测到乱码
2. 自动清除缓存
3. 重新从服务器获取并正确解码

附件下载会自动使用正确的上下文信息。

## 修改的文件

1. `lib/mail/body/email_charset_decoder.dart` - iconv 解码
2. `lib/mail/models/mail_detail.dart` - 附件模型
3. `lib/mail/repository/mail_repository.dart` - 乱码检测和缓存清除
4. `lib/core/database/app_database.dart` - 清除缓存方法
5. `lib/mail/mime/mime_parser.dart` - 填充 UID
6. `lib/features/mail/pages/mail_detail_page.dart` - 下载逻辑
