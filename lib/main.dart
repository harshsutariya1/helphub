import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helphub/router/app_router.dart';
import 'package:helphub/utils/logger.dart';

void main() async {
  // Global error handling for Dart errors outside the Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.f('🚨 Uncaught Platform Error', error: error, stackTrace: stack);
    // TODO: Send to Crashlytics or Sentry here in production
    return true; // Prevents the app from crashing entirely if possible
  };

  try {
    logger.i('🚀 Starting application initialization...');
    WidgetsFlutterBinding.ensureInitialized();

    // Global error handling for Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.f(
        '🚨 Flutter Framework Error',
        error: details.exception,
        stackTrace: details.stack,
      );
      // TODO: Send to Crashlytics or Sentry here in production
      FlutterError.presentError(details);
    };

    // Load environment variables (consider multiple .env files for dev/stg/prod)
    await dotenv.load(fileName: ".env");
    logger.d('✅ Environment variables loaded successfully.');

    await Supabase.initialize(
      
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    logger.d('✅ Supabase initialized successfully.');

    logger.i('🎉 Application initialization complete. Running app...');
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    logger.f(
      '❌ Failed to initialize application',
      error: e,
      stackTrace: stackTrace,
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HelpHub',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}
