import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/auth_block.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/home_page.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/login_page.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/register_page.dart';
import 'package:kanban_frontend/features/auth/presentation/screens/splash_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  GoRouter get router => GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;

        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToSplash = state.matchedLocation == '/splash';
        final isGoingToRegister = state.matchedLocation == '/register';

        if (authState is AuthUnauthenticated || authState is AuthError) {
          return isGoingToLogin ? null : '/login';
        }

        if (authState is AuthRegistering) {
          return isGoingToRegister ? null : '/register';
        }

        if (authState is AuthAuthenticated) {
          if (isGoingToLogin || isGoingToSplash) {
            return '/home';
          }
        }
        return null;
      },
      routes: [
        GoRoute(path:'/splash', builder: (context, state) =>  const SplashPage()),
        GoRoute(path:'/login', builder: (context, state) =>  const LoginPage()),
        GoRoute(path:'/register', builder: (context, state) =>  const RegisterPage()),
        GoRoute(path:'/home', builder: (context, state) =>  const HomePage()),
      ]);
}

class GoRouterRefreshStream extends ChangeNotifier{
  GoRouterRefreshStream(Stream stream){
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) => notifyListeners());
  }

  late final StreamSubscription _subscription;
}
