import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/routine_builder_models.dart';
import '../controllers/trainer_clients_controller.dart';
import '../localization/client_catalog_localizations.dart';

class CoachAssignRoutinePage extends StatefulWidget {
  const CoachAssignRoutinePage({
    super.key,
    required this.getTrainerClients,
    required this.assignWorkout,
  });

  static const routeName = '/coach/assign-routine';
  final GetTrainerClientsUseCase getTrainerClients;
  final AssignWorkoutUseCase assignWorkout;

  @override
  State<CoachAssignRoutinePage> createState() => _CoachAssignRoutinePageState();
}

class _CoachAssignRoutinePageState extends State<CoachAssignRoutinePage> {
  late final TrainerClientsController _clientsController;
  final Set<String> _selectedUserIds = <String>{};
  late DateTime _startDate;
  bool _preselectionApplied = false;
  bool _publishing = false;
  bool _published = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _clientsController = TrainerClientsController(
      getTrainerClients: widget.getTrainerClients,
    )..addListener(_refresh);
    _clientsController.load();
  }

  @override
  void dispose() {
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
    setState(() => _publishing = true);
    var completed = 0;
    try {
      for (final userId in _selectedUserIds) {
        await widget.assignWorkout(
          routine.toCommand(userId: userId, startDate: _startDate),
        );
        completed++;
      }
      if (!mounted) return;
      setState(() => _published = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).routinePublished(completed),
          ),
        ),
      );
    } on WorkoutException catch (error) {
      if (!mounted) return;
      final detail = error.message?.trim();
      final prefix = completed > 0
          ? '$completed asignaciones completadas. '
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$prefix${detail?.isNotEmpty == true ? detail : _errorMessage(error.code)}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  String _errorMessage(WorkoutErrorCode code) => switch (code) {
    WorkoutErrorCode.invalidInput =>
      'Revisa los días, ejercicios y valores de la rutina.',
    WorkoutErrorCode.unauthorized =>
      'Tu sesión expiró. Inicia sesión nuevamente.',
    WorkoutErrorCode.forbidden =>
      'No tienes permisos para asignar esta rutina.',
    WorkoutErrorCode.conflict =>
      'La rutina cambió o ya existe. Actualiza e intenta de nuevo.',
    WorkoutErrorCode.quotaExceeded =>
      'Alcanzaste el límite de rutinas de tu plan.',
    WorkoutErrorCode.timeout ||
    WorkoutErrorCode.network ||
    WorkoutErrorCode.unavailable =>
      'No fue posible conectar con el servicio. Intenta nuevamente.',
    _ => 'No fue posible asignar la rutina.',
  };

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
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(title: Text(l10n.assignRoutineTitle)),
      body: routine == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.large),
                child: Text('Primero crea una rutina para poder asignarla.'),
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
                            onTap: _pickStartDate,
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
      return const Text('No hay clientes activos para asignar.');
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
              onChanged: _publishing
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
          Text('${routine.days.length} días de entrenamiento'),
        ],
      ),
    );
  }
}
