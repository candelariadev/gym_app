import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/routine_builder_controller.dart';
import '../../domain/routine_builder_models.dart';
import 'coach_assign_routine_page.dart';
import 'coach_exercise_library_page.dart';

class CoachCreateRoutinePage extends StatefulWidget {
  const CoachCreateRoutinePage({super.key, required this.getExercisesUseCase});

  final GetExercisesUseCase getExercisesUseCase;
  static const routeName = '/coach/create-routine';

  @override
  State<CoachCreateRoutinePage> createState() => _CoachCreateRoutinePageState();
}

class _CoachCreateRoutinePageState extends State<CoachCreateRoutinePage> {
  late final RoutineBuilderController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _controller = RoutineBuilderController();
    _nameController = TextEditingController();
    _durationController = TextEditingController(text: '8');
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _continueToAssignment() {
    final l10n = AppLocalizations.of(context);
    final draft = _controller.draft;
    if (draft.name.trim().isEmpty) {
      _message(l10n.createRoutineNameRequired);
      return;
    }
    if (!draft.hasValidDuration) {
      _message(
        l10n.createRoutineMinimumDuration(RoutineDraft.minimumDurationWeeks),
      );
      return;
    }
    final incomplete = draft.daysBelowMinimumExercises;
    if (incomplete.isNotEmpty) {
      _message(
        l10n.createRoutineIncompleteDays(
          RoutineDraft.minimumExercisesPerDay,
          incomplete.map((day) => _dayLabel(day.day)).join(', '),
        ),
      );
      return;
    }
    final currentArgs = ModalRoute.of(context)?.settings.arguments;
    final preselected = currentArgs is AssignRoutineArgs
        ? currentArgs.preselectedClients
        : const <AssignableClient>[];
    Navigator.of(context).pushNamed(
      CoachAssignRoutinePage.routeName,
      arguments: AssignRoutineArgs(
        routine: draft,
        preselectedClients: preselected,
      ),
    );
  }

  Future<void> _selectExercise() async {
    final selected = await Navigator.of(
      context,
    ).pushNamed(CoachExerciseLibraryPage.routeName, arguments: true);
    if (!mounted || selected is! ExerciseCatalogItem) return;
    final added = _controller.addExerciseFromCatalog(
      selected,
      Localizations.localeOf(context).languageCode,
    );
    if (!added) _message('Este ejercicio ya está incluido en el día.');
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _dayLabel(WorkoutDay day) {
    final spanish = Localizations.localeOf(context).languageCode == 'es';
    return switch (day) {
      WorkoutDay.monday => spanish ? 'Lunes' : 'Monday',
      WorkoutDay.tuesday => spanish ? 'Martes' : 'Tuesday',
      WorkoutDay.wednesday => spanish ? 'Miércoles' : 'Wednesday',
      WorkoutDay.thursday => spanish ? 'Jueves' : 'Thursday',
      WorkoutDay.friday => spanish ? 'Viernes' : 'Friday',
      WorkoutDay.saturday => spanish ? 'Sábado' : 'Saturday',
      WorkoutDay.sunday => spanish ? 'Domingo' : 'Sunday',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final selectedDay = _controller.selectedDay;
        return Scaffold(
          backgroundColor: const Color(0xFFF7F7FB),
          appBar: AppBar(
            title: Text(l10n.trainerCreateWorkoutAction),
            actions: [
              TextButton.icon(
                onPressed: _continueToAssignment,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.saveRoutineAction),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                GymSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GymLabeledField(
                        label: l10n.routineNameLabel,
                        child: TextField(
                          controller: _nameController,
                          maxLength: 120,
                          onChanged: _controller.updateRoutineName,
                          decoration: InputDecoration(
                            hintText: l10n.newRoutineHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      GymLabeledField(
                        label: l10n.durationWeeksLabel,
                        child: TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: _controller.updateDurationWeeks,
                          decoration: const InputDecoration(helperText: '4–52'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                GymSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Días de entrenamiento',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          PopupMenuButton<WorkoutDay>(
                            enabled: _controller.availableDays.isNotEmpty,
                            tooltip: 'Agregar día',
                            onSelected: _controller.addDay,
                            itemBuilder: (_) => _controller.availableDays
                                .map(
                                  (day) => PopupMenuItem(
                                    value: day,
                                    child: Text(_dayLabel(day)),
                                  ),
                                )
                                .toList(growable: false),
                            child: const Chip(
                              avatar: Icon(Icons.add_rounded, size: 18),
                              label: Text('Agregar día'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _controller.draft.days
                            .asMap()
                            .entries
                            .map((entry) {
                              return ChoiceChip(
                                label: Text(_dayLabel(entry.value.day)),
                                selected:
                                    entry.key == _controller.selectedDayIndex,
                                onSelected: (_) =>
                                    _controller.selectDay(entry.key),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                GymSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dayLabel(selectedDay.day),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  l10n.minimumExercisesHint(
                                    RoutineDraft.minimumExercisesPerDay,
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (_controller.draft.days.length > 1)
                            IconButton(
                              tooltip: 'Quitar día',
                              onPressed: _controller.removeSelectedDay,
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      ElevatedButton.icon(
                        onPressed: _selectExercise,
                        icon: const Icon(Icons.search_rounded),
                        label: Text(l10n.searchExerciseAction),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      if (selectedDay.exercises.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.large),
                          child: Text(
                            l10n.emptyRoutineDay,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...selectedDay.exercises.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.medium,
                            ),
                            child: _ExercisePrescriptionCard(
                              key: ValueKey(entry.value.exerciseId),
                              exercise: entry.value,
                              index: entry.key,
                              total: selectedDay.exercises.length,
                              onMoveUp: () => _controller.moveExercise(
                                entry.key,
                                entry.key - 1,
                              ),
                              onMoveDown: () => _controller.moveExercise(
                                entry.key,
                                entry.key + 1,
                              ),
                              onDelete: () => _controller.deleteExercise(
                                entry.value.exerciseId,
                              ),
                              onChanged:
                                  ({
                                    int? sets,
                                    int? reps,
                                    int? restSeconds,
                                    String? notes,
                                  }) {
                                    _controller.updateExercise(
                                      entry.value.exerciseId,
                                      sets: sets,
                                      reps: reps,
                                      restSeconds: restSeconds,
                                      notes: notes,
                                    );
                                  },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExercisePrescriptionCard extends StatefulWidget {
  const _ExercisePrescriptionCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.total,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onChanged,
  });

  final RoutineExerciseDraft exercise;
  final int index;
  final int total;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;
  final void Function({int? sets, int? reps, int? restSeconds, String? notes})
  onChanged;

  @override
  State<_ExercisePrescriptionCard> createState() =>
      _ExercisePrescriptionCardState();
}

class _ExercisePrescriptionCardState extends State<_ExercisePrescriptionCard> {
  late final TextEditingController _sets;
  late final TextEditingController _reps;
  late final TextEditingController _rest;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _sets = TextEditingController(text: '${widget.exercise.sets}');
    _reps = TextEditingController(text: '${widget.exercise.reps}');
    _rest = TextEditingController(text: '${widget.exercise.restSeconds}');
    _notes = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void dispose() {
    _sets.dispose();
    _reps.dispose();
    _rest.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GymSurface(
      padding: const EdgeInsets.all(AppSpacing.medium),
      borderRadius: 14,
      borderColor: const Color(0xFFE7E8F1),
      elevation: GymSurfaceElevation.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.exercise.focus.isNotEmpty)
                      Text(widget.exercise.focus),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.index == 0 ? null : widget.onMoveUp,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                onPressed: widget.index == widget.total - 1
                    ? null
                    : widget.onMoveDown,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  _sets,
                  l10n.setsLabel,
                  100,
                  (value) => widget.onChanged(sets: value),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: _numberField(
                  _reps,
                  l10n.repsLabel,
                  1000,
                  (value) => widget.onChanged(reps: value),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: _numberField(
                  _rest,
                  '${l10n.restLabel} (s)',
                  3600,
                  (value) => widget.onChanged(restSeconds: value),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _notes,
            maxLength: 500,
            onChanged: (value) =>
                widget.onChanged(notes: value.trim().isEmpty ? null : value),
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    int max,
    ValueChanged<int> onChanged,
  ) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onChanged: (value) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed >= 1 && parsed <= max) onChanged(parsed);
    },
    decoration: InputDecoration(labelText: label),
  );
}
