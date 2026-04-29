import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:kanban_frontend/core/routing/app_routes.dart';
import 'package:kanban_frontend/core/ui/Screens/main_shell_screen.dart';
import 'package:kanban_frontend/core/ui/Screens/mock_feature_screen.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';
import 'package:kanban_frontend/features/boards/presentation/screens/boards_screen.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/home_page.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/login_page.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/register_page.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/splash_page.dart';
import 'package:kanban_frontend/features/projects/presentation/screens/project_info_card_demo_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  GoRouter get router => GoRouter(
        initialLocation: AppRoutes.splash,
        refreshListenable: GoRouterRefreshStream(authBloc.stream),
        redirect: (context, state) {
          final authState = authBloc.state;

          final isGoingToLogin = state.matchedLocation == AppRoutes.login;
          final isGoingToSplash = state.matchedLocation == AppRoutes.splash;
          final isGoingToRegister = state.matchedLocation == AppRoutes.register;

          if (authState is AuthUnauthenticated || authState is AuthError) {
            return isGoingToLogin ? null : AppRoutes.login;
          }

          if (authState is AuthRegistrationSuccess) {
            return isGoingToLogin ? null : AppRoutes.login;
          }

          if (authState is AuthRegistering) {
            return isGoingToRegister ? null : AppRoutes.register;
          }

          if (authState is AuthAuthenticated) {
            if (isGoingToLogin || isGoingToSplash) {
              return AppRoutes.home;
            }
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (context, state) => const RegisterPage(),
          ),
          ShellRoute(
            builder: (context, state, child) {
              return MainShellScreen(
                currentLocation: state.matchedLocation,
                child: child,
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomePage(),
                ),
              ),
              GoRoute(
                path: AppRoutes.projects,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const ProjectInfoCardDemoScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.boards,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const BoardsScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.lists,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const MockFeatureScreen(title: 'Lists'),
                ),
              ),
              GoRoute(
                path: AppRoutes.tasks,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const MockFeatureScreen(title: 'Tasks'),
                ),
              ),
            ],
          ),
        ],
      );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (event) => notifyListeners(),
        );
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
