import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/coach_dashboard_data.dart';
import 'coach_assign_routine_page.dart';

class CoachClientProfilePage extends StatelessWidget {
  const CoachClientProfilePage({super.key});

  static const routeName = '/coach/client-profile';

  @override
  Widget build(BuildContext context) {
    final client = ModalRoute.of(context)?.settings.arguments as CoachClient?;
    if (client == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontro el asesorado.')),
      );
    }

    final theme = Theme.of(context);

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
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          CoachAssignRoutinePage.routeName,
                          arguments: client,
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Asignar rutina'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              const Divider(height: 1, color: Color(0xFFE5E7F0)),
              const SizedBox(height: AppSpacing.medium),
              _ProfileShell(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: client.accentColor,
                            borderRadius: BorderRadius.circular(34),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            client.initials,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cliente desde: ${client.joinedLabel}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF7C8296),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              _InfoMiniCard(
                                icon: Icons.cake_outlined,
                                label: 'Edad',
                                value: client.ageLabel,
                              ),
                              const SizedBox(height: AppSpacing.small),
                              _InfoMiniCard(
                                icon: Icons.monitor_weight_outlined,
                                label: 'Peso actual',
                                value: client.currentWeightLabel,
                              ),
                              const SizedBox(height: AppSpacing.small),
                              _InfoMiniCard(
                                icon: Icons.track_changes_outlined,
                                label: 'Objetivo',
                                value: client.goal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              _SectionShell(
                title: 'Rutina Actual',
                child: _CurrentRoutineCard(client: client),
              ),
              const SizedBox(height: AppSpacing.medium),
              _SectionShell(
                title: 'Historial de Rutinas',
                subtitle: 'Rutinas anteriores completadas',
                child: Column(
                  children: client.routineHistory
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                            child: _HistoryTile(item: item),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileShell extends StatelessWidget {
  const _ProfileShell({required this.child});

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

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ProfileShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8A90A5),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.medium),
          child,
        ],
      ),
    );
  }
}

class _InfoMiniCard extends StatelessWidget {
  const _InfoMiniCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7B4DFF), size: 18),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A90A5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
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

class _CurrentRoutineCard extends StatelessWidget {
  const _CurrentRoutineCard({required this.client});

  final CoachClient client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  client.currentRoutine,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Activa',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF22A95F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            client.programProgressLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF747B92),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: _RoutineMetric(label: 'Inicio', value: client.programStartLabel),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: _RoutineMetric(label: 'Dias/semana', value: client.daysPerWeekLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              Expanded(
                child: _RoutineMetric(
                  label: 'Progreso',
                  value: '${(client.programProgressPercent * 100).toStringAsFixed(1)}%',
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: _RoutineMetric(label: 'Finaliza', value: client.programEndLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: client.programProgressPercent,
              minHeight: 6,
              backgroundColor: const Color(0xFFDCDDDF),
              valueColor: AlwaysStoppedAnimation(client.accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              _TagChip(label: '12 ejercicios'),
              _TagChip(label: client.programDurationLabel),
              _TagChip(label: 'Nivel: ${client.programLevelLabel}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineMetric extends StatelessWidget {
  const _RoutineMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF8A90A5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF61677C),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final CoachRoutineHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEF0F6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EEFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4C77FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${item.durationLabel}  -  Completado: ${item.completedAtLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7E859A),
            ),
          ),
        ],
      ),
    );
  }
}
