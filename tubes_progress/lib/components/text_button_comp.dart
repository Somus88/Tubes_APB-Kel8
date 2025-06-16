import 'package:flutter/material.dart';

class TextButtonComp extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double fontSize;

  const TextButtonComp({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color, // Warna teks
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      child: Text(text),
    );
  }
}
