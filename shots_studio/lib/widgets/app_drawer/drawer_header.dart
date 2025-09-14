import 'package:flutter/material.dart';

class AppDrawerHeader extends StatefulWidget {
  const AppDrawerHeader({super.key});

  @override
  State<AppDrawerHeader> createState() => _AppDrawerHeaderState();
}

class _AppDrawerHeaderState extends State<AppDrawerHeader> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DrawerHeader(
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon with theme coloring
              Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onPrimaryContainer,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icon/ic_launcher_monochrome.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                'Shots Studio',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Screenshot Manager',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),

          // Support button removed for privacy-focused fork
        ],
      ),
    );
  }
}
