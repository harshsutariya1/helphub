import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Extension mapping Supabase User to UserProfile
extension SupabaseUserMapper on supabase.User {
  UserProfile toUserProfile() {
    return UserProfile(
      id: id,
      email: email,
      fullName:
          userMetadata?['name'] as String? ??
          userMetadata?['full_name'] as String?,
      avatarUrl: userMetadata?['avatar_url'] as String?,
      // Note: createdAt can be populated if needed, or fetched from DB
    );
  }
}
