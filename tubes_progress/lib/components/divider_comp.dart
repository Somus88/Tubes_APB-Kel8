import 'package:flutter/material.dart';

class DividerComp extends StatelessWidget {
  final String? text;
  final Color color;
  final double thickness;
  final double padding;

  const DividerComp({
    Key? key,
    this.text,
    this.color = Colors.white,
    this.thickness = 1,
    this.padding = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: thickness)),
        if (text != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Text(
              text!,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Divider(color: color, thickness: thickness)),
        ],
      ],
    );
  }
}
