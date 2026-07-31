import '../entities/law.dart';
import '../entities/hierarchy_node.dart';

/// Read-only access to the catalogue of laws and their hierarchy nodes.
abstract class ILawRepository {
  Future<List<Law>> getAllLaws();
  Future<Law?> getLawById(String id);
  Future<List<HierarchyNode>> getHierarchyForLaw(String lawId);
  Future<List<HierarchyNode>> getChildNodes(String lawId, String? parentId);
}
