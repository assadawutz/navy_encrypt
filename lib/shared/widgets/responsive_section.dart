import 'package:flutter/material.dart';

class ResponsiveSection extends StatelessWidget {
  const ResponsiveSection({super.key, this.isDesktopEmphasis = false});

  final bool isDesktopEmphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = [
      _Feature('Cross-platform', 'Works seamlessly on iOS, Android, Windows and the web'),
      _Feature('Zero knowledge', 'AES-256 with PBKDF2 keeps your secrets safe on-device'),
      _Feature('Accessible', 'Keyboard shortcuts, large fonts and high contrast ready'),
      _Feature('Auditable', 'Detailed logs help teams validate the encryption workflow'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 2
            : constraints.maxWidth > 500
                ? 2
                : 1;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktopEmphasis ? 2.8 : 2.2,
          children: features
              .map(
                (feature) => Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(feature.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(feature.description),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Feature {
  const _Feature(this.title, this.description);

  final String title;
  final String description;
}
