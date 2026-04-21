import 'package:flutter/material.dart';

class InfoCardSection {
  final String title;
  final Widget child;

  const InfoCardSection({
    required this.title,
    required this.child,
  });
}

/// Generic, composable information card with named sections.
class InfoCard extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final List<InfoCardSection> sections;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final BorderSide? borderSide;

  const InfoCard({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    required this.sections,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: borderRadius,
        border: borderSide == null ? null : Border.fromBorderSide(borderSide!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || leading != null || trailing != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 8),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                else
                  const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            if (sections.isNotEmpty) const SizedBox(height: 12),
          ],
          for (var i = 0; i < sections.length; i++) ...[
            Text(
              sections[i].title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            sections[i].child,
            if (i != sections.length - 1) ...[
              const SizedBox(height: 12),
              Divider(color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}
