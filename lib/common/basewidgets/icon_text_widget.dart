import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final String? text;
  final bool isLoading;

  const IconTextWidget({super.key,
    required this.onTap,
    required this.icon,
    this.iconColor,
    this.textStyle,
    this.text,
    this.isLoading = false
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
        child: isLoading ?
        SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
            strokeWidth: 2,
          ),
        ) :
        Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: iconColor ?? Colors.black, size: 20),
          text != null ? SizedBox(width: 5) : const SizedBox(),

          Flexible(
            child: Text(text ?? '', style: textStyle ?? TextStyle(
                color: Theme.of(context).disabledColor,
              fontSize: 14,
              fontWeight: FontWeight.bold
            ), overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}
