import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:helphub/router/app_router.dart';
import 'package:helphub/utils/logger.dart';
import 'package:helphub/widgets/app_init_error_screen.dart';

void main() async {
  _setupErrorHandlers();

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeDependencies();

    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    logger.f(
      '❌ Failed to initialize application',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(const AppInitErrorScreen());
  }
}

/// Configures global error handling for both Flutter API and Dart Platform errors.
void _setupErrorHandlers() {
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.f('🚨 Uncaught Platform Error', error: error, stackTrace: stack);
    // TODO: Send to Crashlytics or Sentry here in production
    return true; // Prevents the app from crashing entirely if possible
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    logger.f(
      '🚨 Flutter Framework Error',
      error: details.exception,
      stackTrace: details.stack,
    );
    // TODO: Send to Crashlytics or Sentry here in production
    FlutterError.presentError(details);
  };
}

/// Initializes external services required before the app starts.
Future<void> _initializeDependencies() async {
  logger.i('🚀 Starting application initialization...');

  // Load environment variables
  await dotenv.load(fileName: ".env");
  logger.d('✅ Environment variables loaded successfully.');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file.');
  }

  // Initialize Backend DB
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  logger.d('✅ Supabase initialized successfully.');

  logger.i('🎉 Application initialization complete.');
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
