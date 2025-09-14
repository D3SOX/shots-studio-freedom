import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
// http removed for offline build
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'update_checker_service.dart';

/// Progress callback type for download progress
typedef ProgressCallback = void Function(double progress, String status);

/// Service for downloading and installing app updates
class UpdateInstallerService {
  static const MethodChannel _channel = MethodChannel('update_installer');

  /// Downloads and installs an update
  static Future<bool> downloadAndInstall({
    required UpdateInfo updateInfo,
    ProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(0.0, 'Checking permissions...');

      // Check and request install permission
      if (!await _checkInstallPermission()) {
        onProgress?.call(0.0, 'Requesting install permission...');
        if (!await _requestInstallPermission()) {
          throw Exception('Install permission denied');
        }
      }

      onProgress?.call(0.1, 'In-app update downloads disabled');
      throw Exception('In-app update downloads are disabled in this build');
    } catch (e) {
      onProgress?.call(0.0, 'Error: $e');
      rethrow;
    }
  }

  /// Checks if the app has permission to install unknown apps
  static Future<bool> _checkInstallPermission() async {
    if (Platform.isAndroid) {
      try {
        final bool? result = await _channel.invokeMethod(
          'canRequestPackageInstalls',
        );
        return result ?? false;
      } catch (e) {
        // Fallback to permission_handler for older Android versions
        final status = await Permission.requestInstallPackages.status;
        return status.isGranted;
      }
    }
    return false;
  }

  /// Requests permission to install unknown apps
  static Future<bool> _requestInstallPermission() async {
    if (Platform.isAndroid) {
      try {
        final bool? result = await _channel.invokeMethod(
          'requestInstallPermission',
        );
        return result ?? false;
      } catch (e) {
        // Fallback to permission_handler
        final status = await Permission.requestInstallPackages.request();
        return status.isGranted;
      }
    }
    return false;
  }

  /// Gets the APK download URL from the GitHub release
  static Future<String?> _getApkDownloadUrl(UpdateInfo updateInfo) async {
    return null;
  }

  /// Downloads the APK file with progress tracking
  static Future<File> _downloadApk(
    String url,
    String version,
    void Function(double progress)? onProgress,
  ) async {
    throw Exception('Network download disabled');

    // unreachable
    // ignore: dead_code
    return File('');
  }

  /// Installs the APK file
  static Future<void> _installApk(String apkPath) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('installApk', {'apkPath': apkPath});
      } catch (e) {
        throw Exception('Failed to install APK: $e');
      }
    } else {
      throw Exception('APK installation is only supported on Android');
    }
  }

  /// Checks if the device supports automatic updates
  static Future<bool> isUpdateSupportedOnPlatform() async {
    return Platform.isAndroid;
  }

  /// Gets estimated download size for the update
  static Future<int?> getUpdateSize(UpdateInfo updateInfo) async {
    try {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Formats file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
