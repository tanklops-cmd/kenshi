enum SearchResultType {
  session('Sessions', 'Session'),
  practice('Practice', 'Practice Topic'),
  learn('Learn', 'Learn Topic'),
  moment('Moments', 'Moment');

  const SearchResultType(this.groupLabel, this.typeLabel);

  final String groupLabel;
  final String typeLabel;
}

class SearchResult {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    this.parentId,
    this.date,
    this.detailLabel,
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String preview;
  final String? parentId;
  final DateTime? date;
  final String? detailLabel;

  String get typeLabel => detailLabel ?? type.typeLabel;
}
