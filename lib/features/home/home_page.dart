import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/adaptive_page_scaffold.dart';
import '../encryption/encryption_page.dart';
import 'home_view.dart';
import 'home_view_win.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (Theme.of(context).platform == TargetPlatform.windows) {
      body = const HomeViewWin();
    } else {
      body = const HomeView();
    }

    return AdaptivePageScaffold(
      selectedRoute: routePath,
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/${EncryptionPage.routeSegment}'),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }
}
