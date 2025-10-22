import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/decryption/decryption_page.dart';
import '../../features/encryption/encryption_page.dart';
import '../../features/home/home_page.dart';
import '../../features/result/result_page.dart';
import '../../features/settings/settings_page.dart';

class AdaptivePageScaffold extends StatelessWidget {
  const AdaptivePageScaffold({
    super.key,
    required this.body,
    required this.selectedRoute,
    this.floatingActionButton,
    this.pageTitle,
  });

  final Widget body;
  final String selectedRoute;
  final Widget? floatingActionButton;
  final String? pageTitle;

  @override
  Widget build(BuildContext context) {
    if (_isDesktop(context)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle ?? _titleForRoute(selectedRoute)),
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _indexForRoute(selectedRoute),
              onDestinationSelected: (index) => _onDestinationSelected(
                context,
                index,
              ),
              labelType: NavigationRailLabelType.all,
              destinations: _destinations
                  .map(
                    (entry) => NavigationRailDestination(
                      icon: Icon(entry.icon),
                      label: Text(entry.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle ?? _titleForRoute(selectedRoute)),
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexForRoute(selectedRoute),
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        destinations: _destinations
            .map(
              (entry) => NavigationDestination(
                icon: Icon(entry.icon),
                label: entry.label,
              ),
            )
            .toList(),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  bool _isDesktop(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.macOS;
  }

  int _indexForRoute(String route) {
    return _destinations.indexWhere((entry) => entry.path == route).clamp(0, 4);
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final target = _destinations[index];
    if (selectedRoute == target.path) {
      return;
    }
    context.go(target.path);
  }

  String _titleForRoute(String route) {
    return _destinations
        .firstWhere((entry) => entry.path == route, orElse: () => _destinations.first)
        .label;
  }
}

class _Destination {
  const _Destination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

const List<_Destination> _destinations = [
  _Destination(HomePage.routePath, 'Home', Icons.home_filled),
  _Destination('/${EncryptionPage.routeSegment}', 'Encrypt', Icons.lock_outline),
  _Destination('/${DecryptionPage.routeSegment}', 'Decrypt', Icons.lock_open_outlined),
  _Destination('/${ResultPage.routeSegment}', 'Results', Icons.receipt_long),
  _Destination('/${SettingsPage.routeSegment}', 'Settings', Icons.settings_outlined),
];
