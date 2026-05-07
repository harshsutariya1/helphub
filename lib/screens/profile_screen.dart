import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helphub/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              Text('Email: ${user.email}'),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
