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
    this.onRefresh,
    this.logoUrl,
    this.dashboardHeroUrl,
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
  final Future<void> Function()? onRefresh;
  final String? logoUrl;
  final String? dashboardHeroUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logoUrl != null && logoUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  logoUrl!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
            ],
            Flexible(child: Text(appTitle, overflow: TextOverflow.ellipsis)),
          ],
        ),
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
        child: RefreshIndicator(
          onRefresh: onRefresh ?? () async {},
          notificationPredicate: (_) => onRefresh != null,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        image:
                            dashboardHeroUrl == null ||
                                dashboardHeroUrl!.isEmpty
                            ? null
                            : DecorationImage(
                                image: NetworkImage(dashboardHeroUrl!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  colorScheme.primary.withValues(alpha: 0.58),
                                  BlendMode.srcOver,
                                ),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roleLabel.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary.withValues(
                                alpha: 0.8,
                              ),
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
                              color: colorScheme.onPrimary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxColumns = constraints.maxWidth >= 700 ? 3 : 2;
                        final columns = metrics.length < maxColumns
                            ? metrics.length
                            : maxColumns;
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
                    Text(
                      quickActionsTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ...content,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
