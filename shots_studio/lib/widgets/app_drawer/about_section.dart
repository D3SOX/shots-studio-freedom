import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/analytics/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/build_source.dart';

class AboutSection extends StatelessWidget {
  final String appVersion;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AboutSection({
    super.key,
    required this.appVersion,
    this.onTap,
    this.onLongPress,
  });

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  // Removed manual update checks and sponsorship dialog for privacy-focused fork

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Divider(color: theme.colorScheme.outline),
        ListTile(
          leading: Icon(Icons.code, color: theme.colorScheme.primary),
          title: Text(
            AppLocalizations.of(context)?.sourceCode ?? 'Source Code',
            style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
          subtitle: Text(
            'Contribute on GitHub',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          onTap: () {
            // Log analytics for source code access
            AnalyticsService().logFeatureUsed('source_code_accessed');
            AnalyticsService().logFeatureUsed('github_link_clicked');

            Navigator.pop(context);
            _launchURL('https://github.com/D3SOX/shots-studio-freedom');
            // _launchURL('https://gitlab.com/mohdansah10/shots-studio');
          },
        ),
        Divider(color: theme.colorScheme.outline),
        ListTile(
          leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
          title: Text(
            AppLocalizations.of(context)?.about ?? 'About',
            style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
          subtitle: Text(
            'Version $appVersion (${BuildSource.current.displayName})',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          onTap: () {
            // Log analytics for about section interactions
            AnalyticsService().logFeatureUsed('about_section_clicked');

            if (onTap != null) {
              onTap!();
            }
            // Don't close drawer when tapping About to allow for multiple taps
          },
          onLongPress: () {
            if (onLongPress != null) {
              onLongPress!();
            }
          },
        ),
      ],
    );
  }
}
