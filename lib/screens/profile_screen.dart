import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helphub/controllers/auth_controller.dart';
import 'package:helphub/models/user_profile.dart'; // added import
import 'package:helphub/screens/edit_profile_screen.dart';
import 'package:helphub/widgets/profile_avatar.dart';
import 'package:helphub/widgets/profile_info_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _navigateToEditProfile(BuildContext context, UserProfile user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditProfileScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseUser = ref.watch(currentUserProvider);
    final user = supabaseUser?.toUserProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  ProfileAvatar(
                    imageUrl: user.avatarUrl,
                    initial: user.fullName ?? user.email,
                    radius: 56.0,
                    onEdit: () => _navigateToEditProfile(context, user),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName ?? 'No Name Provided',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ProfileInfoTile(
                    icon: Icons.person_outline,
                    title: 'Username',
                    value: user.username ?? 'Not set',
                    // Username is auto-generated and read-only
                  ),
                  ProfileInfoTile(
                    icon: Icons.badge_outlined,
                    title: 'Full Name',
                    value: user.fullName ?? 'Not set',
                    onEdit: () => _navigateToEditProfile(context, user),
                  ),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: user.phoneNumber ?? 'Not set',
                    onEdit: () => _navigateToEditProfile(context, user),
                  ),
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email ?? 'Not set',
                    // Usually email isn't editable via this basic UI
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).logout();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
