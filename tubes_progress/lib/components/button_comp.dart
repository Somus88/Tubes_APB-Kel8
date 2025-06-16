import 'package:flutter/material.dart';

class ButtonComp extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback onPressed;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final double padding;

  const ButtonComp({
    Key? key,
    this.text,
    this.icon,
    required this.onPressed,
    this.textColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.fontSize = 16,
    this.padding = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: padding * 2,
          vertical: padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: textColor),
        ),
        elevation: 2, // Sedikit shadow
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            if (text != null)
              const SizedBox(width: 8), // Spasi antara icon & teks
          ],
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }
}
