import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final String text;

  const IconTextWidget({super.key,
    required this.onTap,
    required this.icon,
    this.iconColor,
    this.textStyle,
     required this.text
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: iconColor ?? Theme.of(context).disabledColor, size: 16),
        SizedBox(width: 5),

        Text(text, style: textStyle ?? TextStyle(
            color: Theme.of(context).disabledColor,
          fontSize: 12,
          fontWeight: FontWeight.bold
        ), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
