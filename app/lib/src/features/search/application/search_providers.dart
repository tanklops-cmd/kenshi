import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/learn/application/learn_providers.dart';
import 'package:kendo_companion/src/features/search/data/local_search_service.dart';
import 'package:kendo_companion/src/features/search/domain/search_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return LocalSearchService(
    ref.watch(appDatabaseProvider),
    ref.watch(learnRepositoryProvider),
  );
});
