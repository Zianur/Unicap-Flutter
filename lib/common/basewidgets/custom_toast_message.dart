import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info, fav }

class CustomToast{
  static void showToast(String message, ToastType type, ToastGravity? gravity) {
    Color backgroundColor;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        break;
      case ToastType.error:
        backgroundColor = Colors.red;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue;
        break;
      case ToastType.fav:
        backgroundColor = Colors.pink;
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

