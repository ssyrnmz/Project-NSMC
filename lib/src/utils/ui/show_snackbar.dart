import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String text,
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      showCloseIcon: true,
      backgroundColor: color ?? Colors.grey[850],
    ),
  );
}

void showDismissableSnackBar({
  required BuildContext context,
  required String text,
  Color? color,
  Duration? timeDuration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      duration: timeDuration ?? Duration(minutes: 1),
      action: SnackBarAction(
        label: 'CLOSE',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      backgroundColor: color ?? Colors.grey[850],
    ),
  );
}
