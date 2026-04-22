import 'package:flutter/material.dart';

class IconedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final Color? backgroundColor;
  final Size size;
  final Size minimumSize;
  final Size maximumSize;
  final Color? textColor;
  final Color? iconColor;
  final IconData icon;
  const IconedButton(
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
    final hasText = text != null && text!.trim().isNotEmpty;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: hasText
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : const EdgeInsets.all(8),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        fixedSize: size,
        minimumSize: minimumSize,
        maximumSize: maximumSize,
      ),
      child: hasText
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    text!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor ?? Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: iconColor ?? Colors.white),
              ],
            )
          : Icon(icon, color: iconColor ?? Colors.white),
    );
  }
}
