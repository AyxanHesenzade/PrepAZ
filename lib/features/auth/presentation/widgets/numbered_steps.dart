import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Nömrələnmiş addımlar: istifadəçi nə edəcəyini sıra ilə görür.
class NumberedSteps extends StatelessWidget {
  const NumberedSteps({super.key, required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, step) in steps.indexed) ...[
          if (index > 0) AppSpacing.gapS,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: scheme.primary,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppSpacing.gapM,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(step),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
