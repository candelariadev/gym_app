enum WorkoutDay {
  monday('MONDAY'),
  tuesday('TUESDAY'),
  wednesday('WEDNESDAY'),
  thursday('THURSDAY'),
  friday('FRIDAY'),
  saturday('SATURDAY'),
  sunday('SUNDAY');

  const WorkoutDay(this.apiValue);

  final String apiValue;

  static WorkoutDay? fromApiValue(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.trim().toUpperCase();
    for (final day in values) {
      if (day.apiValue == normalized) return day;
    }
    return null;
  }
}
