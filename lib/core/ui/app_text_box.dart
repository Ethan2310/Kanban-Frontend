import 'package:flutter/material.dart';

class AppTextBox extends StatelessWidget {
  const AppTextBox({
    super.key,
    this.controller,
    this.width,
    this.height,
    this.enabled = true,
    this.keyboardType,
    this.obscureText = false,
    this.decoration,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final double? width;
  final double? height;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool obscureText;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: decoration,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );

    if (height != null) {
      textField = SizedBox(height: height, child: textField);
    }

    if (width != null) {
      textField = SizedBox(width: width, child: textField);
    }

    return textField;
  }
}