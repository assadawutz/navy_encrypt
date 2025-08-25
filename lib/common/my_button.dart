import 'dart:io';

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Widget rightIcon;
  final double width;
  final Function onClick;
  final bool isOutlinedButton;
  final Color backgroundColor;
  final Color textColor;

  MyButton({
    Key key,
    this.label,
    this.rightIcon,
    this.width = double.infinity,
    this.onClick,
    this.isOutlinedButton = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  final outlinedButton = ({onPressed, child, style}) => OutlinedButton(
        onPressed: onPressed,
        child: child,
        style: style,
      );
  final elevatedButton = ({onPressed, child, style}) => ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: style,
      );

  @override
  Widget build(BuildContext context) {
    final button = isOutlinedButton ? outlinedButton : elevatedButton;

    return button(
      onPressed: onClick,
      child: Padding(
        padding: EdgeInsets.all(Platform.isWindows ? 8.0 : 0.0),
        child: Stack(
          children: [
            SizedBox(
              width: width,
              child: Padding(
                padding: EdgeInsets.only(right: rightIcon == null ? 0.0 : 16.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22.0),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: rightIcon,
                ),
              ),
            ),
          ],
        ),
      ),
      style: isOutlinedButton
          ? OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF717171),
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              side: BorderSide(width: 2, color: Color(0xFF838383)),
              backgroundColor: Colors.white,
            )
          : ElevatedButton.styleFrom(
              foregroundColor: textColor,
              backgroundColor: backgroundColor,
              //change text color of button
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 12.0,
              shadowColor: Color(0x80999999),
            ), /*ButtonStyle(
              backgroundColor: backgroundColor,
              padding:
                  MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10.0)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  //side: BorderSide(color: Colors.red),
                ),
              ),
            ),*/
    );
  }
}
