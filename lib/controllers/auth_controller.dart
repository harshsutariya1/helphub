import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:helphub/services/auth_service.dart';
import 'package:helphub/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helphub/utils/logger.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? ref.read(authServiceProvider).currentUser;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final authService = ref.watch(authServiceProvider);
      final storageService = ref.watch(storageServiceProvider);
      return AuthController(authService, storageService);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthController(this._authService, this._storageService)
    : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    logger.d('⚙️ Auth controller: login initiated');
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailPassword(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.w('⚠️ Auth controller: login failed');
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> signup(String email, String password, String fullName) async {
    logger.d('⚙️ Auth controller: signup initiated');
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signUpWithEmailPassword(
        email,
        password,
        fullName: fullName,
      );
      state = const AsyncValue.data(null);
      return response.session == null && response.user != null;
    } catch (e, st) {
      logger.w('⚠️ Auth controller: signup failed');
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? phone,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    logger.d('⚙️ Auth controller: updateProfile initiated');
    state = const AsyncValue.loading();
    try {
      String? finalAvatarUrl = avatarUrl;
      final user = _authService.currentUser;

      if (avatarFile != null && user != null) {
        final uploadedUrl = await _storageService.uploadAvatar(
          userId: user.id,
          file: avatarFile,
        );
        if (uploadedUrl != null) {
          finalAvatarUrl = uploadedUrl;
        }
      }

      await _authService.updateUserProfile(
        fullName: fullName,
        username: username,
        phone: phone,
        avatarUrl: finalAvatarUrl,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.w('⚠️ Auth controller: updateProfile failed');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    logger.d('⚙️ Auth controller: logout initiated');
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.w('⚠️ Auth controller: logout failed');
      state = AsyncValue.error(e, st);
    }
  }
}
