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

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(
      authStateProvider,
      (previous, next) {
        logger.i('🔄 RouterNotifier: authState changed from ${previous?.value?.event} to ${next.value?.event}');
        notifyListeners();
      },
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      logger.d('🚦 Navigation: Evaluating redirect. Loading: ${authState.isLoading}, HasValue: ${authState.hasValue}');

      // If still loading and no initial value, wait on splash
      if (authState.isLoading && !authState.hasValue) return '/splash';

      final user = authState.value?.session?.user ?? ref.read(authServiceProvider).currentUser;
      final isLoggedIn = user != null;
      
      // state.matchedLocation can sometimes be inaccurate during deep linking, uri.path is safer in GoRouter 14+
      final location = state.uri.path;
      final isSplash = location == '/splash';
      final isGoingToAuth = location == '/login' || location == '/signup';

      logger.d('🚦 Navigation Details: location=$location, isLoggedIn=$isLoggedIn, isSplash=$isSplash, isGoingToAuth=$isGoingToAuth');

      if (isSplash) {
        final redirectPath = isLoggedIn ? '/home' : '/login';
        logger.i('🚦 Redirecting from splash to $redirectPath');
        return redirectPath;
      }

      if (!isLoggedIn && !isGoingToAuth) {
        logger.i('🚦 Navigation: Redirecting unauthenticated user to /login from $location');
        return '/login';
      }
      
      if (isLoggedIn && isGoingToAuth) {
        logger.i('🚦 Navigation: Redirecting authenticated user to /home from $location');
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
