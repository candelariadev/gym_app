import 'package:flutter/foundation.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

import '../domain/routine_builder_models.dart';

class RoutineBuilderController extends ChangeNotifier {
  RoutineBuilderController()
    : _draft = const RoutineDraft(
        name: '',
        durationWeeks: 8,
        days: [RoutineDayDraft(day: WorkoutDay.monday, exercises: [])],
      );

  RoutineDraft _draft;
  int _selectedDayIndex = 0;

  RoutineDraft get draft => _draft;
  int get selectedDayIndex => _selectedDayIndex;
  RoutineDayDraft get selectedDay => _draft.days[_selectedDayIndex];
  List<WorkoutDay> get availableDays => WorkoutDay.values
      .where((day) => !_draft.days.any((scheduled) => scheduled.day == day))
      .toList(growable: false);

  void updateRoutineName(String value) {
    _replaceDraft(name: value);
  }

  void updateDurationWeeks(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) _replaceDraft(durationWeeks: parsed);
  }

  void selectDay(int index) {
    if (index < 0 || index >= _draft.days.length) return;
    _selectedDayIndex = index;
    notifyListeners();
  }

  void addDay(WorkoutDay day) {
    if (_draft.days.any((item) => item.day == day)) return;
    final days = [
      ..._draft.days,
      RoutineDayDraft(day: day, exercises: const []),
    ]..sort((left, right) => left.day.index.compareTo(right.day.index));
    _replaceDraft(days: days);
    _selectedDayIndex = days.indexWhere((item) => item.day == day);
    notifyListeners();
  }

  void removeSelectedDay() {
    if (_draft.days.length == 1) return;
    final days = [..._draft.days]..removeAt(_selectedDayIndex);
    _selectedDayIndex = _selectedDayIndex.clamp(0, days.length - 1);
    _replaceDraft(days: days);
  }

  bool addExerciseFromCatalog(ExerciseCatalogItem item, String languageCode) {
    if (selectedDay.exercises.any(
      (exercise) => exercise.exerciseId == item.exerciseId,
    )) {
      return false;
    }
    final exercises = [
      ...selectedDay.exercises,
      RoutineExerciseDraft(
        exerciseId: item.exerciseId,
        name: item.name.resolve(languageCode),
        focus: item.primaryMuscles.isEmpty ? '' : item.primaryMuscles.first,
        sets: 3,
        reps: 10,
        restSeconds: 60,
      ),
    ];
    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
    return true;
  }

  void deleteExercise(String exerciseId) {
    _replaceSelectedDay(
      selectedDay.copyWith(
        exercises: selectedDay.exercises
            .where((exercise) => exercise.exerciseId != exerciseId)
            .toList(growable: false),
      ),
    );
  }

  void moveExercise(int from, int to) {
    final exercises = [...selectedDay.exercises];
    if (from < 0 ||
        from >= exercises.length ||
        to < 0 ||
        to >= exercises.length) {
      return;
    }
    final item = exercises.removeAt(from);
    exercises.insert(to, item);
    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void updateExercise(
    String exerciseId, {
    int? sets,
    int? reps,
    int? restSeconds,
    String? notes,
  }) {
    final exercises = selectedDay.exercises
        .map(
          (exercise) => exercise.exerciseId == exerciseId
              ? exercise.copyWith(
                  sets: sets,
                  reps: reps,
                  restSeconds: restSeconds,
                  notes: notes,
                )
              : exercise,
        )
        .toList(growable: false);
    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void _replaceSelectedDay(RoutineDayDraft updatedDay) {
    final days = [..._draft.days];
    days[_selectedDayIndex] = updatedDay;
    _replaceDraft(days: days);
  }

  void _replaceDraft({
    String? name,
    int? durationWeeks,
    List<RoutineDayDraft>? days,
  }) {
    _draft = RoutineDraft(
      name: name ?? _draft.name,
      durationWeeks: durationWeeks ?? _draft.durationWeeks,
      days: days ?? _draft.days,
    );
    notifyListeners();
  }
}
