import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final Color? backgroundColor;
  final Size size;
  final Color? textColor;
  final Color? iconColor;
  const AddButton(
      {super.key,
      required this.onPressed,
      this.text,
      this.backgroundColor,
      required this.size,
      this.textColor,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.all(16),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        fixedSize: size,
        minimumSize: const Size(150, 50),
        maximumSize: const Size(500, 200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (text != null) ...[
            Text(text!, style: TextStyle(color: textColor ?? Colors.white)),
          ],
          Icon(Icons.add, color: iconColor ?? Colors.white),
        ],
      ),
    );
  }
}
