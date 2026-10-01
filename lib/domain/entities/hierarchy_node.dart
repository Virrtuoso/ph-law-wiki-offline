/// A node in a law's structural hierarchy (e.g. Book, Title, Chapter, Part).
class HierarchyNode {
  final String id;
  final String lawId;
  final String? parentId;
  final String type;
  final String number;
  final String title;
  final int orderIndex;

  const HierarchyNode({
    required this.id,
    required this.lawId,
    this.parentId,
    required this.type,
    required this.number,
    required this.title,
    this.orderIndex = 0,
  });

  /// A human readable label, e.g. "Chapter 1: Civil Personality".
  String get label => '$type $number: $title';

  @override
  bool operator ==(Object other) => other is HierarchyNode && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
