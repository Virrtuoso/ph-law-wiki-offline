import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ph_law_wiki_offline/domain/entities/article.dart';
import 'package:ph_law_wiki_offline/domain/entities/bookmark.dart';
import 'package:ph_law_wiki_offline/domain/entities/cross_reference.dart';
import 'package:ph_law_wiki_offline/domain/entities/hierarchy_node.dart';
import 'package:ph_law_wiki_offline/domain/entities/law.dart';
import 'package:ph_law_wiki_offline/domain/entities/note.dart';
import 'package:ph_law_wiki_offline/domain/entities/search_result.dart';
import 'package:ph_law_wiki_offline/domain/repositories/i_article_repository.dart';
import 'package:ph_law_wiki_offline/domain/repositories/i_bookmark_repository.dart';
import 'package:ph_law_wiki_offline/domain/repositories/i_law_repository.dart';
import 'package:ph_law_wiki_offline/domain/repositories/i_note_repository.dart';
import 'package:ph_law_wiki_offline/domain/repositories/i_search_repository.dart';
import 'package:ph_law_wiki_offline/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Seed data – mirrors the subset required by widget tests
// ---------------------------------------------------------------------------

const _kNow = '2024-01-01T00:00:00.000Z';

final _seedLaws = <Law>[
  const Law(
    id: 'civil-code-ra386',
    title: 'Civil Code of the Philippines (Republic Act No. 386)',
    code: 'R.A. 386',
    jurisdiction: 'Philippines',
    versionDate: '1950-08-30',
    status: 'in_force',
    createdAt: _kNow,
  ),
  const Law(
    id: 'const-1987',
    title: '1987 Constitution of the Republic of the Philippines',
    code: 'CONST 1987',
    jurisdiction: 'Philippines',
    versionDate: '1987-02-02',
    status: 'in_force',
    createdAt: _kNow,
  ),
  const Law(
    id: 'flag-code-ra8491',
    title:
        'Flag and Heraldic Code of the Philippines (Republic Act No. 8491)',
    code: 'R.A. 8491',
    jurisdiction: 'Philippines',
    versionDate: '1998-02-12',
    status: 'in_force',
    createdAt: _kNow,
  ),
];

final _seedHierarchyNodes = <HierarchyNode>[
  const HierarchyNode(
    id: 'cc-book1',
    lawId: 'civil-code-ra386',
    parentId: null,
    type: 'Book',
    number: 'I',
    title: 'Preliminary Title',
    orderIndex: 0,
  ),
  const HierarchyNode(
    id: 'cc-book1-title1',
    lawId: 'civil-code-ra386',
    parentId: 'cc-book1',
    type: 'Title',
    number: 'I',
    title: 'Effect and Application of Laws',
    orderIndex: 0,
  ),
  const HierarchyNode(
    id: 'cc-book1-title1-ch1',
    lawId: 'civil-code-ra386',
    parentId: 'cc-book1-title1',
    type: 'Chapter',
    number: '1',
    title: 'Civil Personality',
    orderIndex: 0,
  ),
  const HierarchyNode(
    id: 'const-art3',
    lawId: 'const-1987',
    parentId: null,
    type: 'Article',
    number: 'III',
    title: 'Bill of Rights',
    orderIndex: 1,
  ),
  const HierarchyNode(
    id: 'flag-chapter1',
    lawId: 'flag-code-ra8491',
    parentId: null,
    type: 'Chapter',
    number: '1',
    title: 'The National Flag',
    orderIndex: 0,
  ),
];

final _seedArticles = <Article>[
  const Article(
    id: 'cc-art-37',
    lawId: 'civil-code-ra386',
    nodeId: 'cc-book1-title1-ch1',
    articleNumber: 'Art. 37',
    title: 'Juridical Capacity and Capacity to Act',
    body:
        'Juridical capacity, which is the fitness to be the subject of '
        'legal relations, is inherent in every natural person and is '
        'lost only through death. Capacity to act, which is the power '
        'to do acts with legal effect, is acquired and may be lost.',
    orderIndex: 0,
  ),
  const Article(
    id: 'cc-art-38',
    lawId: 'civil-code-ra386',
    nodeId: 'cc-book1-title1-ch1',
    articleNumber: 'Art. 38',
    title: 'Restrictions on Capacity to Act',
    body:
        'Minority, insanity or imbecility, the state of being a deaf-mute, '
        'prodigality and civil interdiction are mere restrictions on capacity '
        'to act, and do not exempt the incapacitated person from certain '
        'obligations, as when the latter arise from his acts or from property '
        'relations, such as easements.',
    orderIndex: 1,
  ),
  const Article(
    id: 'cc-art-44',
    lawId: 'civil-code-ra386',
    nodeId: 'cc-book1-title1-ch1',
    articleNumber: 'Art. 44',
    title: 'Juridical Persons',
    body:
        'The following are juridical persons: (1) The State and its '
        'political subdivisions; (2) Other corporations, institutions '
        'and entities for public interest or purpose, created by law.',
    orderIndex: 2,
  ),
  const Article(
    id: 'const-preamble',
    lawId: 'const-1987',
    nodeId: null,
    articleNumber: 'Preamble',
    title: 'Preamble',
    body:
        'We, the sovereign Filipino people, imploring the aid of Almighty '
        'God, in order to build a just and humane society and establish a '
        'Government that shall embody our ideals and aspirations.',
    orderIndex: 0,
  ),
  const Article(
    id: 'const-art3-sec1',
    lawId: 'const-1987',
    nodeId: 'const-art3',
    articleNumber: 'Sec. 1',
    title: 'Due Process and Equal Protection',
    body:
        'No person shall be deprived of life, liberty, or property without '
        'due process of law, nor shall any person be denied the equal '
        'protection of the laws.',
    orderIndex: 1,
  ),
  const Article(
    id: 'flag-sec1',
    lawId: 'flag-code-ra8491',
    nodeId: 'flag-chapter1',
    articleNumber: 'Sec. 1',
    title: 'Short Title',
    body:
        'This Act shall be known as the "Flag and Heraldic Code of the '
        'Philippines".',
    orderIndex: 0,
  ),
  const Article(
    id: 'flag-sec2',
    lawId: 'flag-code-ra8491',
    nodeId: 'flag-chapter1',
    articleNumber: 'Sec. 2',
    title: 'Declaration of Policy',
    body:
        'It is hereby declared to be the policy of the State to dignify the '
        'flag, the anthem, and other national symbols which embody the '
        "nation's ideals.",
    orderIndex: 1,
  ),
];

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class _FakeLawRepository implements ILawRepository {
  @override
  Future<List<Law>> getAllLaws() async => List.unmodifiable(_seedLaws);

  @override
  Future<Law?> getLawById(String id) async {
    try {
      return _seedLaws.firstWhere((l) => l.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<HierarchyNode>> getHierarchyForLaw(String lawId) async =>
      _seedHierarchyNodes.where((n) => n.lawId == lawId).toList();

  @override
  Future<List<HierarchyNode>> getChildNodes(
    String lawId,
    String? parentId,
  ) async =>
      _seedHierarchyNodes
          .where((n) => n.lawId == lawId && n.parentId == parentId)
          .toList();
}

class _FakeArticleRepository implements IArticleRepository {
  @override
  Future<Article?> getArticleById(String id) async {
    try {
      return _seedArticles.firstWhere((a) => a.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<Article>> getArticlesForLaw(String lawId) async =>
      _seedArticles.where((a) => a.lawId == lawId).toList();

  @override
  Future<List<Article>> getArticlesForNode(String nodeId) async =>
      _seedArticles.where((a) => a.nodeId == nodeId).toList();

  @override
  Future<List<CrossReference>> getCrossReferencesFrom(
    String articleId,
  ) async => [];

  @override
  Future<List<CrossReference>> getCrossReferencesTo(
    String articleId,
  ) async => [];
}

class _FakeSearchRepository implements ISearchRepository {
  @override
  Future<List<SearchResult>> search(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final results = <SearchResult>[];
    for (final article in _seedArticles) {
      final law = _seedLaws.firstWhere(
        (l) => l.id == article.lawId,
        orElse: () => _seedLaws.first,
      );
      if (article.articleNumber.toLowerCase().contains(q) ||
          (article.title?.toLowerCase().contains(q) ?? false) ||
          article.body.toLowerCase().contains(q) ||
          law.title.toLowerCase().contains(q) ||
          law.code.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            articleId: article.id,
            lawId: law.id,
            lawTitle: law.title,
            lawCode: law.code,
            articleNumber: article.articleNumber,
            articleTitle: article.title,
            snippet: article.body.length > 80
                ? '${article.body.substring(0, 80)}…'
                : article.body,
          ),
        );
      }
    }
    return results.take(limit).toList();
  }
}

class _FakeBookmarkRepository implements IBookmarkRepository {
  final Map<String, Bookmark> _bookmarks = {};

  @override
  Future<List<Bookmark>> getAllBookmarks() async =>
      _bookmarks.values.toList();

  @override
  Future<Bookmark?> getBookmarkForArticle(String articleId) async =>
      _bookmarks[articleId];

  @override
  Future<bool> isBookmarked(String articleId) async =>
      _bookmarks.containsKey(articleId);

  @override
  Future<void> addBookmark(String articleId) async {
    _bookmarks[articleId] = Bookmark(
      id: 'bm-$articleId',
      articleId: articleId,
      createdAt: _kNow,
    );
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    _bookmarks.remove(articleId);
  }

  @override
  Future<void> toggleBookmark(String articleId) async {
    if (_bookmarks.containsKey(articleId)) {
      await removeBookmark(articleId);
    } else {
      await addBookmark(articleId);
    }
  }
}

class _FakeNoteRepository implements INoteRepository {
  final Map<String, Note> _notes = {};

  @override
  Future<List<Note>> getAllNotes() async => _notes.values.toList();

  @override
  Future<Note?> getNoteForArticle(String articleId) async =>
      _notes[articleId];

  @override
  Future<void> saveNote(String articleId, String noteText) async {
    _notes[articleId] = Note(
      id: 'note-$articleId',
      articleId: articleId,
      noteText: noteText,
      createdAt: _kNow,
      updatedAt: _kNow,
    );
  }

  @override
  Future<void> deleteNote(String articleId) async {
    _notes.remove(articleId);
  }
}

// ---------------------------------------------------------------------------
// Public helpers
// ---------------------------------------------------------------------------

/// No-op kept for API compatibility; FFI init is no longer needed.
// ignore: no-op-functions
void ensureFfiInitialized() {}

/// Returns Riverpod [Override]s that replace every repository provider with
/// a deterministic, in-memory fake so widget tests never touch SQLite/FFI.
Future<List<Override>> buildTestOverrides() async {
  return [
    lawRepositoryProvider.overrideWithValue(_FakeLawRepository()),
    articleRepositoryProvider.overrideWithValue(_FakeArticleRepository()),
    searchRepositoryProvider.overrideWithValue(_FakeSearchRepository()),
    bookmarkRepositoryProvider.overrideWithValue(_FakeBookmarkRepository()),
    noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
    appInitProvider.overrideWith((ref) async {}),
  ];
}

/// Pumps frames in fixed steps until [finder] matches at least one widget.
/// Fails with a clear error instead of hanging on unbounded settle calls.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 60,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
  throw TestFailure(
    'Timed out waiting for: ${finder.describeMatch(Plurality.many)}',
  );
}
