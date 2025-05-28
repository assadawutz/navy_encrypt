import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;
  final String backgroundAssetPath;
  final BoxFit fit;

  const BackgroundScaffold(
      {Key key, this.child, this.backgroundAssetPath, this.fit = BoxFit.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: backgroundAssetPath == null
            ? null
            : BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundAssetPath),
                  fit: fit,
                ),
              ),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
