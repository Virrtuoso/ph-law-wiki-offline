/// Raw SQL statements defining the offline database schema.
///
/// The schema is intentionally denormalized-friendly for read-heavy,
/// offline-first usage: a small set of tables covering the law catalogue,
/// its hierarchy, article bodies, full-text search, cross references,
/// and user-generated bookmarks/notes.
class Schema {
  Schema._();

  static const int schemaVersion = 1;

  static const String createLaws = '''
    CREATE TABLE laws (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      code TEXT NOT NULL,
      jurisdiction TEXT NOT NULL DEFAULT 'Philippines',
      version_date TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'in_force',
      source_url TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const String createHierarchyNodes = '''
    CREATE TABLE hierarchy_nodes (
      id TEXT PRIMARY KEY,
      law_id TEXT NOT NULL,
      parent_id TEXT,
      type TEXT NOT NULL,
      number TEXT NOT NULL,
      title TEXT NOT NULL,
      order_index INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(law_id) REFERENCES laws(id)
    )
  ''';

  static const String createArticles = '''
    CREATE TABLE articles (
      id TEXT PRIMARY KEY,
      law_id TEXT NOT NULL,
      node_id TEXT,
      article_number TEXT NOT NULL,
      title TEXT,
      body TEXT NOT NULL,
      effective_from TEXT,
      effective_to TEXT,
      order_index INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(law_id) REFERENCES laws(id),
      FOREIGN KEY(node_id) REFERENCES hierarchy_nodes(id)
    )
  ''';

  static const String createArticlesFts = '''
    CREATE VIRTUAL TABLE articles_fts USING fts5(
      article_id UNINDEXED,
      law_id UNINDEXED,
      article_number,
      title,
      body,
      content='articles',
      content_rowid='rowid'
    )
  ''';

  // Triggers keep the FTS index in sync with the articles table.
  static const String createArticlesFtsInsertTrigger = '''
    CREATE TRIGGER articles_ai AFTER INSERT ON articles BEGIN
      INSERT INTO articles_fts(rowid, article_id, law_id, article_number, title, body)
      VALUES (new.rowid, new.id, new.law_id, new.article_number, new.title, new.body);
    END
  ''';

  static const String createArticlesFtsDeleteTrigger = '''
    CREATE TRIGGER articles_ad AFTER DELETE ON articles BEGIN
      INSERT INTO articles_fts(articles_fts, rowid, article_id, law_id, article_number, title, body)
      VALUES('delete', old.rowid, old.id, old.law_id, old.article_number, old.title, old.body);
    END
  ''';

  static const String createArticlesFtsUpdateTrigger = '''
    CREATE TRIGGER articles_au AFTER UPDATE ON articles BEGIN
      INSERT INTO articles_fts(articles_fts, rowid, article_id, law_id, article_number, title, body)
      VALUES('delete', old.rowid, old.id, old.law_id, old.article_number, old.title, old.body);
      INSERT INTO articles_fts(rowid, article_id, law_id, article_number, title, body)
      VALUES (new.rowid, new.id, new.law_id, new.article_number, new.title, new.body);
    END
  ''';

  static const String createCrossReferences = '''
    CREATE TABLE cross_references (
      id TEXT PRIMARY KEY,
      from_article_id TEXT NOT NULL,
      to_article_id TEXT NOT NULL,
      ref_text TEXT NOT NULL,
      FOREIGN KEY(from_article_id) REFERENCES articles(id),
      FOREIGN KEY(to_article_id) REFERENCES articles(id)
    )
  ''';

  static const String createBookmarks = '''
    CREATE TABLE bookmarks (
      id TEXT PRIMARY KEY,
      article_id TEXT NOT NULL UNIQUE,
      created_at TEXT NOT NULL,
      FOREIGN KEY(article_id) REFERENCES articles(id)
    )
  ''';

  static const String createNotes = '''
    CREATE TABLE notes (
      id TEXT PRIMARY KEY,
      article_id TEXT NOT NULL UNIQUE,
      note_text TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY(article_id) REFERENCES articles(id)
    )
  ''';

  static const String createAppMetadata = '''
    CREATE TABLE app_metadata (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  /// Statements for core schema objects that do not require optional SQLite
  /// modules.
  static const List<String> createCoreStatements = [
    createLaws,
    createHierarchyNodes,
    createArticles,
    createCrossReferences,
    createBookmarks,
    createNotes,
    createAppMetadata,
  ];

  /// Statements for optional FTS objects.
  static const List<String> createFtsStatements = [
    createArticlesFts,
    createArticlesFtsInsertTrigger,
    createArticlesFtsDeleteTrigger,
    createArticlesFtsUpdateTrigger,
  ];
}
