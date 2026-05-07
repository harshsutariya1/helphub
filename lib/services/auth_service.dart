import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helphub/utils/logger.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
});

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    logger.i('🔑 Attempting to sign in user with email: $email');
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // 't' is for trace, let's use 'i' or 'd' for valid logs to avoid issues depending on logger config.
      logger.i('✅ Successfully signed in user ID: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      logger.w('⚠️ Supabase Auth error during sign in', error: e);
      rethrow;
    } catch (e, st) {
      logger.e('🛑 Unexpected error during sign in', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password, {
    String? fullName,
  }) async {
    logger.i('📝 Attempting to sign up user with email: $email');
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      logger.i('✅ Successfully signed up user ID: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      logger.w('⚠️ Supabase Auth error during sign up', error: e);
      rethrow;
    } catch (e, st) {
      logger.e('🛑 Unexpected error during sign up', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    logger.i('🚪 Attempting to sign out user...');
    try {
      await _supabase.auth.signOut();
      logger.i('✅ Successfully signed out user.');
    } on AuthException catch (e) {
      logger.w('⚠️ Supabase Auth error during sign out', error: e);
      rethrow;
    } catch (e, st) {
      logger.e('🛑 Unexpected error during sign out', error: e, stackTrace: st);
      rethrow;
    }
  }
}
