import '../../domain/entities/hierarchy_node.dart';
import '../../domain/entities/law.dart';
import '../../domain/repositories/i_law_repository.dart';
import '../../infrastructure/database/database_helper.dart';
import '../datasources/law_local_datasource.dart';
import '../models/hierarchy_node_model.dart';
import '../models/law_model.dart';

class LawRepositoryImpl implements ILawRepository {
  LawRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  @override
  Future<List<Law>> getAllLaws() async {
    final db = await _databaseHelper.database;
    final rows = await LawLocalDataSource.getAllLaws(db);
    return rows.map(LawModel.fromMap).toList();
  }

  @override
  Future<Law?> getLawById(String id) async {
    final db = await _databaseHelper.database;
    final row = await LawLocalDataSource.getLawById(db, id);
    return row == null ? null : LawModel.fromMap(row);
  }

  @override
  Future<List<HierarchyNode>> getHierarchyForLaw(String lawId) async {
    final db = await _databaseHelper.database;
    final rows = await LawLocalDataSource.getHierarchyForLaw(db, lawId);
    return rows.map(HierarchyNodeModel.fromMap).toList();
  }

  @override
  Future<List<HierarchyNode>> getChildNodes(
    String lawId,
    String? parentId,
  ) async {
    final db = await _databaseHelper.database;
    final rows = await LawLocalDataSource.getChildNodes(db, lawId, parentId);
    return rows.map(HierarchyNodeModel.fromMap).toList();
  }
}
