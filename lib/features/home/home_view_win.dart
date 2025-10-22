import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/responsive_section.dart';
import '../decryption/decryption_page.dart';
import '../encryption/encryption_page.dart';
import '../result/result_page.dart';
import '../settings/settings_page.dart';

class HomeViewWin extends StatelessWidget {
  const HomeViewWin({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Command centre',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      _DesktopActionCard(
                        title: 'New encryption',
                        subtitle: 'AES-256 • PBKDF2 • Integrity hash',
                        icon: Icons.lock,
                        onTap: () => context.go('/${EncryptionPage.routeSegment}'),
                      ),
                      _DesktopActionCard(
                        title: 'New decryption',
                        subtitle: 'Paste encrypted payload to recover data',
                        icon: Icons.lock_open,
                        onTap: () => context.go('/${DecryptionPage.routeSegment}'),
                      ),
                      _DesktopActionCard(
                        title: 'Latest results',
                        subtitle: 'Audit what you processed recently',
                        icon: Icons.history,
                        onTap: () => context.go('/${ResultPage.routeSegment}'),
                      ),
                      _DesktopActionCard(
                        title: 'Preferences',
                        subtitle: 'Theme, accessibility and update channels',
                        icon: Icons.settings,
                        onTap: () => context.go('/${SettingsPage.routeSegment}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: ResponsiveSection(isDesktopEmphasis: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopActionCard extends StatelessWidget {
  const _DesktopActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
