import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/settings/app_settings.dart';
import '../../shared/widgets/adaptive_page_scaffold.dart';
import 'settings_view.dart';
import 'settings_view_win.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = 'settings';
  static const routeSegment = 'settings';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    final body = isWindows
        ? SettingsViewWin(settings: settings)
        : SettingsView(settings: settings);

    return AdaptivePageScaffold(
      selectedRoute: '/${SettingsPage.routeSegment}',
      pageTitle: 'Settings',
      body: body,
    );
  }
}
