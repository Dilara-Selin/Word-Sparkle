import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onpressed;
  final String textButton;
  final Color textColor;
  final Color buttonColor;

  const CustomButton(
      {super.key,
      required this.onpressed,
      required this.textButton,
      required this.textColor,
      required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onpressed,
      child: Container(),
    );
  }
}
