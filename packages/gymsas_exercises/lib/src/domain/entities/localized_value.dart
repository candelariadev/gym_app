class LocalizedValue {
  const LocalizedValue({this.en, this.es});

  final String? en;
  final String? es;

  String resolve(String languageCode) {
    final preferred = languageCode.toLowerCase() == 'es' ? es : en;
    return _present(preferred) ?? _present(en) ?? _present(es) ?? '';
  }

  String? _present(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class LocalizedStringList {
  const LocalizedStringList({this.en = const [], this.es = const []});

  final List<String> en;
  final List<String> es;

  List<String> resolve(String languageCode) {
    final preferred = languageCode.toLowerCase() == 'es' ? es : en;
    if (preferred.isNotEmpty) return List.unmodifiable(preferred);
    return List.unmodifiable(en.isNotEmpty ? en : es);
  }
}
