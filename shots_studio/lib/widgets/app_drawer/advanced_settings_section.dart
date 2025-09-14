import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shots_studio/services/corrupt_file_service.dart';
import 'package:shots_studio/models/screenshot_model.dart';
// import 'package:shots_studio/screens/debug_notifications_screen.dart'; // Uncomment for debugging
import '../../l10n/app_localizations.dart';

class AdvancedSettingsSection extends StatefulWidget {
  final int currentLimit;
  final Function(int) onLimitChanged;
  final int currentMaxParallel;
  final Function(int) onMaxParallelChanged;
  final bool? currentDevMode;
  final Function(bool)? onDevModeChanged;
  final bool? currentAnalyticsEnabled;
  final Function(bool)? onAnalyticsEnabledChanged;
  final bool? currentServerMessagesEnabled;
  final Function(bool)? onServerMessagesEnabledChanged;
  final bool? currentBetaTestingEnabled;
  final Function(bool)? onBetaTestingEnabledChanged;
  final VoidCallback? onResetAiProcessing;
  final List<Screenshot>? allScreenshots;
  final VoidCallback? onClearCorruptFiles;

  const AdvancedSettingsSection({
    super.key,
    required this.currentLimit,
    required this.onLimitChanged,
    required this.currentMaxParallel,
    required this.onMaxParallelChanged,
    this.currentDevMode,
    this.onDevModeChanged,
    this.currentAnalyticsEnabled,
    this.onAnalyticsEnabledChanged,
    this.currentServerMessagesEnabled,
    this.onServerMessagesEnabledChanged,
    this.currentBetaTestingEnabled,
    this.onBetaTestingEnabledChanged,
    this.onResetAiProcessing,
    this.allScreenshots,
    this.onClearCorruptFiles,
  });

  @override
  State<AdvancedSettingsSection> createState() =>
      _AdvancedSettingsSectionState();
}

class _AdvancedSettingsSectionState extends State<AdvancedSettingsSection> {
  // Analytics/Server/Beta toggles removed for privacy-focused fork

  static const String _maxParallelPrefKey = 'maxParallel';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AdvancedSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _saveMaxParallel(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxParallelPrefKey, value);
  }

  Future<void> _saveAnalyticsEnabled(bool value) async {
    // No-op: analytics disabled in privacy-focused fork
  }

  Future<void> _saveServerMessagesEnabled(bool value) async {
    // No-op: server messages disabled in privacy-focused fork
  }

  Future<void> _saveBetaTestingEnabled(bool value) async {
    // No-op: beta updates disabled in privacy-focused fork
  }

  /// Clear all corrupt files from the app using the CorruptFileService
  Future<void> _clearCorruptFiles() async {
    await CorruptFileService.clearCorruptFiles(
      context,
      widget.allScreenshots,
      widget.onClearCorruptFiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.colorScheme.outline),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)?.advancedSettings ??
                'Advanced Settings',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.sync_alt, color: theme.colorScheme.primary),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.maxParallelAI ??
                      'Max Parallel AI Processes',
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            'Max Parallel AI Processes',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          content: Text(
                            'Controls the maximum number of images sent in one AI request.\n\n'
                            '• Default: 4 (recommended for most users)\n'
                            '• Maximum: 8 (recommended for faster processing)\n'
                            '• Higher values require more internet bandwidth\n'
                            '• Gemma AI only supports 1 image regardless of this setting\n'
                            '• Adjust based on your internet connection speed',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Got it',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.currentMaxParallel}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controls parallel image processing. Higher values need more bandwidth. '
                'Default: 4. \nNote: Gemma only supports 1 image.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '1',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Expanded(
                    child: Slider(
                      value: widget.currentMaxParallel.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      label: widget.currentMaxParallel.toString(),
                      activeColor: theme.colorScheme.primary,
                      onChanged: (value) {
                        final intValue = value.round();
                        widget.onMaxParallelChanged(intValue);
                        _saveMaxParallel(intValue);

                        // Analytics removed
                      },
                    ),
                  ),
                  Text(
                    '8',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Analytics, server messages, and beta testing toggles removed
        // Reset AI Processing Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.onResetAiProcessing != null) {
                  widget.onResetAiProcessing!();
                }
              },
              icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
              label: Text(
                'Reset AI Processing',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
        // Clear Corrupt Files Button (only in debug mode)
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _clearCorruptFiles();
                },
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  AppLocalizations.of(context)?.clearCorruptFiles ??
                      'Clear Corrupt Files',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        // Debug Notifications Button (only in debug mode)
        // Temporarily commented out - uncomment for debugging notification issues
        // if (kDebugMode)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        //     child: SizedBox(
        //       width: double.infinity,
        //       child: OutlinedButton.icon(
        //         onPressed: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => const DebugNotificationsScreen(),
        //             ),
        //           );
        //         },
        //         icon: Icon(Icons.bug_report, color: theme.colorScheme.secondary),
        //         label: Text(
        //           'Debug Notifications',
        //           style: TextStyle(color: theme.colorScheme.secondary),
        //         ),
        //         style: OutlinedButton.styleFrom(
        //           side: BorderSide(color: theme.colorScheme.secondary),
        //           padding: const EdgeInsets.symmetric(vertical: 12.0),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(8.0),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
