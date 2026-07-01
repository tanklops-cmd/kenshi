import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/core/navigation/app_shell.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';
import 'package:kendo_companion/src/features/learn/presentation/learn_screen.dart';
import 'package:kendo_companion/src/features/learn/presentation/learn_topic_detail_screen.dart';
import 'package:kendo_companion/src/features/learn/presentation/learn_topic_list_screen.dart';
import 'package:kendo_companion/src/features/moment/presentation/moment_detail_screen.dart';
import 'package:kendo_companion/src/features/moment/presentation/moment_video_preview_screen.dart';
import 'package:kendo_companion/src/features/practice/presentation/new_practice_topic_screen.dart';
import 'package:kendo_companion/src/features/practice/presentation/practice_screen.dart';
import 'package:kendo_companion/src/features/practice/presentation/practice_topic_detail_screen.dart';
import 'package:kendo_companion/src/features/prepare/presentation/prepare_screen.dart';
import 'package:kendo_companion/src/features/reflect/presentation/reflect_screen.dart';
import 'package:kendo_companion/src/features/search/presentation/search_screen.dart';
import 'package:kendo_companion/src/features/session/presentation/new_session_screen.dart';
import 'package:kendo_companion/src/features/session/presentation/session_detail_screen.dart';
import 'package:kendo_companion/src/features/today/presentation/today_screen.dart';

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
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.newSession,
        builder: (context, state) => const NewSessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionDetail,
        builder: (context, state) {
          return SessionDetailScreen(
            sessionId: state.pathParameters['sessionId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.momentVideoPreview,
        builder: (context, state) {
          return MomentVideoPreviewScreen(
            sessionId: state.pathParameters['sessionId']!,
            sourcePath: state.extra! as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.momentDetail,
        builder: (context, state) {
          return MomentDetailScreen(
            momentId: state.pathParameters['momentId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.newPracticeTopic,
        builder: (context, state) => const NewPracticeTopicScreen(),
      ),
      GoRoute(
        path: AppRoutes.practiceTopicDetail,
        builder: (context, state) {
          return PracticeTopicDetailScreen(
            topicId: state.pathParameters['topicId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.learnCategory,
        builder: (context, state) {
          return LearnTopicListScreen(
            category: LearnCategory.values.byName(
              state.pathParameters['category']!,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.learnTopicDetail,
        builder: (context, state) {
          return LearnTopicDetailScreen(
            topicId: state.pathParameters['topicId']!,
          );
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
