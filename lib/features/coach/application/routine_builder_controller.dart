import 'package:flutter/foundation.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';

import '../domain/routine_builder_models.dart';

class RoutineBuilderController extends ChangeNotifier {
  RoutineBuilderController()
    : _draft = RoutineDraft(
        name: 'Nueva Rutina',
        durationWeeks: 8,
        days: List.generate(
          7,
          (index) => RoutineDayDraft(
            label: 'Dia ${index + 1}',
            focus: _defaultFocuses[index],
            exercises: index == 0
                ? [
                    RoutineExerciseDraft(
                      id: 'exercise-1',
                      name: 'Press de Banca',
                      focus: 'Pecho',
                      series: '4',
                      repetitions: '8-10',
                      weight: '60 kg',
                      rest: '90 s',
                    ),
                  ]
                : [],
          ),
        ),
      );

  static const List<String> _defaultFocuses = [
    'Pecho y Triceps',
    'Espalda y Biceps',
    'Pierna',
    'Hombro y Core',
    'Gluteo',
    'Cardio',
    'Movilidad',
  ];

  RoutineDraft _draft;
  int _selectedDayIndex = 0;
  int _exerciseSeed = 2;

  RoutineDraft get draft => _draft;
  int get selectedDayIndex => _selectedDayIndex;
  RoutineDayDraft get selectedDay => _draft.days[_selectedDayIndex];

  void updateRoutineName(String value) {
    _draft = RoutineDraft(
      name: value,
      durationWeeks: _draft.durationWeeks,
      days: _draft.days,
    );
    notifyListeners();
  }

  void updateDurationWeeks(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return;
    }

    _draft = RoutineDraft(
      name: _draft.name,
      durationWeeks: parsed,
      days: _draft.days,
    );
    notifyListeners();
  }

  void selectDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
  }

  void addExercise() {
    final exercises = List<RoutineExerciseDraft>.from(selectedDay.exercises)
      ..add(
        RoutineExerciseDraft(
          id: 'exercise-${_exerciseSeed++}',
          name: 'Nuevo ejercicio',
          focus: selectedDay.focus,
          series: '3',
          repetitions: '10-12',
          weight: '',
          rest: '60 s',
        ),
      );

    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void addExerciseFromCatalog(ExerciseCatalogItem item, String languageCode) {
    final exercises = List<RoutineExerciseDraft>.from(selectedDay.exercises)
      ..add(
        RoutineExerciseDraft(
          id: 'exercise-${_exerciseSeed++}',
          name: item.name.resolve(languageCode),
          focus: item.primaryMuscles.isEmpty
              ? selectedDay.focus
              : item.primaryMuscles.first,
          series: '3',
          repetitions: '10-12',
          weight: '',
          rest: '60 s',
        ),
      );

    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void deleteExercise(String exerciseId) {
    final exercises = selectedDay.exercises
        .where((exercise) => exercise.id != exerciseId)
        .toList();
    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void moveExerciseUp(int index) {
    if (index <= 0) {
      return;
    }

    final exercises = List<RoutineExerciseDraft>.from(selectedDay.exercises);
    final item = exercises.removeAt(index);
    exercises.insert(index - 1, item);
    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void moveExerciseDown(int index) {
    final exercises = List<RoutineExerciseDraft>.from(selectedDay.exercises);
    if (index >= exercises.length - 1) {
      return;
    }

    final item = exercises.removeAt(index);
    exercises.insert(index + 1, item);
    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void updateExerciseField(
    String exerciseId, {
    String? name,
    String? focus,
    String? series,
    String? repetitions,
    String? weight,
    String? rest,
  }) {
    final exercises = selectedDay.exercises
        .map(
          (exercise) => exercise.id == exerciseId
              ? exercise.copyWith(
                  name: name,
                  focus: focus,
                  series: series,
                  repetitions: repetitions,
                  weight: weight,
                  rest: rest,
                )
              : exercise,
        )
        .toList();

    _replaceSelectedDay(selectedDay.copyWith(exercises: exercises));
  }

  void _replaceSelectedDay(RoutineDayDraft updatedDay) {
    final days = List<RoutineDayDraft>.from(_draft.days);
    days[_selectedDayIndex] = updatedDay;
    _draft = RoutineDraft(
      name: _draft.name,
      durationWeeks: _draft.durationWeeks,
      days: days,
    );
    notifyListeners();
  }
}

extension on RoutineDayDraft {
  RoutineDayDraft copyWith({
    String? label,
    String? focus,
    List<RoutineExerciseDraft>? exercises,
  }) {
    return RoutineDayDraft(
      label: label ?? this.label,
      focus: focus ?? this.focus,
      exercises: exercises ?? this.exercises,
    );
  }
}
