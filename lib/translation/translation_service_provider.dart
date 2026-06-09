import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_translation_service.dart';
import 'translation_service.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return MockTranslationService();
});
