import '../../domain/entities/law.dart';

/// Maps between the `laws` table rows and the [Law] domain entity.
class LawModel {
  LawModel._();

  static Law fromMap(Map<String, Object?> map) {
    return Law(
      id: map['id'] as String,
      title: map['title'] as String,
      code: map['code'] as String,
      jurisdiction: map['jurisdiction'] as String? ?? 'Philippines',
      versionDate: map['version_date'] as String,
      status: map['status'] as String? ?? 'in_force',
      sourceUrl: map['source_url'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  static Map<String, Object?> toMap(Law law) {
    return {
      'id': law.id,
      'title': law.title,
      'code': law.code,
      'jurisdiction': law.jurisdiction,
      'version_date': law.versionDate,
      'status': law.status,
      'source_url': law.sourceUrl,
      'created_at': law.createdAt,
    };
  }
}
