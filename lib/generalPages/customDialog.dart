import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CSBar extends StatelessWidget {
   String text;
  Color color;
   IconData _icon;
  @override
  Widget build(BuildContext context) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red[900],
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Icon( _icon, color: color, size: 14),
        SizedBox(width: 15),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400))),
      ]),
      duration: const Duration(seconds: 8),
    );
  }
}
