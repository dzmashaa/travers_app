import 'package:flutter/material.dart';

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final TextStyle? textStyle;

  const IconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 18,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                textStyle ??
                const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
