/// Represents a Philippine law, act, or statute (e.g. the Civil Code).
class Law {
  final String id;
  final String title;
  final String code;
  final String jurisdiction;
  final String versionDate;
  final String status;
  final String? sourceUrl;
  final String createdAt;

  const Law({
    required this.id,
    required this.title,
    required this.code,
    this.jurisdiction = 'Philippines',
    required this.versionDate,
    this.status = 'in_force',
    this.sourceUrl,
    required this.createdAt,
  });

  Law copyWith({
    String? id,
    String? title,
    String? code,
    String? jurisdiction,
    String? versionDate,
    String? status,
    String? sourceUrl,
    String? createdAt,
  }) {
    return Law(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      versionDate: versionDate ?? this.versionDate,
      status: status ?? this.status,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Law && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Law($code: $title)';
}
