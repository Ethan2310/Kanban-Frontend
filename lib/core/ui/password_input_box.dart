import 'package:flutter/material.dart';
import 'package:kanban_frontend/core/ui/app_text_box.dart';

enum PasswordInputState { normal, invalid, incorrect }

class PasswordInputBox extends StatefulWidget {
  const PasswordInputBox({
    super.key,
    this.controller,
    this.width,
    this.height,
    this.enabled = true,
    this.validator,
    this.state = PasswordInputState.normal,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final double? width;
  final double? height;
  final bool enabled;
  final String? Function(String?)? validator;
  final PasswordInputState state;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordInputBox> createState() => _PasswordInputBoxState();
}

class _PasswordInputBoxState extends State<PasswordInputBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = switch (widget.state) {
      PasswordInputState.incorrect => Colors.red,
      PasswordInputState.invalid => Colors.amber,
      PasswordInputState.normal => colorScheme.outline,
    };

    return AppTextBox(
      controller: widget.controller,
      width: widget.width,
      height: widget.height,
      enabled: widget.enabled,
      obscureText: _obscureText,
      validator: widget.validator,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: widget.enabled
              ? () => setState(() => _obscureText = !_obscureText)
              : null,
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
    );
  }
}