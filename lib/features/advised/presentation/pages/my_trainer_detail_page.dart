import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';

class MyTrainerDetailPage extends StatelessWidget {
  const MyTrainerDetailPage({super.key});

  static const routeName = '/advised/trainer-detail';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trainer =
        ModalRoute.of(context)?.settings.arguments as AdvisedTrainer?;
    if (trainer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myTrainerAction)),
        body: Center(child: Text(l10n.trainerSummaryNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(trainer.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TrainerHeader(trainer: trainer),
            const SizedBox(height: AppSpacing.medium),
            GymSectionCard(
              title: l10n.trainerSummaryAboutTitle,
              child: Text(trainer.bio),
            ),
            const SizedBox(height: AppSpacing.medium),
            GymSectionCard(
              title: l10n.trainerSummaryDetailsTitle,
              child: Column(
                children: [
                  GymLabelValue(label: l10n.usernameLabel, value: trainer.user),
                  const SizedBox(height: AppSpacing.small),
                  GymLabelValue(
                    label: l10n.trainerSummaryPlanLabel,
                    value: trainer.plan,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  GymLabelValue(
                    label: l10n.trainerSummaryStatusLabel,
                    value: trainer.status,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  GymLabelValue(
                    label: l10n.trainerSummaryExperienceLabel,
                    value: l10n.trainerSummaryExperienceYears(
                      trainer.experience,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            GymSectionCard(
              title: l10n.trainerSummaryCertificationsTitle,
              child: trainer.certifications.isEmpty
                  ? Text(l10n.valueNotAvailable)
                  : Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.small,
                      children: trainer.certifications
                          .map((item) => GymTag(label: item))
                          .toList(growable: false),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainerHeader extends StatelessWidget {
  const _TrainerHeader({required this.trainer});

  final AdvisedTrainer trainer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return GymSurface(
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            child: Text(trainer.initials, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  trainer.email.isEmpty
                      ? l10n.valueNotAvailable
                      : trainer.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                GymTag(label: l10n.trainerRole),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
