import 'dart:convert';
import 'dart:io';

/// Decodes transfer-encoded bytes into text without logging mail content.
abstract class EmailCharsetDecoder {
  Future<String> decode({required List<int> bytes, required String? charset});
}

class BasicEmailCharsetDecoder implements EmailCharsetDecoder {
  const BasicEmailCharsetDecoder();

  @override
  Future<String> decode({
    required List<int> bytes,
    required String? charset,
  }) async {
    if (bytes.isEmpty) {
      return '';
    }
    final normalized = (charset ?? 'utf-8')
        .toLowerCase()
        .replaceAll('"', '')
        .replaceAll('_', '-')
        .trim();
    try {
      return switch (normalized) {
        'us-ascii' || 'ascii' => ascii.decode(bytes, allowInvalid: true),
        'iso-8859-1' || 'latin1' || 'latin-1' => latin1.decode(bytes),
        'iso-8859-2' || 'latin2' || 'latin-2' => latin1.decode(bytes),
        'windows-1252' || 'cp1252' => latin1.decode(bytes),
        'gb2312' ||
        'gb-2312-80' ||
        'gbk' ||
        'x-gbk' ||
        'cp936' ||
        'gb18030' ||
        'big5' ||
        'big-5' ||
        'shift-jis' ||
        'shift_jis' ||
        'sjis' ||
        'euc-kr' ||
        'euckr' ||
        'euc-jp' ||
        'eucjp' ||
        'iso-2022-jp' => await _decodeWithIconv(bytes, normalized),
        _ => utf8.decode(bytes, allowMalformed: true),
      };
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  Future<String> _decodeWithIconv(List<int> bytes, String charset) async {
    final input = await File(
      '${Directory.systemTemp.path}/mailnest-mime-'
      '${DateTime.now().microsecondsSinceEpoch}.bin',
    ).create();
    try {
      await input.writeAsBytes(bytes, flush: true);
      for (final executable in const ['/usr/bin/iconv', 'iconv']) {
        try {
          final result = await Process.run(
            executable,
            ['-f', charset, '-t', 'utf-8', input.path],
            stdoutEncoding: utf8,
            stderrEncoding: utf8,
          );
          if (result.exitCode == 0) {
            return result.stdout.toString();
          }
        } on Object {
          continue;
        }
      }
    } on Object {
      // Some sandboxed platforms may not expose iconv. Load the message with a
      // lossy fallback rather than failing the detail page.
    } finally {
      if (await input.exists()) {
        await input.delete();
      }
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}
