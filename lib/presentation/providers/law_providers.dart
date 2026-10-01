import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/hierarchy_node.dart';
import '../../domain/entities/law.dart';
import 'repository_providers.dart';

/// All laws in the local catalogue, used for the home screen's
/// quick-access cards and the law browse screen.
final lawsProvider = FutureProvider<List<Law>>((ref) {
  return ref.watch(lawRepositoryProvider).getAllLaws();
});

final lawByIdProvider = FutureProvider.family<Law?, String>((ref, lawId) {
  return ref.watch(lawRepositoryProvider).getLawById(lawId);
});

/// Parameters for [childNodesProvider]: the parent law and, optionally,
/// the parent hierarchy node (null = top-level nodes of that law).
class ChildNodesParams {
  final String lawId;
  final String? parentId;

  const ChildNodesParams(this.lawId, this.parentId);

  @override
  bool operator ==(Object other) =>
      other is ChildNodesParams &&
      other.lawId == lawId &&
      other.parentId == parentId;

  @override
  int get hashCode => Object.hash(lawId, parentId);
}

final childNodesProvider =
    FutureProvider.family<List<HierarchyNode>, ChildNodesParams>((
      ref,
      params,
    ) {
      return ref
          .watch(lawRepositoryProvider)
          .getChildNodes(params.lawId, params.parentId);
    });

final hierarchyForLawProvider =
    FutureProvider.family<List<HierarchyNode>, String>((ref, lawId) {
      return ref.watch(lawRepositoryProvider).getHierarchyForLaw(lawId);
    });
