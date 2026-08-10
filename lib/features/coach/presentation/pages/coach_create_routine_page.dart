import 'package:flutter/material.dart';

import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';
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
    _nameController = TextEditingController(text: _controller.draft.name);
    _durationController = TextEditingController(
      text: '${_controller.draft.durationWeeks}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _saveAndAssign() {
    final l10n = AppLocalizations.of(context);
    final draft = _controller.draft;
    if (draft.name.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createRoutineNameRequired)));
      return;
    }

    if (!draft.hasMinimumDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.createRoutineMinimumDuration(
              RoutineDraft.minimumDurationWeeks,
            ),
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
            l10n.createRoutineIncompleteDays(
              RoutineDraft.minimumExercisesPerDay,
              labels,
            ),
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
    final selectedExercise = await Navigator.of(
      context,
    ).pushNamed(CoachExerciseLibraryPage.routeName, arguments: true);

    if (!mounted || selectedExercise is! ExerciseCatalogItem) {
      return;
    }

    _controller.addExerciseFromCatalog(
      selectedExercise,
      Localizations.localeOf(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _saveAndAssign,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: Text(l10n.saveRoutineAction),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  GymSurface(
                    child: Column(
                      children: [
                        GymLabeledField(
                          label: l10n.routineNameLabel,
                          child: TextField(
                            controller: _nameController,
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
                            onChanged: _controller.updateDurationWeeks,
                            decoration: const InputDecoration(hintText: '8'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.weeklyRoutineRules(
                              RoutineDraft.minimumDurationWeeks,
                              RoutineDraft.minimumExercisesPerDay,
                            ),
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
                        final isSelected =
                            index == _controller.selectedDayIndex;

                        return ChoiceChip(
                          label: Text(day.title),
                          selected: isSelected,
                          onSelected: (_) => _controller.selectDay(index),
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6C748D),
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
                  GymSurface(
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
                          l10n.minimumExercisesHint(
                            RoutineDraft.minimumExercisesPerDay,
                          ),
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
                              label: Text(l10n.addExerciseAction),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 38),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            ElevatedButton.icon(
                              onPressed: _openExerciseLibrary,
                              icon: const Icon(Icons.search_rounded, size: 18),
                              label: Text(l10n.searchExerciseAction),
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
                              l10n.emptyRoutineDay,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF80879D),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...selectedDay.exercises.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.medium,
                              ),
                              child: _ExerciseEditorCard(
                                key: ValueKey(entry.value.id),
                                dayFocus: selectedDay.focus,
                                exercise: entry.value,
                                index: entry.key,
                                total: selectedDay.exercises.length,
                                onMoveUp: () =>
                                    _controller.moveExerciseUp(entry.key),
                                onMoveDown: () =>
                                    _controller.moveExerciseDown(entry.key),
                                onDelete: () =>
                                    _controller.deleteExercise(entry.value.id),
                                onChanged:
                                    ({
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
  })
  onChanged;

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
    _repetitionsController = TextEditingController(
      text: widget.exercise.repetitions,
    );
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
    final l10n = AppLocalizations.of(context);

    return GymSurface(
      padding: const EdgeInsets.all(AppSpacing.medium),
      borderRadius: 14,
      borderColor: const Color(0xFFE7E8F1),
      elevation: GymSurfaceElevation.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.drag_indicator_rounded,
                color: Color(0xFFC3C7D6),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.exerciseLabel,
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
                onPressed: widget.index == widget.total - 1
                    ? null
                    : widget.onMoveDown,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          TextField(
            controller: _nameController,
            onChanged: (value) => widget.onChanged(name: value),
            decoration: InputDecoration(labelText: l10n.nameLabel),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            widget.exercise.focus.isEmpty
                ? widget.dayFocus
                : widget.exercise.focus,
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
            decoration: InputDecoration(labelText: l10n.setsLabel),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _repetitionsController,
            onChanged: (value) => widget.onChanged(repetitions: value),
            decoration: InputDecoration(labelText: l10n.repsLabel),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _weightController,
            onChanged: (value) => widget.onChanged(weight: value),
            decoration: InputDecoration(labelText: l10n.weightLabel),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _restController,
            onChanged: (value) => widget.onChanged(rest: value),
            decoration: InputDecoration(labelText: l10n.restLabel),
          ),
        ],
      ),
    );
  }
}
