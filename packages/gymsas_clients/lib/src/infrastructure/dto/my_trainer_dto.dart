import '../../domain/entities/advised_trainer.dart';

class MyTrainerDto {
  const MyTrainerDto(this._json);

  factory MyTrainerDto.fromJson(Map<String, dynamic> json) =>
      MyTrainerDto(json);

  final Map<String, dynamic> _json;

  String get user => _requiredString(_json['user']);
  String get name => _requiredString(_json['name']);
  String get email => _optionalString(_json['email']) ?? '';
  String get plan => _requiredString(_json['plan']);
  String get status => _requiredString(_json['status']);

  Map<String, dynamic> get _profile {
    final raw = _json['profile'];
    if (raw is Map<String, dynamic>) return raw;
    throw const FormatException('myTrainer.profile');
  }

  String get bio => _requiredString(_profile['bio']);

  List<String> get certifications {
    final raw = _profile['certifications'];
    if (raw is! List) throw const FormatException('myTrainer.certifications');
    return raw.map(_requiredString).toList(growable: false);
  }

  int get experience {
    final raw = _profile['experience'];
    if (raw is int) return raw;
    throw const FormatException('myTrainer.experience');
  }

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return words.take(2).map((word) => word[0]).join().toUpperCase();
  }

  AdvisedTrainer toDomain() => AdvisedTrainer(
    user: user,
    name: name,
    email: email,
    plan: plan,
    status: status,
    bio: bio,
    certifications: certifications,
    experience: experience,
  );

  static String _requiredString(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw;
    throw const FormatException('myTrainer');
  }

  static String? _optionalString(Object? raw) =>
      raw is String && raw.trim().isNotEmpty ? raw : null;
}
