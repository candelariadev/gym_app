import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../application/routine_builder_controller.dart';
import '../../domain/exercise_library_data.dart';
import '../../domain/routine_builder_models.dart';
import 'coach_assign_routine_page.dart';
import 'coach_exercise_library_page.dart';

class CoachCreateRoutinePage extends StatefulWidget {
  const CoachCreateRoutinePage({super.key});

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
    _nameController = TextEditingController(text: _controller.draft.name);
    _durationController =
        TextEditingController(text: '${_controller.draft.durationWeeks}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _saveAndAssign() {
    final draft = _controller.draft;
    if (draft.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega un nombre antes de guardar la rutina.'),
        ),
      );
      return;
    }

    if (!draft.hasMinimumDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'La rutina semanal debe asignarse por al menos ${RoutineDraft.minimumDurationWeeks} semanas.',
          ),
        ),
      );
      return;
    }

    final incompleteDays = draft.daysBelowMinimumExercises;
    if (incompleteDays.isNotEmpty) {
      final labels = incompleteDays.map((day) => day.label).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se puede guardar. Cada dia de la semana debe tener minimo ${RoutineDraft.minimumExercisesPerDay} ejercicios. Revisa: $labels.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      CoachAssignRoutinePage.routeName,
      arguments: AssignRoutineArgs(routine: draft),
    );
  }

  Future<void> _openExerciseLibrary() async {
    final selectedExercise = await Navigator.of(context).pushNamed(
      CoachExerciseLibraryPage.routeName,
    );

    if (!mounted || selectedExercise is! ExerciseLibraryItem) {
      return;
    }

    _controller.addExerciseFromLibrary(selectedExercise);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final selectedDay = _controller.selectedDay;
        if (_nameController.text != _controller.draft.name) {
          _nameController.value = TextEditingValue(
            text: _controller.draft.name,
            selection: TextSelection.collapsed(
              offset: _controller.draft.name.length,
            ),
          );
        }
        final durationText = '${_controller.draft.durationWeeks}';
        if (_durationController.text != durationText) {
          _durationController.value = TextEditingValue(
            text: durationText,
            selection: TextSelection.collapsed(offset: durationText.length),
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
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          label: const Text('Volver'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6A7188),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _saveAndAssign,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Guardar rutina'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _ShellCard(
                    child: Column(
                      children: [
                        _InputBlock(
                          label: 'Nombre de la rutina',
                          child: TextField(
                            controller: _nameController,
                            onChanged: _controller.updateRoutineName,
                            decoration: const InputDecoration(
                              hintText: 'Nueva Rutina',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        _InputBlock(
                          label: 'Duracion (semanas)',
                          child: TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            onChanged: _controller.updateDurationWeeks,
                            decoration: const InputDecoration(
                              hintText: '8',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Se guarda como rutina semanal. Debe durar al menos ${RoutineDraft.minimumDurationWeeks} semanas y cada dia necesita minimo ${RoutineDraft.minimumExercisesPerDay} ejercicios.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6C748D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _controller.draft.days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final day = _controller.draft.days[index];
                        final isSelected = index == _controller.selectedDayIndex;

                        return ChoiceChip(
                          label: Text(day.title),
                          selected: isSelected,
                          onSelected: (_) => _controller.selectDay(index),
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white : const Color(0xFF6C748D),
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: const Color(0xFFEFF1F8),
                          selectedColor: const Color(0xFF5B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _ShellCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDay.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          'Minimo ${RoutineDraft.minimumExercisesPerDay} ejercicios para poder guardar la semana.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6C748D),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _controller.addExercise,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Agregar ejercicio'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 38),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            ElevatedButton.icon(
                              onPressed: _openExerciseLibrary,
                              icon: const Icon(Icons.search_rounded, size: 18),
                              label: const Text('Buscar ejercicio'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 38),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        if (selectedDay.exercises.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.large),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7FC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Todavia no hay ejercicios en este dia. Usa "Buscar ejercicio" para agregar uno.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF80879D),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...selectedDay.exercises.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                                  child: _ExerciseEditorCard(
                                    key: ValueKey(entry.value.id),
                                    dayFocus: selectedDay.focus,
                                    exercise: entry.value,
                                    index: entry.key,
                                    total: selectedDay.exercises.length,
                                    onMoveUp: () => _controller.moveExerciseUp(entry.key),
                                    onMoveDown: () => _controller.moveExerciseDown(entry.key),
                                    onDelete: () =>
                                        _controller.deleteExercise(entry.value.id),
                                    onChanged: ({
                                      String? name,
                                      String? focus,
                                      String? series,
                                      String? repetitions,
                                      String? weight,
                                      String? rest,
                                    }) {
                                      _controller.updateExerciseField(
                                        entry.value.id,
                                        name: name,
                                        focus: focus,
                                        series: series,
                                        repetitions: repetitions,
                                        weight: weight,
                                        rest: rest,
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
          ),
        );
      },
    );
  }
}

class _ShellCard extends StatelessWidget {
  const _ShellCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1B4B),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: child,
    );
  }
}

class _InputBlock extends StatelessWidget {
  const _InputBlock({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6C748D),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ExerciseEditorCard extends StatefulWidget {
  const _ExerciseEditorCard({
    super.key,
    required this.dayFocus,
    required this.exercise,
    required this.index,
    required this.total,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onChanged,
  });

  final String dayFocus;
  final RoutineExerciseDraft exercise;
  final int index;
  final int total;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;
  final void Function({
    String? name,
    String? focus,
    String? series,
    String? repetitions,
    String? weight,
    String? rest,
  }) onChanged;

  @override
  State<_ExerciseEditorCard> createState() => _ExerciseEditorCardState();
}

class _ExerciseEditorCardState extends State<_ExerciseEditorCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _seriesController;
  late final TextEditingController _repetitionsController;
  late final TextEditingController _weightController;
  late final TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _seriesController = TextEditingController(text: widget.exercise.series);
    _repetitionsController =
        TextEditingController(text: widget.exercise.repetitions);
    _weightController = TextEditingController(text: widget.exercise.weight);
    _restController = TextEditingController(text: widget.exercise.rest);
  }

  @override
  void didUpdateWidget(covariant _ExerciseEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_nameController, widget.exercise.name);
    _syncController(_seriesController, widget.exercise.series);
    _syncController(_repetitionsController, widget.exercise.repetitions);
    _syncController(_weightController, widget.exercise.weight);
    _syncController(_restController, widget.exercise.rest);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E8F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator_rounded, color: Color(0xFFC3C7D6)),
              const SizedBox(width: 6),
              Text(
                'Ejercicio',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFA0A5B8),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.index == 0 ? null : widget.onMoveUp,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed:
                    widget.index == widget.total - 1 ? null : widget.onMoveDown,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          TextField(
            controller: _nameController,
            onChanged: (value) => widget.onChanged(name: value),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            widget.exercise.focus.isEmpty ? widget.dayFocus : widget.exercise.focus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4C77FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _seriesController,
            onChanged: (value) => widget.onChanged(series: value),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Series'),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _repetitionsController,
            onChanged: (value) => widget.onChanged(repetitions: value),
            decoration: const InputDecoration(labelText: 'Reps'),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _weightController,
            onChanged: (value) => widget.onChanged(weight: value),
            decoration: const InputDecoration(labelText: 'Peso'),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _restController,
            onChanged: (value) => widget.onChanged(rest: value),
            decoration: const InputDecoration(labelText: 'Descanso'),
          ),
        ],
      ),
    );
  }
}
