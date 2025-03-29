import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ColorAnimatedText extends StatelessWidget {
  final String text;
  const ColorAnimatedText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold
    ), textAlign: TextAlign.center)
        .animate(onPlay: (controller) => controller.repeat()) // Infinite loop
        .shimmer(
      duration: 3.seconds, // Smooth shimmer effect
      colors: [Theme.of(context).primaryColor, Colors.blue, Colors.deepPurpleAccent],
    );
  }
}
