import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/decryption/decryption_page.dart';
import '../../features/encryption/encryption_page.dart';
import '../../features/home/home_page.dart';
import '../../features/result/result_page.dart';
import '../../features/result/result_page_args.dart';
import '../../features/settings/settings_page.dart';
import '../settings/app_settings.dart';

GoRouter createAppRouter(AppSettings settings) {
  return GoRouter(
    initialLocation: HomePage.routePath,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: settings,
    routes: [
      GoRoute(
        path: HomePage.routePath,
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: EncryptionPage.routeSegment,
            name: EncryptionPage.routeName,
            builder: (context, state) => const EncryptionPage(),
          ),
          GoRoute(
            path: DecryptionPage.routeSegment,
            name: DecryptionPage.routeName,
            builder: (context, state) => const DecryptionPage(),
          ),
          GoRoute(
            path: ResultPage.routeSegment,
            name: ResultPage.routeName,
            builder: (context, state) {
              final args = state.extra is ResultPageArgs
                  ? state.extra as ResultPageArgs
                  : ResultPageArgs.empty();
              return ResultPage(args: args);
            },
          ),
          GoRoute(
            path: SettingsPage.routeSegment,
            name: SettingsPage.routeName,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
