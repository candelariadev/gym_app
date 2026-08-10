import '../../domain/entities/dashboard_metric.dart';
import '../../domain/entities/trainer_dashboard.dart';

class TrainerDashboardDto {
  const TrainerDashboardDto(this._json);

  final Map<String, dynamic> _json;

  TrainerDashboard toDomain() => TrainerDashboard(
    activeClients: _metric('activeClients'),
    assignedWorkouts: _metric('assignedWorkouts'),
    generatedAt: _date('generatedAt'),
  );

  DashboardMetric _metric(String key) {
    final raw = _json[key];
    if (raw is! Map<String, dynamic>) throw FormatException(key);
    final status = switch (raw['status']) {
      'AVAILABLE' => DashboardMetricStatus.available,
      'UNAVAILABLE' => DashboardMetricStatus.unavailable,
      _ => throw FormatException('$key.status'),
    };
    final value = raw['value'];
    if (status == DashboardMetricStatus.available && value is! num) {
      throw FormatException('$key.value');
    }
    return DashboardMetric(value: (value as num?)?.toInt(), status: status);
  }

  DateTime _date(String key) {
    final raw = _json[key];
    if (raw is! String) throw FormatException(key);
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) throw FormatException(key);
    return parsed;
  }
}
