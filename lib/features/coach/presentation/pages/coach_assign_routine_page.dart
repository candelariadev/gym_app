import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/routine_builder_models.dart';
import '../controllers/trainer_clients_controller.dart';
import '../localization/client_catalog_localizations.dart';
import '../../application/routine_assignment_controller.dart';
import '../../../notifications/application/notifications_controller.dart';
import '../../../notifications/presentation/routine_notification_panel.dart';
import '../../../notifications/presentation/notification_localizations.dart';

class CoachAssignRoutinePage extends StatefulWidget {
  const CoachAssignRoutinePage({
    super.key,
    required this.getTrainerClients,
    required this.assignWorkout,
    this.notifications,
    this.isCurrentAccount,
  });

  static const routeName = '/coach/assign-routine';
  final GetTrainerClientsUseCase getTrainerClients;
  final AssignWorkoutUseCase assignWorkout;
  final NotificationsController? notifications;
  final bool Function()? isCurrentAccount;

  @override
  State<CoachAssignRoutinePage> createState() => _CoachAssignRoutinePageState();
}

class _CoachAssignRoutinePageState extends State<CoachAssignRoutinePage> {
  late final TrainerClientsController _clientsController;
  final Set<String> _selectedUserIds = <String>{};
  late DateTime _startDate;
  bool _preselectionApplied = false;
  late final RoutineAssignmentController _assignment;
  bool get _publishing => _assignment.publishing;
  bool _published = false;

  @override
  void initState() {
    super.initState();
    _assignment = RoutineAssignmentController(
      assignWorkout: widget.assignWorkout,
      notifications: widget.notifications?.repository,
      isCurrentAccount: widget.isCurrentAccount,
    )..addListener(_refresh);
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _clientsController = TrainerClientsController(
      getTrainerClients: widget.getTrainerClients,
    )..addListener(_refresh);
    _clientsController.load();
  }

  @override
  void dispose() {
    _assignment
      ..removeListener(_refresh)
      ..dispose();
    _clientsController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null && mounted) setState(() => _startDate = selected);
  }

  Future<void> _publish(RoutineDraft routine) async {
    if (_publishing || _selectedUserIds.isEmpty) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final candidates = <String, AssignableClient>{
      if (args is AssignRoutineArgs)
        for (final c in args.preselectedClients) c.userId: c,
      for (final c in _clientsController.clients)
        c.user: AssignableClient(id: c.id, userId: c.user, name: c.name),
    };
    final clients = _selectedUserIds
        .map((id) => candidates[id])
        .whereType<AssignableClient>()
        .toList();
    if (clients.length != _selectedUserIds.length) return;
    await _assignment.publish(routine, clients, _startDate);
    if (!mounted || widget.isCurrentAccount?.call() == false) return;
    final completed = _assignment.confirmed.length,
        l10n = AppLocalizations.of(context);
    setState(
      () => _published = _selectedUserIds.every(
        _assignment.confirmed.containsKey,
      ),
    );
    final message = _assignment.error == null
        ? l10n.routinePublished(completed)
        : completed > 0
        ? l10n.routineAssignmentPartial(completed)
        : _errorMessage(_assignment.error!);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(WorkoutErrorCode code) {
    final l = AppLocalizations.of(context);
    return switch (code) {
      WorkoutErrorCode.invalidInput => l.routineAssignmentInvalid,
      WorkoutErrorCode.unauthorized => l.routineAssignmentAuth,
      WorkoutErrorCode.forbidden => l.routineAssignmentForbidden,
      WorkoutErrorCode.conflict => l.routineAssignmentConflict,
      WorkoutErrorCode.quotaExceeded => l.routineAssignmentQuota,
      WorkoutErrorCode.timeout ||
      WorkoutErrorCode.network ||
      WorkoutErrorCode.unavailable => l.routineAssignmentNetwork,
      _ => l.routineAssignmentError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is AssignRoutineArgs
        ? rawArgs
        : const AssignRoutineArgs();
    final routine = args.routine;
    if (!_preselectionApplied) {
      _preselectionApplied = true;
      _selectedUserIds.addAll(
        args.preselectedClients.map((client) => client.userId),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.assignRoutineTitle)),
      body: routine == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(l10n.routineAssignmentMissing),
              ),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.medium),
                children: [
                  _RoutineSummary(routine: routine),
                  const SizedBox(height: AppSpacing.medium),
                  GymSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GymLabeledField(
                          label: l10n.startDateLabel,
                          child: InkWell(
                            onTap:
                                _publishing || _assignment.confirmed.isNotEmpty
                                ? null
                                : _pickStartDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_month_rounded),
                              ),
                              child: Text(
                                DateFormat.yMMMd(
                                  Localizations.localeOf(
                                    context,
                                  ).toLanguageTag(),
                                ).format(_startDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        Text(
                          l10n.selectClientsTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        _clientList(l10n),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          l10n.selectedClientsCount(_selectedUserIds.length),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  if (_assignment.confirmed.isNotEmpty &&
                      widget.notifications != null)
                    RoutineNotificationPanel(
                      controller: widget.notifications!,
                      targets: _assignment.confirmed.values.toList(),
                    ),
                  if (_assignment.notificationError != null)
                    GymStatusMessage(
                      label: l10n.notificationError(
                        _assignment.notificationError!,
                      ),
                      warning: true,
                    ),
                  ElevatedButton.icon(
                    onPressed: _published
                        ? () => Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst)
                        : _publishing || _selectedUserIds.isEmpty
                        ? null
                        : () => _publish(routine),
                    icon: _publishing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _published
                                ? Icons.check_circle_rounded
                                : Icons.send_rounded,
                          ),
                    label: Text(
                      _published
                          ? l10n.commonFinish
                          : l10n.publishRoutineAction,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _clientList(AppLocalizations l10n) {
    final clients = _clientsController.clients;
    if (_clientsController.isLoading && clients.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_clientsController.errorCode != null && clients.isEmpty) {
      return Column(
        children: [
          Text(l10n.clientCatalogError(_clientsController.errorCode!)),
          TextButton(
            onPressed: _clientsController.retry,
            child: Text(l10n.exerciseRetry),
          ),
        ],
      );
    }
    if (clients.isEmpty) {
      return Text(l10n.routineAssignmentNoClients);
    }
    return Column(
      children: clients
          .map((client) {
            final selected = _selectedUserIds.contains(client.user);
            return CheckboxListTile(
              value: selected,
              contentPadding: EdgeInsets.zero,
              title: Text(client.name),
              subtitle: Text(client.user),
              secondary: CircleAvatar(child: Text(client.initials)),
              onChanged:
                  _publishing ||
                      _published ||
                      _assignment.confirmed.containsKey(client.user)
                  ? null
                  : (_) => setState(() {
                      if (selected) {
                        _selectedUserIds.remove(client.user);
                      } else {
                        _selectedUserIds.add(client.user);
                      }
                    }),
            );
          })
          .toList(growable: false),
    );
  }
}

class _RoutineSummary extends StatelessWidget {
  const _RoutineSummary({required this.routine});

  final RoutineDraft routine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GymSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            routine.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            l10n.routineMetadata(routine.durationWeeks, routine.totalExercises),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(l10n.routineTrainingDays(routine.days.length)),
        ],
      ),
    );
  }
}
