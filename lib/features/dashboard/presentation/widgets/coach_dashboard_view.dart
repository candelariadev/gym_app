import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../coach/domain/coach_dashboard_data.dart';
import '../../../coach/presentation/pages/coach_create_routine_page.dart';
import '../../../coach/presentation/pages/coach_client_profile_page.dart';
import '../../../coach/presentation/pages/coach_routine_history_page.dart';

class CoachDashboardView extends StatefulWidget {
  const CoachDashboardView({super.key});

  @override
  State<CoachDashboardView> createState() => _CoachDashboardViewState();
}

class _CoachDashboardViewState extends State<CoachDashboardView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _CoachHomeTab(
        onShowAllClients: () => setState(() => _currentIndex = 1),
      ),
      const _CoachClientsTab(),
      const _CoachPlaceholderTab(
        title: 'Calendario',
        description: 'Aqui luego veremos sesiones, citas y recordatorios del entrenador.',
        icon: Icons.calendar_month_rounded,
      ),
      const _CoachPlaceholderTab(
        title: 'Progreso',
        description: 'Aqui luego veremos progreso acumulado de clientes y metricas del panel.',
        icon: Icons.show_chart_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _CoachBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class _CoachHomeTab extends StatelessWidget {
  const _CoachHomeTab({required this.onShowAllClients});

  final VoidCallback onShowAllClients;

  @override
  Widget build(BuildContext context) {
    final dashboard = CoachMockData.dashboard;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CoachTopBar(),
            const SizedBox(height: AppSpacing.large),
            _CoachStatCard(
              title: 'Asesorados activos',
              value: '${dashboard.activeTrainees}',
              subtitle: '+3 este mes',
              icon: Icons.groups_rounded,
              iconBackground: const Color(0xFF2F80ED),
              onTap: onShowAllClients,
            ),
            const SizedBox(height: AppSpacing.medium),
            _CoachStatCard(
              title: 'Rutinas activas',
              value: '${dashboard.activeRoutines}',
              subtitle: '+2 esta semana',
              icon: Icons.assignment_rounded,
              iconBackground: const Color(0xFF1EC870),
              onTap: () {
                Navigator.of(context).pushNamed(CoachRoutineHistoryPage.routeName);
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            const _CoachStatCard(
              title: 'Sesiones programadas',
              value: '12',
              subtitle: 'Esta semana',
              icon: Icons.calendar_today_rounded,
              iconBackground: Color(0xFFB14CFF),
            ),
            const SizedBox(height: AppSpacing.medium),
            _RecentClientsCard(
              clients: dashboard.recentClients.take(5).toList(),
              onClientTap: (client) {
                Navigator.of(context).pushNamed(
                  CoachClientProfilePage.routeName,
                  arguments: client,
                );
              },
              onShowAllPressed: onShowAllClients,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachClientsTab extends StatelessWidget {
  const _CoachClientsTab();

  @override
  Widget build(BuildContext context) {
    final clients = CoachMockData.clients;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Todos los asesorados',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              'Lista base para gestionar clientes y abrir su perfil.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF697088),
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            ...clients.map(
              (client) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: _ClientTile(
                  client: client,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      CoachClientProfilePage.routeName,
                      arguments: client,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachPlaceholderTab extends StatelessWidget {
  const _CoachPlaceholderTab({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        child: _CoachCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF697088),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachTopBar extends StatelessWidget {
  const _CoachTopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_motion_rounded,
            color: colorScheme.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FitCoach',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Panel de Control',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF697088),
              ),
            ),
          ],
        ),
        const Spacer(),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).pushNamed(CoachRoutineHistoryPage.routeName);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAF3)),
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                color: Color(0xFF737A90),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(CoachCreateRoutinePage.routeName);
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Crear rutina'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
        ),
      ],
    );
  }
}

class _CoachStatCard extends StatelessWidget {
  const _CoachStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = _CoachCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF697088),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9AA0B5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: child,
    );
  }
}

class _RecentClientsCard extends StatelessWidget {
  const _RecentClientsCard({
    required this.clients,
    required this.onClientTap,
    required this.onShowAllPressed,
  });

  final List<CoachClient> clients;
  final ValueChanged<CoachClient> onClientTap;
  final VoidCallback onShowAllPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CoachCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asesorados recientes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clientes con actividad reciente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF697088),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAEAF1)),
          ...clients.map(
            (client) => _ClientTile(
              client: client,
              onTap: () => onClientTap(client),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onShowAllPressed,
                child: const Text('Ver todos los asesorados'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientTile extends StatelessWidget {
  const _ClientTile({
    required this.client,
    required this.onTap,
  });

  final CoachClient client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: client.accentColor,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                client.initials,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _ClientStatusChip(label: client.statusLabel),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.lastActivityLabel} - ${client.programProgressLabel}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF697088),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9AA0B5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1B4B),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _ClientStatusChip extends StatelessWidget {
  const _ClientStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FFF0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF27A95D),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CoachBottomNavBar extends StatelessWidget {
  const _CoachBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7D84FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121A1B4B),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _CoachNavItem(
              label: 'Inicio',
              icon: Icons.auto_awesome_motion_rounded,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _CoachNavItem(
              label: 'Clientes',
              icon: Icons.groups_rounded,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _CoachNavItem(
              label: 'Calendario',
              icon: Icons.calendar_today_rounded,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _CoachNavItem(
              label: 'Progreso',
              icon: Icons.show_chart_rounded,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachNavItem extends StatelessWidget {
  const _CoachNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF5B5CF6) : const Color(0xFFA3A7B8);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
