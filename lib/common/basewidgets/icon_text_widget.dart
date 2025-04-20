import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final String? text;

  const IconTextWidget({super.key,
    required this.onTap,
    required this.icon,
    this.iconColor,
    this.textStyle,
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      highlightColor: Colors.deepPurpleAccent,
      splashColor: Colors.deepPurpleAccent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(children: [
          Icon(icon, color: iconColor ?? Theme.of(context).disabledColor, size: 20),
          SizedBox(width: 5),

          Text(text ?? '', style: textStyle ?? TextStyle(
              color: Theme.of(context).disabledColor,
            fontSize: 14,
            fontWeight: FontWeight.bold
          ), overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}
