import 'package:flutter/material.dart';

// Screen to wait before the app checks if user is still logged in
class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Color(0xFF629E5C))),
    );
  }
}
