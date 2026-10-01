import '../entities/article.dart';
import '../entities/law.dart';

/// Formats a human-readable legal citation from a [Law] and [Article].
///
/// Examples:
///   formatCitation(law: civilCode, article: art37)
///     => "Civil Code of the Philippines (Republic Act No. 386), Art. 37"
///   formatCitation(law: civilCode, article: art37, short: true)
///     => "R.A. 386, Art. 37"
String formatCitation({
  required Law law,
  required Article article,
  bool short = false,
  bool includeTitle = false,
}) {
  final lawPart = short ? law.code : law.title;
  final buffer = StringBuffer('$lawPart, ${article.articleNumber}');
  if (includeTitle && article.title != null && article.title!.isNotEmpty) {
    buffer.write(' (${article.title})');
  }
  return buffer.toString();
}
