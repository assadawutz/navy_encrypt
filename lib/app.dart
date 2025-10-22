import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';

class NavyEncryptApp extends StatelessWidget {
  const NavyEncryptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: Consumer<AppSettings>(
        builder: (context, settings, _) {
          final router = createAppRouter(settings);
          return MaterialApp.router(
            title: 'Navy Encrypt',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            themeMode: settings.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            builder: (context, child) {
              return DefaultTextStyle(
                style: GoogleFonts.prompt(
                  textStyle: Theme.of(context).textTheme.bodyMedium!,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
