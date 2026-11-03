import 'package:flutter/material.dart';

import '../molecules/gym_loading_status.dart';
import '../theme/app_spacing.dart';

/// Keeps the current screen visible while preventing duplicate interactions.
/// Place in bounded page space, outside scroll views.
class GymLoadingOverlay extends StatelessWidget {
  const GymLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.label,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final String label;
  final String? message;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !isLoading,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ExcludeFocus(
          excluding: isLoading,
          child: ExcludeSemantics(
            excluding: isLoading,
            child: AbsorbPointer(absorbing: isLoading, child: child),
          ),
        ),
        if (isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.45),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Card(
                    child: GymLoadingStatus(label: label, message: message),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
