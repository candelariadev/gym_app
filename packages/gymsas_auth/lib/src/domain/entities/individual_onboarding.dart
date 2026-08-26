import '../user_role.dart';
import '../user_gender.dart';

class IndividualOnboarding {
  const IndividualOnboarding({
    required this.idToken,
    required this.nickname,
    required this.password,
    required this.role,
    this.advised,
    this.trainer,
  });

  final String idToken;
  final String nickname;
  final String password;
  final UserRole role;
  final AdvisedOnboarding? advised;
  final TrainerOnboarding? trainer;
}

class AdvisedOnboarding {
  const AdvisedOnboarding({
    required this.birthdate,
    required this.gender,
    required this.weight,
    required this.goals,
    this.notes,
  });
  final DateTime birthdate;
  final UserGender gender;
  final double weight;
  final List<String> goals;
  final String? notes;
}

class TrainerOnboarding {
  const TrainerOnboarding({
    required this.bio,
    required this.certifications,
    required this.experience,
  });
  final String bio;
  final List<String> certifications;
  final int experience;
}
