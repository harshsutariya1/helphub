import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';
import 'package:helphub/utils/logger.dart';

final updaterServiceProvider = Provider<UpdaterService>((ref) {
  return UpdaterService();
});

class UpdaterService {
  final _updater = ShorebirdUpdater();

  /// Checks for upgrades and prompts the user to restart if a new patch is available
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      logger.i('Checking for Shorebird updates...');
      // 1. Check if a new patch is available
      final status = await _updater.checkForUpdate();

      if (status != UpdateStatus.outdated) {
        logger.i('No new patches found or app is already up to date.');
        return;
      }

      logger.i('New patch found! Downloading...');

      // 2. Download the patch
      await _updater.update();

      logger.i('Patch downloaded successfully. Prompting user to restart.');

      if (!context.mounted) return;

      // 3. Prompt user to restart app to apply patch
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('New Update Available'),
            content: const Text(
              'A new update has been downloaded. Please restart the app to apply the changes and get the latest features.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Not Now'),
              ),
              FilledButton(
                onPressed: () {
                  // Restart the application
                  Restart.restartApp();
                },
                child: const Text('Restart App'),
              ),
            ],
          );
        },
      );
    } catch (e, st) {
      logger.e(
        'Failed to check/download Shorebird update',
        error: e,
        stackTrace: st,
      );
    }
  }
}
