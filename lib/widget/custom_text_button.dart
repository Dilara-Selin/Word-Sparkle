import 'package:flutter/material.dart';
import 'package:flutter_dersleri/utils/custom_colors.dart';

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
    return Center(
        child: TextButton(
            onPressed: onPressed,
            child: Text(buttonText, style: TextStyle(color: textColor))));
  }
}
