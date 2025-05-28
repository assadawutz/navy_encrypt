import 'dart:io';

import 'package:flutter/material.dart';
import 'package:navy_encrypt/etc/utils.dart';

class MyContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;

  MyContainer({this.child, this.margin, this.padding});

  @override
  Widget build(BuildContext context) {
    final width = screenWidth(context);
    //final height = screenHeight(context);

    return Platform.isWindows
        ? Container(
            margin: margin ??
                EdgeInsets.fromLTRB(
                  width * (width > 1000 ? 0.2 : 0.1),
                  32.0,
                  width * (width > 1000 ? 0.2 : 0.1),
                  64.0,
                ),
            padding: padding ?? EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              border: Border.all(width: 1.0, color: Color(0xFFC6C6C6)),
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: child,
          )
        : Container(
            padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
            child: child,
          );
  }
}
