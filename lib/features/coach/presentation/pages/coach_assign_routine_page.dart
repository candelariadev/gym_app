import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/coach_dashboard_data.dart';
import '../../domain/routine_catalog_mock_data.dart';
import '../../domain/routine_builder_models.dart';

class CoachAssignRoutinePage extends StatefulWidget {
  const CoachAssignRoutinePage({super.key});

  static const routeName = '/coach/assign-routine';

  @override
  State<CoachAssignRoutinePage> createState() => _CoachAssignRoutinePageState();
}

class _CoachAssignRoutinePageState extends State<CoachAssignRoutinePage> {
  final Set<String> _selectedClientIds = <String>{};
  String? _selectedRoutineKey;
  bool _notifyClients = true;
  bool _isPublished = false;

  @override
  Widget build(BuildContext context) {
    final args = _normalizeArgs(ModalRoute.of(context)?.settings.arguments);
    final allClients = CoachMockData.clients;
    final routines = _buildRoutineCatalog(args.routine);
    final selectedRoutine = _resolveSelectedRoutine(routines);
    final theme = Theme.of(context);

    if (_selectedClientIds.isEmpty && args.preselectedClients.isNotEmpty) {
      _selectedClientIds.addAll(args.preselectedClients.map((client) => client.id));
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              _ShellCard(
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
                                'Asignar Rutina',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedRoutine?.name ?? 'Selecciona una rutina ya creada',
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
                    _InputBlock(
                      label: 'Fecha de inicio',
                      child: TextFormField(
                        initialValue: '23/03/2026',
                        decoration: const InputDecoration(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _InputBlock(
                      label: 'Duracion (semanas)',
                      child: TextFormField(
                        initialValue:
                            '${selectedRoutine?.durationWeeks ?? RoutineDraft.minimumDurationWeeks}',
                        decoration: const InputDecoration(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Rutinas disponibles',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C748D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...routines.map(
                      (routine) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.small),
                        child: _RoutineSelectionCard(
                          routine: routine,
                          isSelected: _routineKey(routine) == _selectedRoutineKey,
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
                      'Seleccionar asesorado(s)',
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: allClients.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFEDEF5A)),
                        itemBuilder: (context, index) {
                          final client = allClients[index];
                          final isSelected = _selectedClientIds.contains(client.id);

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
                                      color: client.accentColor,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      client.initials,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.small),
                                  Expanded(
                                    child: Text(
                                      client.name,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
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
                      '${_selectedClientIds.length} asesorado(s) seleccionado(s)',
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
                            title: const Text('Enviar notificacion'),
                            subtitle: const Text(
                              'Los asesorados recibiran una notificacion de la nueva rutina',
                            ),
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
                                  'Resumen',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                _SummaryLine(
                                  label: 'Rutina',
                                  value: selectedRoutine?.name ?? 'Sin seleccionar',
                                ),
                                _SummaryLine(label: 'Inicio', value: '22 de marzo de 2026'),
                                _SummaryLine(
                                  label: 'Duracion',
                                  value: '${selectedRoutine?.durationWeeks ?? 0} semanas',
                                ),
                                _SummaryLine(
                                  label: 'Ejercicios',
                                  value: '${selectedRoutine?.totalExercises ?? 0}',
                                ),
                                _SummaryLine(
                                  label: 'Asesorados',
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
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPublished
                                ? () {
                                    Navigator.of(context).popUntil(
                                      (route) =>
                                          route.isFirst ||
                                          route.settings.name == '/dashboard',
                                    );
                                  }
                                : _selectedClientIds.isEmpty || selectedRoutine == null
                                    ? null
                                    : () {
                                        setState(() {
                                          _isPublished = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Rutina publicada para ${_selectedClientIds.length} asesorado(s).',
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
                              _isPublished ? 'Finalizar' : 'Publicar rutina',
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

    if (rawArgs is CoachClient) {
      return AssignRoutineArgs(
        preselectedClients: [rawArgs],
      );
    }

    return const AssignRoutineArgs();
  }

  List<RoutineDraft> _buildRoutineCatalog(RoutineDraft? incomingRoutine) {
    final routines = List<RoutineDraft>.from(RoutineCatalogMockData.savedRoutines);
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '- $label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF55607F),
            ),
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
            color: isSelected ? const Color(0xFF5B5CF6) : const Color(0xFFC0C4D2),
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
                  .map((tag) => _RoutineFocusTag(label: tag))
                  .toList(growable: false),
            ),
          ),
          trailing: TextButton(
            onPressed: onSelect,
            child: Text(isSelected ? 'Seleccionada' : 'Usar'),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${routine.durationWeeks} semanas - ${routine.totalExercises} ejercicios',
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

class _RoutineFocusTag extends StatelessWidget {
  const _RoutineFocusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4C77FF),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
