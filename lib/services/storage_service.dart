import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helphub/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helphub/utils/logger.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return StorageService(supabase);
});

class StorageService {
  final SupabaseClient _supabase;

  StorageService(this._supabase);

  Future<String?> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final pathParts = file.path.split('.');
      final rawExtension = pathParts.length > 1 ? pathParts.last.toLowerCase() : '';

      // Normalize and validate extension
      String fileExtension;
      if (rawExtension == 'jpg' || rawExtension == 'jpeg') {
        fileExtension = 'jpeg';
      } else if (rawExtension == 'png') {
        fileExtension = 'png';
      } else if (rawExtension == 'gif') {
        fileExtension = 'gif';
      } else if (rawExtension == 'webp') {
        fileExtension = 'webp';
      } else {
        // Default to png for unknown or missing extensions
        logger.w('Unknown or missing file extension: $rawExtension, defaulting to png');
        fileExtension = 'png';
      }

      final fileName = 'avatar_$userId.$fileExtension';
      final path = '$userId/$fileName';

      logger.i('📤 Uploading avatar to Supabase Storage: $path');

      // Upload or replace the existing file.
      await _supabase.storage
          .from('avatars')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final url = _supabase.storage.from('avatars').getPublicUrl(path);
      // Append a timestamp to avoid local caching issues in the UI
      final publicUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

      logger.i('✅ Avatar uploaded successfully');
      return publicUrl;
    } catch (e, st) {
      logger.e('🛑 Failed to upload avatar', error: e, stackTrace: st);
      return null;
    }
  }
}
