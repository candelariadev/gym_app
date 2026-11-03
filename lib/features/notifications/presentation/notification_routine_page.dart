import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';

class NotificationRoutinePage extends StatefulWidget {
  const NotificationRoutinePage({
    super.key,
    required this.routineId,
    required this.verify,
    required this.canVerify,
  });
  static const routeName = '/notification/routine';
  final String routineId;
  final GetConfirmedWorkoutUseCase verify;
  final bool Function() canVerify;
  @override
  State<NotificationRoutinePage> createState() =>
      _NotificationRoutinePageState();
}

class _NotificationRoutinePageState extends State<NotificationRoutinePage> {
  Workout? _routine;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _routine = null;
    });
    try {
      if (!widget.canVerify()) return;
      final result = await widget.verify(widget.routineId);
      if (mounted && widget.canVerify()) setState(() => _routine = result);
    } on Object {
      // Nunca abrir caché desde una referencia push sin comprobar acceso remoto.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), r = _routine;
    return Scaffold(
      appBar: AppBar(title: Text(l.routineDetailTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: _loading
              ? GymLoadingStatus(label: l.pushVerifying)
              : r == null
              ? GymActionStatusCard(
                  title: l.routineDetailTitle,
                  status: l.pushAccessUnavailable,
                  warning: true,
                  actionLabel: l.exerciseRetry,
                  onAction: _load,
                )
              : ListView(
                  children: [
                    Text(
                      r.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    for (final day in r.days ?? <WorkoutDayPlan>[]) ...[
                      const SizedBox(height: AppSpacing.medium),
                      GymSectionCard(
                        title: DateFormat.EEEE(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(DateTime(2024, 1, 1 + day.day.index)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final exercise in day.exercises)
                              Text(
                                '${exercise.name.isEmpty ? exercise.exerciseId : exercise.name} · ${exercise.sets} × ${exercise.reps}',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
