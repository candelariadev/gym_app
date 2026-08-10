import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/exercise_catalog_controller.dart';
import '../localization/exercise_catalog_localizations.dart';

class CoachExerciseLibraryPage extends StatefulWidget {
  const CoachExerciseLibraryPage({
    super.key,
    required this.getExercisesUseCase,
    this.selectionMode = false,
  });

  static const routeName = '/coach/exercise-library';

  final GetExercisesUseCase getExercisesUseCase;
  final bool selectionMode;

  @override
  State<CoachExerciseLibraryPage> createState() =>
      _CoachExerciseLibraryPageState();
}

class _CoachExerciseLibraryPageState extends State<CoachExerciseLibraryPage> {
  late final ExerciseCatalogController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ExerciseCatalogController(
      getExercises: widget.getExercisesUseCase,
    )..loadInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exerciseCatalogTitle)),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _controller.updateSearch(value);
                        setState(() {});
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.exerciseSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _controller.updateSearch('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear_rounded),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  IconButton.filledTonal(
                    tooltip: l10n.exerciseFiltersAction,
                    onPressed: () => _showFilters(context),
                    icon: Badge(
                      isLabelVisible: _controller.hasActiveFilters,
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    l10n.exerciseResultsCount(_controller.total),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (_controller.hasActiveFilters)
                    TextButton(
                      onPressed: _controller.clearFilters,
                      child: Text(l10n.exerciseClearFilters),
                    ),
                ],
              ),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_controller.isLoading && _controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorCode != null && _controller.items.isEmpty) {
      return _CatalogMessage(
        icon: Icons.cloud_off_rounded,
        title: l10n.exerciseCatalogError(_controller.errorCode!),
        actionLabel: l10n.exerciseRetry,
        onAction: _controller.retry,
      );
    }
    if (_controller.items.isEmpty) {
      return _CatalogMessage(
        icon: Icons.search_off_rounded,
        title: l10n.exerciseEmptyTitle,
        description: l10n.exerciseEmptyDescription,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.loadInitial,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 300) {
            _controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _controller.items.length + 1,
          itemBuilder: (context, index) {
            if (index == _controller.items.length) {
              return _PaginationFooter(controller: _controller);
            }
            final exercise = _controller.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: _ExerciseCatalogCard(
                exercise: exercise,
                onDetails: () => _showDetails(context, exercise),
                onAdd: widget.selectionMode
                    ? () => Navigator.of(context).pop(exercise)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showFilters(BuildContext context) async {
    var level = _controller.filters.level;
    var category = _controller.filters.category;
    var equipment = _controller.filters.equipment;
    var muscle = _controller.filters.muscle;
    final result = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = AppLocalizations.of(context);
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.exerciseFiltersAction,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  GymDropdownField<String>(
                    label: l10n.exerciseLevelLabel,
                    value: level ?? '',
                    options: _options(l10n, _levels),
                    onChanged: (value) => setModalState(
                      () =>
                          level = value == null || value.isEmpty ? null : value,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  GymDropdownField<String>(
                    label: l10n.exerciseCategoryLabel,
                    value: category ?? '',
                    options: _options(l10n, _categories),
                    onChanged: (value) => setModalState(
                      () => category = value == null || value.isEmpty
                          ? null
                          : value,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  GymDropdownField<String>(
                    label: l10n.equipmentLabel,
                    value: equipment ?? '',
                    options: _options(l10n, _equipment),
                    onChanged: (value) => setModalState(
                      () => equipment = value == null || value.isEmpty
                          ? null
                          : value,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  GymDropdownField<String>(
                    label: l10n.exerciseMuscleLabel,
                    value: muscle ?? '',
                    options: _options(l10n, _muscles),
                    onChanged: (value) => setModalState(
                      () => muscle = value == null || value.isEmpty
                          ? null
                          : value,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _FilterSelection(
                        level: level,
                        category: category,
                        equipment: equipment,
                        muscle: muscle,
                      ),
                    ),
                    child: Text(l10n.exerciseApplyFilters),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(const _FilterSelection()),
                    child: Text(l10n.exerciseClearFilters),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (result == null || !mounted) return;
    await _controller.applyFilters(
      level: result.level,
      category: result.category,
      equipment: result.equipment,
      muscle: result.muscle,
    );
  }

  List<GymSelectOption<String>> _options(
    AppLocalizations l10n,
    List<String> values,
  ) => [
    GymSelectOption(value: '', label: l10n.exerciseAllFilter),
    ...values.map(
      (value) =>
          GymSelectOption(value: value, label: l10n.exerciseTaxonomy(value)),
    ),
  ];

  Future<void> _showDetails(
    BuildContext context,
    ExerciseCatalogItem exercise,
  ) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final instructions = exercise.instructions.resolve(language);
    return showModalBottomSheet<ExerciseCatalogItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name.resolve(language),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                l10n.exerciseInstructionsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              if (instructions.isEmpty)
                Text(l10n.exerciseNoInstructions)
              else
                ...instructions.indexed.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: Text('${entry.$1 + 1}. ${entry.$2}'),
                  ),
                ),
              const SizedBox(height: AppSpacing.large),
              if (widget.selectionMode)
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(exercise),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.commonAdd),
                ),
            ],
          ),
        ),
      ),
    ).then((selected) {
      if (selected != null && mounted) {
        Navigator.of(this.context).pop(selected);
      }
    });
  }
}

class _ExerciseCatalogCard extends StatelessWidget {
  const _ExerciseCatalogCard({
    required this.exercise,
    required this.onDetails,
    this.onAdd,
  });

  final ExerciseCatalogItem exercise;
  final VoidCallback onDetails;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final tags = <String>[
      if (exercise.level != null) exercise.level!,
      if (exercise.equipment != null) exercise.equipment!,
      ...exercise.primaryMuscles.take(2),
    ];
    final name = exercise.name.resolve(language);
    final initial = name.isEmpty ? '?' : name.characters.first;
    return GymSurface(
      elevation: GymSurfaceElevation.none,
      borderColor: Theme.of(context).colorScheme.outlineVariant,
      child: InkWell(
        onTap: onDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(initial)),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onAdd != null)
                  IconButton(
                    tooltip: l10n.commonAdd,
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map((tag) => GymTag(label: l10n.exerciseTaxonomy(tag)))
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.controller});

  final ExerciseCatalogController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (controller.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorCode != null) {
      return TextButton.icon(
        onPressed: controller.loadMore,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.exerciseRetry),
      );
    }
    if (!controller.hasMore) return const SizedBox.shrink();
    return TextButton(
      onPressed: controller.loadMore,
      child: Text(l10n.exerciseLoadMore),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(title, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(description!, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.medium),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterSelection {
  const _FilterSelection({
    this.level,
    this.category,
    this.equipment,
    this.muscle,
  });

  final String? level;
  final String? category;
  final String? equipment;
  final String? muscle;
}

const _levels = ['beginner', 'intermediate', 'expert'];
const _categories = [
  'strength',
  'stretching',
  'cardio',
  'powerlifting',
  'plyometrics',
  'olympic weightlifting',
  'strongman',
];
const _equipment = [
  'bands',
  'barbell',
  'body only',
  'cable',
  'dumbbell',
  'e-z curl bar',
  'exercise ball',
  'foam roll',
  'kettlebells',
  'machine',
  'medicine ball',
  'other',
];
const _muscles = [
  'abdominals',
  'abductors',
  'adductors',
  'biceps',
  'calves',
  'chest',
  'forearms',
  'glutes',
  'hamstrings',
  'lats',
  'lower back',
  'middle back',
  'neck',
  'quadriceps',
  'shoulders',
  'traps',
  'triceps',
];
