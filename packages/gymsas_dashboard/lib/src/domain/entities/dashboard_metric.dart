enum DashboardMetricStatus { available, unavailable }

class DashboardMetric {
  const DashboardMetric({required this.value, required this.status});

  final int? value;
  final DashboardMetricStatus status;

  bool get isAvailable => status == DashboardMetricStatus.available;
}
