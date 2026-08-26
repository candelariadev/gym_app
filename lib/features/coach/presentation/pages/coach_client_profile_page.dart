import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/routine_builder_models.dart';
import '../localization/client_catalog_localizations.dart';
import 'coach_create_routine_page.dart';
import 'coach_routine_detail_page.dart';

class CoachClientProfilePage extends StatelessWidget {
  const CoachClientProfilePage({super.key});

  static const routeName = '/coach/client-profile';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final client = ModalRoute.of(context)?.settings.arguments as TrainerClient?;
    if (client == null) {
      return Scaffold(body: Center(child: Text(l10n.clientNotFound)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              CoachCreateRoutinePage.routeName,
              arguments: AssignRoutineArgs(
                preselectedClients: [
                  AssignableClient(
                    id: client.id,
                    userId: client.user,
                    name: client.name,
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.assignRoutineAction),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(client: client),
            const SizedBox(height: AppSpacing.medium),
            GymSectionCard(
              title: l10n.clientDetailsTitle,
              child: _ClientDetails(client: client),
            ),
            const SizedBox(height: AppSpacing.medium),
            GymSectionCard(
              title: l10n.assignedRoutinesTitle,
              subtitle: l10n.assignedRoutinesSubtitle,
              child: client.assignedWorkouts.isEmpty
                  ? Text(l10n.assignedRoutinesEmpty)
                  : Column(
                      children: client.assignedWorkouts
                          .map(
                            (workout) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.small,
                              ),
                              child: _WorkoutCard(
                                workout: workout,
                                clientName: client.name,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.client});

  final TrainerClient client;

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
            child: Text(
              client.initials,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.email ?? l10n.valueNotAvailable,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                GymTag(label: l10n.clientStatusLabel(client.status)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  const _ClientDetails({required this.client});

  final TrainerClient client;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final birthdate = client.birthdate;
    final createdAt = client.createdAt;
    return Column(
      children: [
        GymLabelValue(label: l10n.usernameLabel, value: client.user),
        const SizedBox(height: AppSpacing.small),
        GymLabelValue(
          label: l10n.birthdateLabel,
          value: birthdate == null
              ? l10n.valueNotAvailable
              : material.formatCompactDate(birthdate.toLocal()),
        ),
        const SizedBox(height: AppSpacing.small),
        GymLabelValue(
          label: l10n.currentWeightLabel,
          value: client.weight == null
              ? l10n.valueNotAvailable
              : l10n.weightKilograms(client.weight!),
        ),
        const SizedBox(height: AppSpacing.small),
        GymLabelValue(
          label: l10n.clientCreatedAtLabel,
          value: createdAt == null
              ? l10n.valueNotAvailable
              : material.formatCompactDate(createdAt.toLocal()),
        ),
        const SizedBox(height: AppSpacing.medium),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.goalsTitle,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: client.goals.isEmpty
              ? Text(l10n.goalsEmpty)
              : Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: client.goals
                      .map((goal) => GymTag(label: goal))
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout, required this.clientName});

  final AssignedWorkout workout;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = workout.days;
    final startDate = workout.startDate;
    final durationWeeks = workout.durationWeeks;
    final metadata = startDate != null && durationWeeks != null
        ? l10n.workoutWeeklyMetadata(
            days.length,
            MaterialLocalizations.of(
              context,
            ).formatCompactDate(startDate.toLocal()),
            workout.totalExercises,
            durationWeeks,
          )
        : l10n.workoutMetadata(
            workout.totalExercises,
            l10n.workoutDaysCount(days.length),
          );
    return GymWorkoutSummaryCard(
      title: workout.name,
      statusLabel: l10n.clientStatusLabel(workout.status),
      metadata: metadata,
      tags: days
          .map(
            (day) => l10n.workoutMetadata(
              day.exercises.length,
              l10n.workoutDayLabel(day.day),
            ),
          )
          .toList(growable: false),
      actionLabel: l10n.viewRoutineDetails,
      onTap: () => Navigator.of(context).pushNamed(
        CoachRoutineDetailPage.routeName,
        arguments: CoachRoutineDetailArgs(
          workout: workout,
          clientName: clientName,
        ),
      ),
    );
  }
}
