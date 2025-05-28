import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyFormField extends StatelessWidget {
  final String label;
  final String subLabel;
  final String hint;
  final bool multiline;
  final Widget child;
  final Widget rightIcon;
  final Function onClickRightIcon;
  final TextEditingController controller;
  final bool enabled;
  final EdgeInsets padding;
  final List<TextInputFormatter> inputFormatters;
  final BoxShadow shadow;
  final bool obscureText;
  final int maxLength;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextAlign textAlign;
  final Function onEditingComplete;

  MyFormField(
      {this.label,
      this.subLabel,
      this.hint,
      this.multiline = false,
      this.child,
      this.rightIcon,
      this.onClickRightIcon,
      this.controller,
      this.enabled = true,
      this.padding,
      this.inputFormatters,
      this.shadow,
      this.obscureText = false,
      this.maxLength,
      this.autofocus = false,
      this.keyboardType,
      this.textAlign = TextAlign.start,
      this.onEditingComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 2.0),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
                ),
              )
            : SizedBox(height: 4.0),
        if (subLabel != null)
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              subLabel,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
            border: Border.all(color: Color(0xFFC3BFBF), width: 1.0),
            color: enabled ? Colors.white : Color(0xFFEFEFEF),
            boxShadow: [if (shadow != null) shadow],
          ),
          child: Row(
            children: [
              Expanded(
                child: child ??
                    TextFormField(
                      onEditingComplete: onEditingComplete,
                      textAlign: textAlign,
                      autofocus: autofocus,
                      inputFormatters: inputFormatters,
                      enabled: enabled,
                      obscureText: obscureText,
                      maxLength: maxLength,
                      controller: controller,
                      keyboardType: multiline
                          ? TextInputType.multiline
                          : (keyboardType ?? TextInputType.text),
                      maxLines: multiline ? null : 1,
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 20.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 20.0,
                        ),
                        counterText: '',
                      ),
                    ),
              ),
              if (rightIcon != null)
                GestureDetector(
                  onTap: onClickRightIcon,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    alignment: Alignment.center,
                    child: rightIcon ?? SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
