import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_config.dart';

class UpdateService {
  // Check for app updates
  static Future<bool> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      // Call your update API
      final response = await http.get(
        Uri.parse('${AppConfig.updateCheckUrl}?version=$currentVersion&build=$buildNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['latestVersion'];
        final latestBuild = data['latestBuild'];
        final downloadUrl = data['downloadUrl'];
        final isUpdateAvailable = data['updateAvailable'] ?? false;

        if (isUpdateAvailable) {
          // Compare versions
          final currentVersionParts = currentVersion.split('.');
          final latestVersionParts = latestVersion.split('.');

          bool needsUpdate = false;
          for (int i = 0; i < latestVersionParts.length; i++) {
            final current = int.tryParse(currentVersionParts[i]) ?? 0;
            final latest = int.tryParse(latestVersionParts[i]) ?? 0;
            if (latest > current) {
              needsUpdate = true;
              break;
            }
          }

          if (needsUpdate || int.parse(latestBuild) > int.parse(buildNumber)) {
            return true; // Update available
          }
        }
      }
      return false;
    } catch (e) {
      // If update check fails, don't block the app
      return false;
    }
  }

  // Download APK update
  static Future<void> downloadUpdate(String downloadUrl) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('Failed to download update: $e');
    }
  }

  // Show update dialog (call from UI)
  static Future<void> showUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    required String downloadUrl,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          'A new version ($latestVersion) is available. Please update to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await downloadUpdate(downloadUrl);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}

