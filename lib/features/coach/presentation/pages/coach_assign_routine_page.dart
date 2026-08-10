import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/routine_builder_models.dart';
import '../../infrastructure/in_memory_routine_catalog.dart';
import '../controllers/trainer_clients_controller.dart';
import '../localization/client_catalog_localizations.dart';

class CoachAssignRoutinePage extends StatefulWidget {
  const CoachAssignRoutinePage({super.key, required this.getTrainerClients});

  static const routeName = '/coach/assign-routine';

  final GetTrainerClientsUseCase getTrainerClients;

  @override
  State<CoachAssignRoutinePage> createState() => _CoachAssignRoutinePageState();
}

class _CoachAssignRoutinePageState extends State<CoachAssignRoutinePage> {
  final Set<String> _selectedClientIds = <String>{};
  late final TrainerClientsController _clientsController;
  String? _selectedRoutineKey;
  bool _notifyClients = true;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final args = _normalizeArgs(ModalRoute.of(context)?.settings.arguments);
    final allClients = _clientsController.clients;
    final routines = _buildRoutineCatalog(args.routine);
    final selectedRoutine = _resolveSelectedRoutine(routines);
    final theme = Theme.of(context);

    if (_selectedClientIds.isEmpty && args.preselectedClients.isNotEmpty) {
      _selectedClientIds.addAll(
        args.preselectedClients.map((client) => client.id),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                      ),
                      label: Text(l10n.commonBack),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6A7188),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              GymSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.assignRoutineTitle,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedRoutine?.name ??
                                    l10n.selectSavedRoutine,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF7B8194),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    GymLabeledField(
                      label: l10n.startDateLabel,
                      child: TextFormField(
                        initialValue: '23/03/2026',
                        decoration: const InputDecoration(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    GymLabeledField(
                      label: l10n.durationWeeksLabel,
                      child: TextFormField(
                        initialValue:
                            '${selectedRoutine?.durationWeeks ?? RoutineDraft.minimumDurationWeeks}',
                        decoration: const InputDecoration(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      l10n.availableRoutinesTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C748D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...routines.map(
                      (routine) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: _RoutineSelectionCard(
                          routine: routine,
                          isSelected:
                              _routineKey(routine) == _selectedRoutineKey,
                          onSelect: () {
                            setState(() {
                              _selectedRoutineKey = _routineKey(routine);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      l10n.selectClientsTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C748D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 260),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7F0)),
                      ),
                      child: _clientsController.isLoading && allClients.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : _clientsController.errorCode != null &&
                                allClients.isEmpty
                          ? _ClientLoadError(
                              message: l10n.clientCatalogError(
                                _clientsController.errorCode!,
                              ),
                              retryLabel: l10n.exerciseRetry,
                              onRetry: _clientsController.retry,
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: allClients.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: Color(0xFFEDEF5A),
                              ),
                              itemBuilder: (context, index) {
                                final client = allClients[index];
                                final isSelected = _selectedClientIds.contains(
                                  client.id,
                                );

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedClientIds.remove(client.id);
                                      } else {
                                        _selectedClientIds.add(client.id);
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: isSelected
                                        ? const Color(0xFFF4F1FF)
                                        : Colors.transparent,
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              17,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            client.initials,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.small),
                                        Expanded(
                                          child: Text(
                                            client.name,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons
                                                    .radio_button_unchecked_rounded,
                                          color: isSelected
                                              ? const Color(0xFF5B5CF6)
                                              : const Color(0xFFC0C4D2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      l10n.selectedClientsCount(_selectedClientIds.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C748D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: _notifyClients,
                            onChanged: (value) {
                              setState(() {
                                _notifyClients = value ?? true;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.sendNotificationTitle),
                            subtitle: Text(l10n.sendNotificationDescription),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.medium),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF0FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.summaryTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                _SummaryLine(
                                  label: l10n.routineLabel,
                                  value:
                                      selectedRoutine?.name ?? l10n.noSelection,
                                ),
                                _SummaryLine(
                                  label: l10n.startLabel,
                                  value: '22 de marzo de 2026',
                                ),
                                _SummaryLine(
                                  label: l10n.durationLabel,
                                  value: l10n.weeksValue(
                                    selectedRoutine?.durationWeeks ?? 0,
                                  ),
                                ),
                                _SummaryLine(
                                  label: l10n.exercisesLabel,
                                  value:
                                      '${selectedRoutine?.totalExercises ?? 0}',
                                ),
                                _SummaryLine(
                                  label: l10n.clientsLabel,
                                  value: '${_selectedClientIds.length}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.commonCancel),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPublished
                                ? () {
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  }
                                : _selectedClientIds.isEmpty ||
                                      selectedRoutine == null
                                ? null
                                : () {
                                    setState(() {
                                      _isPublished = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.routinePublished(
                                            _selectedClientIds.length,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            icon: Icon(
                              _isPublished
                                  ? Icons.check_circle_rounded
                                  : Icons.send_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _isPublished
                                  ? l10n.commonFinish
                                  : l10n.publishRoutineAction,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AssignRoutineArgs _normalizeArgs(Object? rawArgs) {
    if (rawArgs is AssignRoutineArgs) {
      return rawArgs;
    }

    return const AssignRoutineArgs();
  }

  List<RoutineDraft> _buildRoutineCatalog(RoutineDraft? incomingRoutine) {
    final routines = List<RoutineDraft>.from(
      InMemoryRoutineCatalog.savedRoutines,
    );
    if (incomingRoutine != null) {
      routines.insert(0, incomingRoutine);
    }
    if (_selectedRoutineKey == null && routines.isNotEmpty) {
      _selectedRoutineKey = _routineKey(incomingRoutine ?? routines.first);
    }
    return routines;
  }

  RoutineDraft? _resolveSelectedRoutine(List<RoutineDraft> routines) {
    for (final routine in routines) {
      if (_routineKey(routine) == _selectedRoutineKey) {
        return routine;
      }
    }
    return routines.isEmpty ? null : routines.first;
  }

  String _routineKey(RoutineDraft routine) {
    return routine.id.isNotEmpty ? routine.id : routine.name;
  }
}

class _ClientLoadError extends StatelessWidget {
  const _ClientLoadError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.small),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '- $label: $value',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF55607F)),
      ),
    );
  }
}

class _RoutineSelectionCard extends StatelessWidget {
  const _RoutineSelectionCard({
    required this.routine,
    required this.isSelected,
    required this.onSelect,
  });

  final RoutineDraft routine;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = routine.focusTags;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF4F1FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF5B5CF6) : const Color(0xFFE5E7F0),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isSelected
                ? const Color(0xFF5B5CF6)
                : const Color(0xFFC0C4D2),
          ),
          title: Text(
            routine.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => GymTag(
                      label: tag,
                      backgroundColor: const Color(0xFFEAF0FF),
                      foregroundColor: const Color(0xFF4C77FF),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          trailing: TextButton(
            onPressed: onSelect,
            child: Text(isSelected ? l10n.selectedAction : l10n.commonUse),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.routineMetadata(
                  routine.durationWeeks,
                  routine.totalExercises,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6C748D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            ...routine.days.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...day.exercises.map(
                        (exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '- ${exercise.name} - ${exercise.series} x ${exercise.repetitions}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF61677C),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
