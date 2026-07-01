import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/core/navigation/app_shell.dart';
import 'package:kendo_companion/src/features/guidance/presentation/guidance_detail_screen.dart';
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
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.newSession,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: const NewSessionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.sessionDetail,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: SessionDetailScreen(
            sessionId: state.pathParameters['sessionId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.newGuidance,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: GuidanceDetailScreen(
            sessionId: state.pathParameters['sessionId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.guidanceDetail,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: GuidanceDetailScreen(
            sessionId: state.pathParameters['sessionId']!,
            guidanceId: state.pathParameters['guidanceId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.momentVideoPreview,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: MomentVideoPreviewScreen(
            sessionId: state.pathParameters['sessionId']!,
            sourcePath: state.extra! as String,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.momentDetail,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: MomentDetailScreen(
            momentId: state.pathParameters['momentId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.newPracticeTopic,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: const NewPracticeTopicScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.practiceTopicDetail,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: PracticeTopicDetailScreen(
            topicId: state.pathParameters['topicId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.learnCategory,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: LearnTopicListScreen(
            category: LearnCategory.values.byName(
              state.pathParameters['category']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.learnTopicDetail,
        pageBuilder: (context, state) => _fadeSlide(
          state: state,
          child: LearnTopicDetailScreen(
            topicId: state.pathParameters['topicId']!,
          ),
        ),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

CustomTransitionPage<void> _fadeSlide({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
