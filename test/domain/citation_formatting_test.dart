import 'package:flutter_test/flutter_test.dart';
import 'package:ph_law_wiki_offline/domain/entities/article.dart';
import 'package:ph_law_wiki_offline/domain/entities/law.dart';
import 'package:ph_law_wiki_offline/domain/usecases/format_citation_usecase.dart';

void main() {
  final law = Law(
    id: 'civil-code-ra386',
    title: 'Civil Code of the Philippines (Republic Act No. 386)',
    code: 'R.A. 386',
    versionDate: '1950-08-30',
    createdAt: '2024-01-01T00:00:00.000Z',
  );

  final article = const Article(
    id: 'cc-art-37',
    lawId: 'civil-code-ra386',
    nodeId: 'cc-book1-title1-ch1',
    articleNumber: 'Art. 37',
    title: 'Juridical Capacity and Capacity to Act',
    body: 'Juridical capacity, which is the fitness to be the subject...',
  );

  group('formatCitation', () {
    test('formats the full citation with the law title', () {
      final citation = formatCitation(law: law, article: article);
      expect(
        citation,
        'Civil Code of the Philippines (Republic Act No. 386), Art. 37',
      );
    });

    test('formats the short citation with the law code', () {
      final citation = formatCitation(law: law, article: article, short: true);
      expect(citation, 'R.A. 386, Art. 37');
    });

    test('optionally includes the article title', () {
      final citation = formatCitation(
        law: law,
        article: article,
        short: true,
        includeTitle: true,
      );
      expect(
        citation,
        'R.A. 386, Art. 37 (Juridical Capacity and Capacity to Act)',
      );
    });

    test('omits the title suffix when the article has no title', () {
      const untitledArticle = Article(
        id: 'cc-art-37',
        lawId: 'civil-code-ra386',
        nodeId: 'cc-book1-title1-ch1',
        articleNumber: 'Art. 37',
        body: 'Juridical capacity, which is the fitness to be the subject...',
      );
      final citation = formatCitation(
        law: law,
        article: untitledArticle,
        short: true,
        includeTitle: true,
      );
      expect(citation, 'R.A. 386, Art. 37');
    });

    test('handles a Constitution-style Section citation', () {
      final constitution = Law(
        id: 'const-1987',
        title: '1987 Constitution of the Republic of the Philippines',
        code: 'CONST 1987',
        versionDate: '1987-02-02',
        createdAt: '2024-01-01T00:00:00.000Z',
      );
      final section = const Article(
        id: 'const-art3-sec1',
        lawId: 'const-1987',
        nodeId: 'const-art3',
        articleNumber: 'Sec. 1',
        title: 'Due Process and Equal Protection',
        body: 'No person shall be deprived of life, liberty, or property...',
      );
      final citation = formatCitation(
        law: constitution,
        article: section,
        short: true,
      );
      expect(citation, 'CONST 1987, Sec. 1');
    });
  });
}
