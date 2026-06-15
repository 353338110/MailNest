import 'dart:io';

import 'package:open_filex/open_filex.dart';

class AttachmentOpener {
  static Future<bool> openFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final result = await OpenFilex.open(filePath);

    // Result types: done, fileNotFound, noAppToOpen, permissionDenied, error
    switch (result.type) {
      case ResultType.done:
        return true;
      case ResultType.fileNotFound:
        throw Exception('File not found');
      case ResultType.noAppToOpen:
        throw Exception('No application available to open this file type');
      case ResultType.permissionDenied:
        throw Exception('Permission denied to open file');
      case ResultType.error:
        throw Exception('Error opening file: ${result.message}');
    }
  }
}
