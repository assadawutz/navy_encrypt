import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';

class SettingsViewWin extends StatelessWidget {
  const SettingsViewWin({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: settings.updateThemeMode,
                  title: const Text('Follow Windows theme'),
                  subtitle: const Text('Syncs automatically with Windows accent colour'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: settings.updateThemeMode,
                  title: const Text('Light'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: settings.updateThemeMode,
                  title: const Text('Dark'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Regional settings', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                DropdownButtonFormField<Locale?>(
                  value: settings.locale,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('System default')),
                    DropdownMenuItem(value: Locale('en'), child: Text('English')),
                    DropdownMenuItem(value: Locale('th'), child: Text('ไทย (Thai)')),
                  ],
                  onChanged: settings.updateLocale,
                ),
                const SizedBox(height: 24),
                SwitchListTile.adaptive(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (value) => settings.updateThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  ),
                  title: const Text('Force dark mode'),
                  subtitle: const Text('Helpful for high-contrast operations rooms'),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.security_update_good),
                    title: const Text('Security posture'),
                    subtitle: const Text('AES-256 • PBKDF2 • Integrity MAC'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
