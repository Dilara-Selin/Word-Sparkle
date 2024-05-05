import 'package:flutter/material.dart';
import 'package:word_sparkle/customs/customcolors.dart';

class CustomElevatedButton extends StatelessWidget {
  final Color buttoncolor;
  final VoidCallback onpressed;
  final String content;

  const CustomElevatedButton(
      {super.key,
      required this.buttoncolor,
      required this.onpressed,
      required this.content,
      });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(230, 100),
        backgroundColor: CustomColors.buttoncolor,
      ),

      child:Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
