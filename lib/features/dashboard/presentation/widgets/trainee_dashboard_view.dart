import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../workout/application/workout_session_store.dart';
import '../../../workout/presentation/pages/workout_today_page.dart';

class TraineeDashboardView extends StatefulWidget {
  const TraineeDashboardView({super.key});

  @override
  State<TraineeDashboardView> createState() => _TraineeDashboardViewState();
}

class _TraineeDashboardViewState extends State<TraineeDashboardView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _TraineeHomeTab(),
      const _SimpleDashboardTab(
        title: 'Mi Progreso',
        description: 'Aqui podras revisar fotos, estadisticas y avance semanal.',
        icon: Icons.show_chart_rounded,
      ),
      const _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _TraineeHomeTab extends StatelessWidget {
  const _TraineeHomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DashboardTopBar(),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Hola, Ana',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              'Hoy tienes una rutina lista para completar.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.large),
            const _TodayRoutineCard(),
            const SizedBox(height: AppSpacing.medium),
            const _WeekCard(),
            const SizedBox(height: AppSpacing.medium),
            const _ProgramProgressCard(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: colorScheme.onPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          'FitCoach',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(17),
          ),
          alignment: Alignment.center,
          child: Text(
            'AG',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayRoutineCard extends StatelessWidget {
  const _TodayRoutineCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTag(
            label: 'Rutina de hoy',
            color: colorScheme.primary.withValues(alpha: 0.12),
            textColor: colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Lunes - Dia de Espalda',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rutina Full body - Principiante',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Text(
                'Progreso de hoy',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8E93A8),
                ),
              ),
              const Spacer(),
              Text(
                '0%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: Color(0xFFE7E9F2),
              valueColor: AlwaysStoppedAnimation(Color(0xFF5B5CF6)),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            '0 de 5 ejercicios completados',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.medium),
          const Row(
            children: [
              Expanded(
                child: _MetricCard(value: '5', label: 'Ejercicios'),
              ),
              SizedBox(width: AppSpacing.small),
              Expanded(
                child: _MetricCard(value: '45', label: 'Minutos'),
              ),
              SizedBox(width: AppSpacing.small),
              Expanded(
                child: _MetricCard(value: '15', label: 'Series'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(WorkoutTodayPage.routeName);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Comenzar Rutina'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semana actual',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekDayItem(label: 'D', status: _DayStatus.completed),
              _WeekDayItem(label: 'L', status: _DayStatus.completed),
              _WeekDayItem(label: 'M', status: _DayStatus.completed),
              _WeekDayItem(label: 'M', status: _DayStatus.completed),
              _WeekDayItem(label: 'J', status: _DayStatus.missed),
              _WeekDayItem(label: 'V', status: _DayStatus.today),
              _WeekDayItem(label: 'S', status: _DayStatus.idle),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgramProgressCard extends StatelessWidget {
  const _ProgramProgressCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROGRESO DEL PROGRAMA',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFF7B8197),
                ),
              ),
              const Spacer(),
              Text(
                'Semana 3 de 6',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.25,
              minHeight: 8,
              backgroundColor: Color(0xFFE7E9F2),
              valueColor: AlwaysStoppedAnimation(Color(0xFF5B5CF6)),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            '25% completado',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                color: const Color(0xFF6E7386),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: child,
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  const _SectionTag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
      ),
    );
  }
}

enum _DayStatus { completed, missed, today, idle }

class _WeekDayItem extends StatelessWidget {
  const _WeekDayItem({
    required this.label,
    required this.status,
  });

  final String label;
  final _DayStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;
    final Widget content;

    switch (status) {
      case _DayStatus.completed:
        backgroundColor = const Color(0xFFE9FFF0);
        borderColor = const Color(0xFF74D68E);
        textColor = const Color(0xFF3CA857);
        content = const Icon(
          Icons.check_rounded,
          size: 18,
          color: Color(0xFF3CA857),
        );
      case _DayStatus.missed:
        backgroundColor = const Color(0xFFFFEEEE);
        borderColor = const Color(0xFFFF8181);
        textColor = const Color(0xFFE15050);
        content = const Icon(
          Icons.close_rounded,
          size: 18,
          color: Color(0xFFE15050),
        );
      case _DayStatus.today:
        backgroundColor = const Color(0xFFECECFF);
        borderColor = const Color(0xFFB7BBFF);
        textColor = const Color(0xFF5B5CF6);
        content = Text(
          'Hoy',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        );
      case _DayStatus.idle:
        backgroundColor = const Color(0xFFF0F0F3);
        borderColor = const Color(0xFFD9DDE8);
        textColor = const Color(0xFF9298AA);
        content = Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        );
    }

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 11,
            color: const Color(0xFF8E93A8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
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
            child: _NavItem(
              label: 'Inicio',
              icon: Icons.home_rounded,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              label: 'Progreso',
              icon: Icons.show_chart_rounded,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _NavItem(
              label: 'Perfil',
              icon: Icons.person_rounded,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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

class _SimpleDashboardTab extends StatelessWidget {
  const _SimpleDashboardTab({
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
        child: _DashboardCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProfileTopBar(),
                const SizedBox(height: AppSpacing.large),
                _DashboardCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4B45F5),
                                  Color(0xFF8038F5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(36),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.large),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ana Gonzalez',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  'Miembro desde Enero\n2025',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF505566),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.large),
                      const Row(
                        children: [
                          Expanded(child: _ProfileMetric(value: '68', label: 'Dias activos')),
                          SizedBox(width: AppSpacing.small),
                          Expanded(child: _ProfileMetric(value: '15', label: 'Rutinas')),
                          SizedBox(width: AppSpacing.small),
                          Expanded(
                            child: _ProfileMetric(
                              value: '94%',
                              label: 'Asistencia',
                              valueColor: Color(0xFF1DA84A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                const _ProfileSectionCard(
                  title: 'Rutina Actual',
                  child: Center(
                    child: Text(
                      'Rutina Full Body',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                const _ProfileSectionCard(
                  title: 'Informacion Personal',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileInfoRow(label: 'Edad', value: '27 anios'),
                      _ProfileInfoRow(label: 'Genero', value: 'Femenino'),
                      _ProfileInfoRow(label: 'Estatura', value: '1.67 m'),
                      _ProfileInfoRow(label: 'Correo', value: 'ana@gym.com'),
                      _ProfileInfoRow(label: 'Peso', value: '61 kg'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Entrenador',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4B45F5),
                                  Color(0xFF8038F5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Carlos Martinez',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Entrenador Personal Certificado',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF505566),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                OutlinedButton.icon(
                  onPressed: () {
                    WorkoutSessionStore.instance.reset();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginPage.routeName,
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: BorderSide(color: colorScheme.primary),
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesion'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: colorScheme.onPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'FitCoach',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.value,
    required this.label,
    this.valueColor = const Color(0xFF5B5CF6),
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    color: valueColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF505566),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: AppSpacing.large),
          child,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF505566),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
