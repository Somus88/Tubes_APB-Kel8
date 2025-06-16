import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextLinkComp extends StatelessWidget {
  final String normalText;
  final String linkText;
  final VoidCallback onTap;
  final Color normalTextColor;
  final Color linkTextColor;
  final double fontSize;

  const TextLinkComp({
    Key? key,
    required this.normalText,
    required this.linkText,
    required this.onTap,
    this.normalTextColor = Colors.white,
    this.linkTextColor = Colors.black,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: normalText,
        style: TextStyle(fontSize: fontSize, color: normalTextColor),
        children: [
          TextSpan(
            text: " $linkText",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: linkTextColor,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
