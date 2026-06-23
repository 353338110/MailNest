# 邮件乱码与附件下载问题修复

## 问题描述

1. **邮件标题和内容显示乱码**：标题显示为 "æ­£å½å…¬å"å€™éž¸å¿" 等乱码字符
2. **附件下载失败**：点击下载附件时显示 "missing context" 错误

## 根本原因

### 1. 字符编码问题
- 邮件使用 GBK/GB2312 编码（中文邮件常见编码）
- iconv 解码时参数不当，导致解码失败
- 回退到 UTF-8 解码时，将 GBK 字节当作 UTF-8 处理，产生乱码

### 2. 附件下载上下文缺失
- `MailAttachmentInfo` 模型缺少 `accountId`、`folderId`、`messageUid` 字段
- 从缓存加载邮件时，这些信息未传递给附件对象
- 下载附件时无法获取必需的上下文参数

## 修复方案

### 1. 改进字符编码解码

**文件**: `lib/mail/body/email_charset_decoder.dart`

```dart
// 修改 iconv 调用，添加 -c 参数忽略无效字符
final result = await Process.run(
  executable,
  ['-f', charset, '-t', 'utf-8', '-c', input.path],
  stdoutEncoding: null,  // 直接获取字节数组，避免二次编码
);
if (result.exitCode == 0 && result.stdout is List<int>) {
  return utf8.decode(result.stdout as List<int>, allowMalformed: true);
}
```

**关键改进**：
- 添加 `-c` 参数：跳过无法转换的字符，提高容错性
- `stdoutEncoding: null`：直接获取字节而非字符串，避免 Dart 的自动 UTF-8 解码干扰

### 2. 改进乱码检测逻辑

**文件**: `lib/mail/repository/mail_repository.dart`

```dart
static bool _looksMojibake(String? value) {
  if (value == null || value.isEmpty) {
    return false;
  }
  // 检查替换字符（表示编码失败）
  if (value.contains('�')) {
    return true;
  }
  // 检查常见的乱码模式（GBK 字节被错误解释为 Latin-1）
  final mojibakePatterns = [
    RegExp(r'[àáâãäå][^a-zA-Z\s]{2,}'),
    RegExp(r'æ[^a-zA-Z\s]{2,}'),
    RegExp(r'ç[^a-zA-Z\s]{2,}'),
    RegExp(r'è[^a-zA-Z\s]{2,}'),
    RegExp(r'é[^a-zA-Z\s]{2,}'),
    RegExp(r'ï¿½'),
  ];
  for (final pattern in mojibakePatterns) {
    if (pattern.hasMatch(value)) {
      return true;
    }
  }
  return false;
}
```

**关键改进**：
- 使用正则模式匹配乱码特征，而非简单的字符检查
- 避免误判正常的拉丁字符或其他语言字符

### 3. 附件信息携带上下文

**文件**: `lib/mail/models/mail_detail.dart`

```dart
class MailAttachmentInfo {
  const MailAttachmentInfo({
    required this.id,
    required this.fileName,
    required this.mimeType,
    this.size,
    this.contentId,
    this.downloaded = false,
    this.localPath,
    this.accountId,      // 新增
    this.folderId,       // 新增
    this.messageUid,     // 新增
  });

  // ... 其他字段
  final String? accountId;
  final String? folderId;
  final int? messageUid;
}
```

### 4. 从缓存加载时填充上下文

**文件**: `lib/mail/repository/mail_repository.dart`

```dart
Future<List<MailAttachmentInfo>> _attachmentsFromCache({
  required String accountId,
  required String folderId,
  required int uid,
}) async {
  final rows = await database.getLocalMailAttachments(
    accountId: accountId,
    folderName: folderId,
    uid: uid,
  );
  return rows
      .map(
        (row) => MailAttachmentInfo(
          id: row.id,
          fileName: row.fileName,
          mimeType: row.mimeType,
          size: row.size,
          contentId: row.contentId,
          downloaded: row.downloaded,
          localPath: row.localPath,
          accountId: accountId,      // 传递上下文
          folderId: folderId,        // 传递上下文
          messageUid: uid,           // 传递上下文
        ),
      )
      .toList(growable: false);
}
```

### 5. 附件下载优先使用内部上下文

**文件**: `lib/features/mail/pages/mail_detail_page.dart`

```dart
Future<void> _handleTap() async {
  // ... 前面代码

  // 优先从附件对象获取上下文，回退到 widget 参数
  final accountId = widget.attachment.accountId ?? widget.accountId;
  final folderId = widget.attachment.folderId ?? widget.folderId;
  final uid = widget.attachment.messageUid ?? 
              (widget.uid != null ? int.tryParse(widget.uid!) : null);

  if (accountId == null || folderId == null || uid == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot download: missing context')),
      );
    }
    return;
  }

  // ... 下载代码
}
```

## 影响范围

### 修改的文件
1. `lib/mail/models/mail_detail.dart` - 附件模型新增字段
2. `lib/mail/repository/mail_repository.dart` - 填充附件上下文，改进乱码检测
3. `lib/mail/mime/mime_parser.dart` - 解析时填充 messageUid
4. `lib/features/mail/pages/mail_detail_page.dart` - 下载时优先使用内部上下文
5. `lib/mail/body/email_charset_decoder.dart` - 改进 iconv 调用

### 影响的功能
- ✅ 邮件详情显示（编码修复后正确显示中文）
- ✅ 附件下载（上下文传递后可正常下载）
- ✅ 缓存邮件加载（兼容新字段）

## 测试建议

1. **GBK/GB2312 邮件测试**
   - 打开使用 GBK 编码的中文邮件
   - 验证标题、发件人、正文是否正确显示中文

2. **附件下载测试**
   - 从缓存打开邮件（二次打开）
   - 点击附件下载
   - 验证下载成功且文件可打开

3. **边界情况测试**
   - 测试没有附件的邮件
   - 测试多附件邮件
   - 测试各种编码的邮件（UTF-8, ISO-8859-1, GBK, Big5）

## 注意事项

1. **iconv 依赖**：修复依赖系统的 iconv 工具，在 macOS/Linux 系统通常预装
2. **向后兼容**：新增的字段为可选，不影响已有数据
3. **性能影响**：乱码检测增加了正则匹配，对长文本可能有轻微性能影响
