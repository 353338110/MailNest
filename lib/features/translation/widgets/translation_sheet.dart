import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../translation/models/translation_result.dart';
import '../../../translation/translation_service_provider.dart';

class TranslationSheet extends ConsumerStatefulWidget {
  const TranslationSheet({
    super.key,
    required this.sourceText,
    required this.initialTargetLanguage,
    this.onUseTranslation,
  });

  final String sourceText;
  final AppLanguage initialTargetLanguage;
  final ValueChanged<String>? onUseTranslation;

  @override
  ConsumerState<TranslationSheet> createState() => _TranslationSheetState();
}

class _TranslationSheetState extends ConsumerState<TranslationSheet> {
  late AppLanguage _targetLanguage;
  TranslationResult? _result;
  bool _isLoading = false;
  bool _showOriginal = false;
  String? _errorMessage;

  static final List<AppLanguage> _targetLanguages = AppLanguage.values
      .where((language) => language != AppLanguage.system)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _targetLanguage = widget.initialTargetLanguage == AppLanguage.system
        ? AppLanguage.zhCN
        : widget.initialTargetLanguage;
  }

  Future<void> _translate() async {
    final l10n = AppLocalizations.of(context);
    final text = widget.sourceText.trim();
    if (text.isEmpty) {
      setState(() {
        _result = null;
        _errorMessage = l10n.translationSourceEmpty;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await ref.read(translationServiceProvider.future);
      final sourceLanguage =
          await service.detectLanguage(text: text) ?? AppLanguage.en;
      final result = await service.translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: _targetLanguage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _showOriginal = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = l10n.translationFailed(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyTranslation() async {
    final result = _result;
    if (result == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: result.translatedText));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.translationCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = _result;
    final displayedText = result == null
        ? widget.sourceText
        : _showOriginal
        ? result.originalText
        : result.translatedText;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.small,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.translate,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<AppLanguage>(
              initialValue: _targetLanguage,
              decoration: InputDecoration(
                labelText: l10n.targetLanguage,
                border: const OutlineInputBorder(),
              ),
              items: _targetLanguages
                  .map(
                    (language) => DropdownMenuItem(
                      value: language,
                      child: Text(language.displayName),
                    ),
                  )
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (language) {
                      if (language != null) {
                        setState(() {
                          _targetLanguage = language;
                          _result = null;
                          _errorMessage = null;
                        });
                      }
                    },
            ),
            const SizedBox(height: AppSpacing.medium),
            if (_errorMessage case final message?)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: MaterialBanner(
                  content: Text(message),
                  leading: const Icon(Icons.error_outline),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() {
                        _errorMessage = null;
                      }),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              ),
            if (result != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.translate),
                      label: Text(l10n.translatedText),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.article_outlined),
                      label: Text(l10n.originalText),
                    ),
                  ],
                  selected: {_showOriginal},
                  onSelectionChanged: (value) {
                    setState(() {
                      _showOriginal = value.single;
                    });
                  },
                ),
              ),
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: SelectableText(displayedText),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _translate,
                    icon: _isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.translate),
                    label: Text(
                      result == null ? l10n.translate : l10n.translateAgain,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                IconButton.filledTonal(
                  tooltip: l10n.copyTranslation,
                  onPressed: result == null ? null : _copyTranslation,
                  icon: const Icon(Icons.copy_outlined),
                ),
                if (widget.onUseTranslation != null) ...[
                  const SizedBox(width: AppSpacing.small),
                  IconButton.filled(
                    tooltip: l10n.useTranslation,
                    onPressed: result == null
                        ? null
                        : () {
                            widget.onUseTranslation!(result.translatedText);
                            Navigator.of(context).pop();
                          },
                    icon: const Icon(Icons.check),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
