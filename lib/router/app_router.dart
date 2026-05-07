import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helphub/controllers/auth_controller.dart';
import 'package:helphub/services/auth_service.dart';
import 'package:helphub/screens/splash_screen.dart';
import 'package:helphub/screens/login_screen.dart';
import 'package:helphub/screens/signup_screen.dart';
import 'package:helphub/screens/home_screen.dart';
import 'package:helphub/screens/profile_screen.dart';
import 'package:helphub/utils/logger.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(
      ref.watch(authServiceProvider).authStateChanges,
    ),
    redirect: (context, state) {
      // If authState is loading, keep on splash screen
      if (authState.isLoading) return '/splash';

      final user = ref.read(currentUserProvider);
      final isLoggedIn = user != null;
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/splash';

      // Redirect based on auth state
      if (!isLoggedIn && !isGoingToAuth) {
        logger.i(
          '🚦 Navigation: Redirecting unauthenticated user to /login from ${state.matchedLocation}',
        );
        return '/login';
      }
      if (isLoggedIn && isGoingToAuth) {
        logger.i(
          '🚦 Navigation: Redirecting authenticated user to /home from ${state.matchedLocation}',
        );
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
