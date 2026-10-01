import '../../domain/entities/article.dart';
import '../../domain/entities/cross_reference.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../infrastructure/database/database_helper.dart';
import '../datasources/article_local_datasource.dart';
import '../models/article_model.dart';
import '../models/cross_reference_model.dart';

class ArticleRepositoryImpl implements IArticleRepository {
  ArticleRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  @override
  Future<Article?> getArticleById(String id) async {
    final db = await _databaseHelper.database;
    final row = await ArticleLocalDataSource.getArticleById(db, id);
    return row == null ? null : ArticleModel.fromMap(row);
  }

  @override
  Future<List<Article>> getArticlesForLaw(String lawId) async {
    final db = await _databaseHelper.database;
    final rows = await ArticleLocalDataSource.getArticlesForLaw(db, lawId);
    return rows.map(ArticleModel.fromMap).toList();
  }

  @override
  Future<List<Article>> getArticlesForNode(String nodeId) async {
    final db = await _databaseHelper.database;
    final rows = await ArticleLocalDataSource.getArticlesForNode(db, nodeId);
    return rows.map(ArticleModel.fromMap).toList();
  }

  @override
  Future<List<CrossReference>> getCrossReferencesFrom(String articleId) async {
    final db = await _databaseHelper.database;
    final rows = await ArticleLocalDataSource.getCrossReferencesFrom(
      db,
      articleId,
    );
    return rows.map(CrossReferenceModel.fromMap).toList();
  }

  @override
  Future<List<CrossReference>> getCrossReferencesTo(String articleId) async {
    final db = await _databaseHelper.database;
    final rows = await ArticleLocalDataSource.getCrossReferencesTo(
      db,
      articleId,
    );
    return rows.map(CrossReferenceModel.fromMap).toList();
  }
}
