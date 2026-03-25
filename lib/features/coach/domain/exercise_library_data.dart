class ExerciseLibraryItem {
  const ExerciseLibraryItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.level,
    required this.series,
    required this.repetitions,
    required this.weight,
    required this.rest,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String level;
  final String series;
  final String repetitions;
  final String weight;
  final String rest;
}

class ExerciseLibraryMockData {
  const ExerciseLibraryMockData._();

  static const muscleGroups = [
    'Todos',
    'Pecho',
    'Espalda',
    'Piernas',
    'Brazos',
    'Hombros',
    'Core',
  ];

  static const equipments = [
    'Todos',
    'Barra',
    'Mancuernas',
    'Maquina',
    'Peso corporal',
    'Cable',
  ];

  static const exercises = [
    ExerciseLibraryItem(
      id: 'library-1',
      name: 'Press de Banca',
      muscleGroup: 'Pecho',
      equipment: 'Barra',
      level: 'Intermedio',
      series: '4',
      repetitions: '8-10',
      weight: '60 kg',
      rest: '90 s',
    ),
    ExerciseLibraryItem(
      id: 'library-2',
      name: 'Sentadilla',
      muscleGroup: 'Piernas',
      equipment: 'Barra',
      level: 'Intermedio',
      series: '4',
      repetitions: '8-10',
      weight: '80 kg',
      rest: '120 s',
    ),
    ExerciseLibraryItem(
      id: 'library-3',
      name: 'Peso Muerto',
      muscleGroup: 'Espalda',
      equipment: 'Barra',
      level: 'Avanzado',
      series: '4',
      repetitions: '6-8',
      weight: '100 kg',
      rest: '120 s',
    ),
    ExerciseLibraryItem(
      id: 'library-4',
      name: 'Curl de Biceps',
      muscleGroup: 'Brazos',
      equipment: 'Mancuernas',
      level: 'Principiante',
      series: '3',
      repetitions: '10-12',
      weight: '12 kg',
      rest: '60 s',
    ),
    ExerciseLibraryItem(
      id: 'library-5',
      name: 'Press Militar',
      muscleGroup: 'Hombros',
      equipment: 'Mancuernas',
      level: 'Intermedio',
      series: '4',
      repetitions: '8-10',
      weight: '16 kg',
      rest: '75 s',
    ),
    ExerciseLibraryItem(
      id: 'library-6',
      name: 'Plancha',
      muscleGroup: 'Core',
      equipment: 'Peso corporal',
      level: 'Principiante',
      series: '3',
      repetitions: '30-45 s',
      weight: '',
      rest: '45 s',
    ),
  ];
}
