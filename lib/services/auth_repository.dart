import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helphub/services/supabase_provider.dart';
import 'package:helphub/models/user_profile.dart'; // Replaced app_user.dart with user_profile.dart

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  UserProfile? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return user.toUserProfile();
  }

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse?> signInWithGoogle() async {
    return null;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseProvider));
}

@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
