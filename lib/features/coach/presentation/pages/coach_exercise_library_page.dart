import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/exercise_library_data.dart';

class CoachExerciseLibraryPage extends StatefulWidget {
  const CoachExerciseLibraryPage({super.key});

  static const routeName = '/coach/exercise-library';

  @override
  State<CoachExerciseLibraryPage> createState() =>
      _CoachExerciseLibraryPageState();
}

class _CoachExerciseLibraryPageState extends State<CoachExerciseLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscleGroup = 'Todos';
  String _selectedEquipment = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final exercises = ExerciseLibraryMockData.exercises.where((exercise) {
      final matchesQuery =
          query.isEmpty || exercise.name.toLowerCase().contains(query);
      final matchesMuscle = _selectedMuscleGroup == 'Todos' ||
          exercise.muscleGroup == _selectedMuscleGroup;
      final matchesEquipment = _selectedEquipment == 'Todos' ||
          exercise.equipment == _selectedEquipment;
      return matchesQuery && matchesMuscle && matchesEquipment;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
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
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_alt_outlined, size: 18),
                    label: const Text('Filtros'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Buscar ejercicios...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _FilterSection(
                      title: 'Grupo Muscular',
                      values: ExerciseLibraryMockData.muscleGroups,
                      selectedValue: _selectedMuscleGroup,
                      onSelected: (value) {
                        setState(() {
                          _selectedMuscleGroup = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _FilterSection(
                      title: 'Equipo',
                      values: ExerciseLibraryMockData.equipments,
                      selectedValue: _selectedEquipment,
                      onSelected: (value) {
                        setState(() {
                          _selectedEquipment = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (exercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.large),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'No se encontraron ejercicios con esos filtros.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7B8194),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...exercises.map(
                        (exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                          child: _ExerciseLibraryCard(
                            exercise: exercise,
                            onAdd: () => Navigator.of(context).pop(exercise),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6C748D),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: selectedValue == value,
                  onSelected: (_) => onSelected(value),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: selectedValue == value
                            ? Colors.white
                            : const Color(0xFF6C748D),
                        fontWeight: FontWeight.w700,
                      ),
                  backgroundColor: const Color(0xFFF3F4F9),
                  selectedColor: const Color(0xFF5B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ExerciseLibraryCard extends StatelessWidget {
  const _ExerciseLibraryCard({
    required this.exercise,
    required this.onAdd,
  });

  final ExerciseLibraryItem exercise;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = switch (exercise.level) {
      'Avanzado' => const Color(0xFFFF7A7A),
      'Intermedio' => const Color(0xFFF6C45A),
      _ => const Color(0xFF75C98C),
    };

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 118,
            decoration: const BoxDecoration(
              color: Color(0xFFEDEBFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            alignment: Alignment.center,
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 42,
                    color: Color(0xFF7F78FF),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      exercise.level,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(text: exercise.muscleGroup),
                    _Tag(text: exercise.equipment),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF61677C),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
