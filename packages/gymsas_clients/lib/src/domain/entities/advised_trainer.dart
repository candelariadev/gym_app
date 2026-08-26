class AdvisedTrainer {
  const AdvisedTrainer({
    required this.user,
    required this.name,
    required this.email,
    required this.plan,
    required this.status,
    required this.bio,
    required this.certifications,
    required this.experience,
  });

  final String user;
  final String name;
  final String email;
  final String plan;
  final String status;
  final String bio;
  final List<String> certifications;
  final int experience;

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return words.take(2).map((word) => word[0]).join().toUpperCase();
  }
}
