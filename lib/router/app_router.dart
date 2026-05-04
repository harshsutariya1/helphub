import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:helphub/services/auth_repository.dart';
import 'package:helphub/screens/login_screen.dart';
import 'package:helphub/screens/signup_screen.dart';
import 'package:helphub/screens/home_page.dart';

part 'app_router.g.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) {
      notifyListeners();
    });
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading || !authState.hasValue) {
        return null; // Don't redirect while auth state is loading
      }

      final isAuthenticated = authState.value?.session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MyHomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
    ],
  );
}
