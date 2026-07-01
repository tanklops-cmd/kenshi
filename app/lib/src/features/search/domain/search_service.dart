import 'package:kendo_companion/src/features/search/domain/search_result.dart';

abstract interface class SearchService {
  Future<List<SearchResult>> search(String query);
}
