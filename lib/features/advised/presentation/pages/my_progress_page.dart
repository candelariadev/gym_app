import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/my_progress_controller.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key, this.getProgress});
  static const routeName = '/advised/progress';
  final GetWorkoutProgress? getProgress;

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  late final MyProgressController controller;

  @override
  void initState() {
    super.initState();
    controller = MyProgressController(widget.getProgress)..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _metric(ProgressMetric metric, AppLocalizations l10n) =>
      switch (metric) {
        ProgressMetric.sets => l10n.progressSets,
        ProgressMetric.repetitions => l10n.progressRepetitions,
        ProgressMetric.weight => l10n.progressWeight,
        ProgressMetric.volume => l10n.progressVolume,
        ProgressMetric.sessions => l10n.progressSessions,
        ProgressMetric.trainingDays => l10n.progressTrainingDays,
      };

  Future<void> _selectRange() async {
    final now = DateTime.now();
    final earliest = controller.progress?.earliestDate;
    final firstDate = earliest ?? DateTime(1970);
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: controller.from,
        end: controller.to,
      ),
    );
    if (range == null || !mounted) return;
    if (range.end.difference(range.start).inDays > 365) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).progressRangeTooLong),
        ),
      );
      return;
    }
    controller.from = range.start;
    controller.to = range.end;
    await controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMd(locale);
    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProgressAction)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final progress = controller.progress;
          final points = progress?.points ?? const <ProgressPoint>[];
          final title = _metric(controller.metric, l10n);
          final chartPoints = points
              .map(
                (p) => GymChartPoint(
                  label: dateFormat.format(p.date),
                  value: p.value(controller.metric),
                  valueLabel: p.value(controller.metric) == null
                      ? l10n.progressNoMeasurement
                      : number.format(p.value(controller.metric)),
                ),
              )
              .toList();
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                Text(
                  l10n.myProgressActionDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton.icon(
                  onPressed: controller.loading ? null : _selectRange,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                    '${dateFormat.format(controller.from)} – ${dateFormat.format(controller.to)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                SegmentedButton<ProgressGranularity>(
                  segments: [
                    ButtonSegment(
                      value: ProgressGranularity.day,
                      label: Text(l10n.progressDaily),
                    ),
                    ButtonSegment(
                      value: ProgressGranularity.week,
                      label: Text(l10n.progressWeekly),
                    ),
                    ButtonSegment(
                      value: ProgressGranularity.month,
                      label: Text(l10n.progressMonthly),
                    ),
                  ],
                  selected: {controller.granularity},
                  onSelectionChanged: controller.loading
                      ? null
                      : (values) {
                          controller.granularity = values.single;
                          controller.load();
                        },
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<ProgressMetric>(
                  initialValue: controller.metric,
                  decoration: InputDecoration(labelText: l10n.progressMetric),
                  items: ProgressMetric.values
                      .map(
                        (metric) => DropdownMenuItem(
                          value: metric,
                          child: Text(_metric(metric, l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectMetric(value);
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                if (controller.error != null && progress != null)
                  Text(l10n.progressLoadError),
                if (controller.loading && progress != null)
                  LinearProgressIndicator(semanticsLabel: l10n.loadingData),
                if (controller.loading && progress == null)
                  GymLoadingStatus(label: l10n.loadingData)
                else if (controller.error != null && progress == null) ...[
                  Text(
                    controller.error == ProgressError.historyNotAllowed
                        ? l10n.progressHistoryDenied
                        : l10n.progressLoadError,
                  ),
                  TextButton(
                    onPressed: controller.load,
                    child: Text(l10n.progressRetry),
                  ),
                ] else if (points.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.progressEmpty,
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          GymProgressChart(
                            points: chartPoints,
                            title: title,
                            emptyLabel: l10n.progressNoMeasurement,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (points.any((point) => point.unrecordedSessions > 0))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(l10n.progressLegacyWarning),
                    ),
                  ExpansionTile(
                    title: Text(l10n.progressDetails),
                    children: [
                      for (final point in chartPoints)
                        ListTile(
                          title: Text(point.label),
                          trailing: Text(point.valueLabel),
                        ),
                    ],
                  ),
                ],
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      progress.historyMonths == -1
                          ? l10n.progressUnlimited
                          : l10n.progressHistoryMonths(progress.historyMonths),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  l10n.progressMetricHelp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
