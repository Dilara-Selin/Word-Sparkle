import 'package:flutter/material.dart';
import 'package:last_project/screens/customcolors.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color textColor;

  const CustomTextButton(
      {super.key,
      required this.onPressed,
      required this.buttonText,
      this.textColor = CustomColors.textButtonColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(buttonText, style: TextStyle(color: textColor)));
  }
}
