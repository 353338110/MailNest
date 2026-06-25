import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/services/attachment_service.dart';

void main() {
  group('DownloadCancelToken', () {
    test('initial state is not cancelled', () {
      final token = DownloadCancelToken();
      expect(token.isCancelled, isFalse);
    });

    test('cancel sets isCancelled to true', () {
      final token = DownloadCancelToken();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });

    test('cancel is idempotent', () {
      final token = DownloadCancelToken();
      token.cancel();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });
  });

  group('DownloadProgressCallback', () {
    test('callback receives received and total bytes', () {
      int? lastReceived;
      int? lastTotal;

      void onProgress(int received, int? total) {
        lastReceived = received;
        lastTotal = total;
      }

      onProgress(100, 1000);
      expect(lastReceived, 100);
      expect(lastTotal, 1000);

      onProgress(500, 1000);
      expect(lastReceived, 500);
      expect(lastTotal, 1000);
    });

    test('callback accepts null total for unknown size', () {
      int? lastReceived;
      int? lastTotal;
      var called = false;

      void onProgress(int received, int? total) {
        called = true;
        lastReceived = received;
        lastTotal = total;
      }

      onProgress(256, null);
      expect(called, isTrue);
      expect(lastReceived, 256);
      expect(lastTotal, isNull);
    });
  });

  group('AttachmentDownloadErrorType', () {
    test('cancelled is a valid error type', () {
      expect(
        AttachmentDownloadErrorType.values,
        contains(AttachmentDownloadErrorType.cancelled),
      );
    });
  });
}
