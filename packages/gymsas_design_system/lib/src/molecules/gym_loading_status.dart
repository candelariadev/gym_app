import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Localized copy is supplied by the host app; colors come from its SaaS theme.
class GymLoadingStatus extends StatelessWidget {
  const GymLoadingStatus({super.key, required this.label, this.message});

  final String label;
  final String? message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: [label, ?message].join('. '),
    child: ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.large),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
