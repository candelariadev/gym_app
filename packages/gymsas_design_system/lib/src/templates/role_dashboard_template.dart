import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class RoleDashboardTemplate extends StatelessWidget {
  const RoleDashboardTemplate({
    super.key,
    required this.appTitle,
    required this.logoutTooltip,
    required this.greeting,
    required this.roleLabel,
    required this.headline,
    required this.quickActionsTitle,
    required this.metrics,
    required this.content,
    required this.onLogout,
  });

  final String appTitle;
  final String logoutTooltip;
  final String greeting;
  final String roleLabel;
  final String headline;
  final String quickActionsTitle;
  final List<Widget> metrics;
  final List<Widget> content;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            tooltip: logoutTooltip,
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.large),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roleLabel.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          greeting,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          headline,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 700 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSpacing.medium,
                        mainAxisSpacing: AppSpacing.medium,
                        childAspectRatio: columns == 3 ? 1.3 : 1.05,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: metrics,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Text(quickActionsTitle, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.medium),
                  ...content,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
