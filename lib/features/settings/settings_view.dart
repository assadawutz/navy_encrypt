import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Preferences', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_android)),
            ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.wb_sunny_outlined)),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.nightlight_round)),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (value) {
            settings.updateThemeMode(value.first);
          },
        ),
        const SizedBox(height: 24),
        Text('Language', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<Locale?>(
          value: settings.locale,
          decoration: const InputDecoration(labelText: 'App language'),
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
          onChanged: (value) => settings.updateThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          title: const Text('Force dark mode'),
          subtitle: const Text('Overrides system preference with a high-contrast palette'),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text('3.3.8 baseline • modernised ${DateTime.now().year}'),
          ),
        ),
      ],
    );
  }
}
