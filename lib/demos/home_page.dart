import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff31274F),
      body: Center(
        child: Text(
          "Anasayfa",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
