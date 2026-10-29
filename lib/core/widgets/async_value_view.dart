import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/app_exception.dart';
import 'error_view.dart';

/// Hər FutureProvider/StreamProvider üçün eyni yüklənir / xəta / data məntiqi.
/// Ekranlarda `when(...)` təkrar yazılmır.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(message: errorMessage(error), onRetry: onRetry),
    );
  }
}
