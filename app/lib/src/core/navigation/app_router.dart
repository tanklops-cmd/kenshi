import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_shell.dart';
import 'package:kendo_companion/src/features/learn/presentation/learn_screen.dart';
import 'package:kendo_companion/src/features/practice/presentation/practice_screen.dart';
import 'package:kendo_companion/src/features/prepare/presentation/prepare_screen.dart';
import 'package:kendo_companion/src/features/reflect/presentation/reflect_screen.dart';
import 'package:kendo_companion/src/features/today/presentation/today_screen.dart';

abstract final class AppRoutes {
  static const today = '/today';
  static const reflect = '/reflect';
  static const practice = '/practice';
  static const learn = '/learn';
  static const prepare = '/prepare';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reflect,
                builder: (context, state) => const ReflectScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.practice,
                builder: (context, state) => const PracticeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                builder: (context, state) => const LearnScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.prepare,
                builder: (context, state) => const PrepareScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
