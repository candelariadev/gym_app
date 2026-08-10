enum WorkoutDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static WorkoutDay? tryParse(Object? raw) {
    final normalized = raw?.toString().trim().toLowerCase();
    for (final day in values) {
      if (day.name == normalized) return day;
    }
    return null;
  }
}
