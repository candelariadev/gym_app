import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';

class MyProgressPage extends StatelessWidget {
  const MyProgressPage({super.key});

  static const routeName = '/advised/progress';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProgressAction)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          _headerCard(context, l10n),
          const SizedBox(height: AppSpacing.medium),
          _emptyState(context),
        ],
      ),
    );
  }

  Widget _headerCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myProgressAction,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              l10n.myProgressActionDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            Icon(Icons.insights_rounded, size: 44),
            SizedBox(height: AppSpacing.medium),
            Text('Aquí inicia tu widget de progreso.'),
          ],
        ),
      ),
    );
  }
}
