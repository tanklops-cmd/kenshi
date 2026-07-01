import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/features/learn/data/seeded_learn_repository.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_repository.dart';

final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return const SeededLearnRepository();
});
