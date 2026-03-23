enum UserRole {
  coach(label: 'Entrenador'),
  trainee(label: 'Asesorado');

  const UserRole({required this.label});

  final String label;

  String get dashboardTitle => 'Dashboard de $label';
}
