import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final Color? backgroundColor;
  final Size size;
  final Size minimumSize;
  final Size maximumSize;
  final Color? textColor;
  final Color? iconColor;
  final IconData icon;
  const AddButton(
      {super.key,
      required this.onPressed,
      this.text,
      this.backgroundColor,
      required this.size,
      this.minimumSize = const Size(150, 50),
      this.maximumSize = const Size(500, 200),
      this.textColor,
      this.iconColor,
      required this.icon});

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
        minimumSize: minimumSize,
        maximumSize: maximumSize,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (text != null) ...[
            Text(text!, style: TextStyle(color: textColor ?? Colors.white)),
          ],
          Icon(icon, color: iconColor ?? Colors.white),
        ],
      ),
    );
  }
}
