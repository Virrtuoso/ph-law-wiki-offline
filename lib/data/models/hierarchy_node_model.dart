import '../../domain/entities/hierarchy_node.dart';

/// Maps between the `hierarchy_nodes` table rows and [HierarchyNode].
class HierarchyNodeModel {
  HierarchyNodeModel._();

  static HierarchyNode fromMap(Map<String, Object?> map) {
    return HierarchyNode(
      id: map['id'] as String,
      lawId: map['law_id'] as String,
      parentId: map['parent_id'] as String?,
      type: map['type'] as String,
      number: map['number'] as String,
      title: map['title'] as String,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  static Map<String, Object?> toMap(HierarchyNode node) {
    return {
      'id': node.id,
      'law_id': node.lawId,
      'parent_id': node.parentId,
      'type': node.type,
      'number': node.number,
      'title': node.title,
      'order_index': node.orderIndex,
    };
  }
}
