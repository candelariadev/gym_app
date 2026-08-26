import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/my_workouts_controller.dart';

class WorkoutCalendarView extends StatefulWidget {
  const WorkoutCalendarView({
    super.key,
    required this.controller,
    required this.onLogout,
  });

  final MyWorkoutsController controller;
  final VoidCallback onLogout;

  @override
  State<WorkoutCalendarView> createState() => _WorkoutCalendarViewState();
}

class _WorkoutCalendarViewState extends State<WorkoutCalendarView> {
  _CalendarMonth? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final months = _availableMonths(widget.controller.workouts);
    final currentMonth = _CalendarMonth.fromDate(DateTime.now());
    final selectedMonth = _resolveSelectedMonth(
      requested: _selectedMonth,
      available: months,
      current: currentMonth,
    );
    final completedDays = selectedMonth == null
        ? const <int>{}
        : widget.controller.completedWorkoutDays
              .where(
                (date) =>
                    date.year == selectedMonth.year &&
                    date.month == selectedMonth.month,
              )
              .map((date) => date.day)
              .toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.logoutTooltip,
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Text(
                l10n.routineHistoryTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              if (months.isNotEmpty)
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: months.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final month = months[index];
                      return ChoiceChip(
                        label: Text(_monthLabel(context, month)),
                        selected: month == selectedMonth,
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _selectedMonth = month);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.medium),
              if (widget.controller.isLoading && months.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (selectedMonth == null)
                GymSurface(child: Text(l10n.myAssignedRoutinesEmpty))
              else ...[
                Text(
                  _monthLabel(context, selectedMonth),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.medium),
                _CompletedWorkoutCalendar(
                  month: selectedMonth,
                  completedDays: completedDays,
                  l10n: l10n,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedWorkoutCalendar extends StatelessWidget {
  const _CompletedWorkoutCalendar({
    required this.month,
    required this.completedDays,
    required this.l10n,
  });

  final _CalendarMonth month;
  final Set<int> completedDays;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month).weekday - 1;
    final totalCells = firstWeekday + daysInMonth;
    final weekdayLabels = [
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
      l10n.weekdaySunday,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Row(
              children: weekdayLabels
                  .map(
                    (label) => Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.small),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox.shrink();

                final day = index - firstWeekday + 1;
                final completed = completedDays.contains(day);
                return Container(
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFFFFF4E5)
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: completed
                          ? const Color(0xFFF3A64E)
                          : const Color(0xFFE6E9F2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day'),
                      if (completed)
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFF08A24),
                          size: 14,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

List<_CalendarMonth> _availableMonths(List<AdvisedWorkoutItem> items) {
  final months = <_CalendarMonth>{};

  for (final item in items) {
    final startDate = item.workout.startDate;
    if (startDate == null) continue;

    final start = DateTime(startDate.year, startDate.month);
    final explicitEnd = item.workout.endDate;
    final durationWeeks = item.workout.durationWeeks;
    final calculatedEnd =
        explicitEnd ??
        (durationWeeks != null && durationWeeks > 0
            ? startDate.add(Duration(days: durationWeeks * 7 - 1))
            : startDate);
    final end = DateTime(calculatedEnd.year, calculatedEnd.month);

    var cursor = start;
    while (!cursor.isAfter(end)) {
      months.add(_CalendarMonth.fromDate(cursor));
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
  }

  final ordered = months.toList()
    ..sort((left, right) {
      final yearComparison = left.year.compareTo(right.year);
      return yearComparison != 0
          ? yearComparison
          : left.month.compareTo(right.month);
    });
  return ordered;
}

_CalendarMonth? _resolveSelectedMonth({
  required _CalendarMonth? requested,
  required List<_CalendarMonth> available,
  required _CalendarMonth current,
}) {
  if (available.isEmpty) return null;
  if (requested != null && available.contains(requested)) return requested;
  if (available.contains(current)) return current;
  return available.last;
}

String _monthLabel(BuildContext context, _CalendarMonth month) {
  return MaterialLocalizations.of(
    context,
  ).formatMonthYear(DateTime(month.year, month.month));
}

class _CalendarMonth {
  const _CalendarMonth(this.year, this.month);

  factory _CalendarMonth.fromDate(DateTime date) {
    return _CalendarMonth(date.year, date.month);
  }

  final int year;
  final int month;

  @override
  bool operator ==(Object other) {
    return other is _CalendarMonth &&
        year == other.year &&
        month == other.month;
  }

  @override
  int get hashCode => Object.hash(year, month);
}
