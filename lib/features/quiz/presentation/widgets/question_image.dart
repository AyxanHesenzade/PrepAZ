import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../offline/presentation/offline_providers.dart';
import '../quiz_providers.dart';

/// Sualın şəkli. Yüklənərkən yer tutucu, alınmasa "Şəkil yüklənmədi" göstərir, sual yenə həll oluna bilir.
/// Toxunanda tam ekranda böyüdülür. [compact] nəticə siyahısı üçün kiçik ölçüdür.
class QuestionImage extends ConsumerWidget {
  const QuestionImage(this.path, {super.key, this.compact = false});

  final String path;
  final bool compact;

  static const _placeholderHeight = 140.0;
  static const _compactMaxHeight = 90.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Şəkil telefonda yüklənibsə, internetsiz fayldan açılır; yoxsa imzalı link ilə serverdən.
    final local = ref.watch(localImagePathProvider(path));
    return local.when(
      loading: () =>
          const _Placeholder(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, _) => _fromServer(context, ref),
      data: (file) =>
          file == null ? _fromServer(context, ref) : _fromPhone(context, file),
    );
  }

  Widget _fromPhone(BuildContext context, String file) {
    return GestureDetector(
      onTap: () => _zoom(context, _FileImage(file)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: compact ? _compactMaxHeight : double.infinity,
        ),
        child: _Frame(child: _FileImage(file, width: double.infinity)),
      ),
    );
  }

  Widget _fromServer(BuildContext context, WidgetRef ref) {
    final url = ref.watch(questionImageUrlProvider(path));
    return url.when(
      loading: () =>
          const _Placeholder(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, _) => const _Placeholder(child: _FailedLabel()),
      data: (link) => GestureDetector(
        onTap: () => _zoom(context, _NetworkImage(link)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: compact ? _compactMaxHeight : double.infinity,
          ),
          child: _Frame(child: _NetworkImage(link, width: double.infinity)),
        ),
      ),
    );
  }

  void _zoom(BuildContext context, Widget image) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(child: _Frame(child: image)),
              ),
            ),
            Positioned(
              top: AppSpacing.s,
              right: AppSpacing.s,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Şəkillərin fonu ağdır: tünd temada da formullar oxunaqlı qalır.
class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.white, child: child);
}

class _FileImage extends StatelessWidget {
  const _FileImage(this.file, {this.width});

  final String file;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(file),
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const SizedBox(
        height: QuestionImage._placeholderHeight,
        child: Center(child: _FailedLabel()),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage(this.url, {this.width});

  final String url;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const SizedBox(
              height: QuestionImage._placeholderHeight,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (_, _, _) => const SizedBox(
        height: QuestionImage._placeholderHeight,
        child: Center(child: _FailedLabel()),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: QuestionImage._placeholderHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _FailedLabel extends StatelessWidget {
  const _FailedLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.broken_image_outlined),
        AppSpacing.gapS,
        Text(
          AppStrings.imageFailed,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
