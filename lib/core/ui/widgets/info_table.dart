import 'package:flutter/material.dart';

class InfoTableColumn<T> {
  final String heading;
  final int flex;
  final TextAlign headingTextAlign;
  final TextAlign dataTextAlign;
  final String Function(T row)? textValue;
  final Widget Function(BuildContext context, T row)? cellBuilder;

  const InfoTableColumn({
    required this.heading,
    this.flex = 1,
    this.headingTextAlign = TextAlign.left,
    this.dataTextAlign = TextAlign.left,
    this.textValue,
    this.cellBuilder,
  }) : assert(
          textValue != null || cellBuilder != null,
          'Provide either textValue or cellBuilder for each column.',
        );
}

/// Generic vertical-scroll table.
///
/// The caller must provide both [width] and [height] so the layout remains
/// predictable and does not require horizontal scrolling.
class InfoTable<T> extends StatefulWidget {
  final List<InfoTableColumn<T>> columns;
  final List<T> rows;
  final double width;
  final double height;
  final TextStyle? headingTextStyle;
  final TextStyle? dataTextStyle;
  final String emptyText;
  final double rowMinHeight;
  final EdgeInsetsGeometry cellPadding;
  final Color? borderColor;
  final Color? headingBackgroundColor;
  final double scrollbarThickness;
  final double scrollbarCrossAxisMargin;
  final double rightContentPadding;

  const InfoTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.width,
    required this.height,
    this.headingTextStyle,
    this.dataTextStyle,
    this.emptyText = 'No rows found',
    this.rowMinHeight = 44,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    this.borderColor,
    this.headingBackgroundColor,
    this.scrollbarThickness = 10,
    this.scrollbarCrossAxisMargin = 4,
    this.rightContentPadding = 16,
  }) : assert(columns.length > 0, 'Provide at least one column.');

  @override
  State<InfoTable<T>> createState() => _InfoTableState<T>();
}

class _InfoTableState<T> extends State<InfoTable<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor =
        widget.borderColor ?? Theme.of(context).colorScheme.outlineVariant;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: resolvedBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              Container(
                color: widget.headingBackgroundColor ??
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(120),
                child: _buildHeader(context, resolvedBorderColor),
              ),
              Expanded(
                child: widget.rows.isEmpty
                    ? _buildEmptyState(context)
                    : RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: widget.scrollbarThickness,
                        radius: const Radius.circular(8),
                        interactive: true,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        crossAxisMargin: widget.scrollbarCrossAxisMargin,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: widget.rightContentPadding),
                            child: Column(
                              children: [
                                for (var i = 0; i < widget.rows.length; i++)
                                  _buildDataRow(
                                    context,
                                    widget.rows[i],
                                    resolvedBorderColor,
                                    showBottomBorder:
                                        i != widget.rows.length - 1,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color border) {
    return Container(
      constraints: BoxConstraints(minHeight: widget.rowMinHeight),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          for (final column in widget.columns)
            Expanded(
              flex: column.flex,
              child: Padding(
                padding: widget.cellPadding,
                child: Text(
                  column.heading,
                  textAlign: column.headingTextAlign,
                  style: widget.headingTextStyle ??
                      Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    T row,
    Color border, {
    required bool showBottomBorder,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: widget.rowMinHeight),
      decoration: BoxDecoration(
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: border))
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          for (final column in widget.columns)
            Expanded(
              flex: column.flex,
              child: Padding(
                padding: widget.cellPadding,
                child: column.cellBuilder != null
                    ? column.cellBuilder!(context, row)
                    : Text(
                        column.textValue!(row),
                        textAlign: column.dataTextAlign,
                        style: widget.dataTextStyle ??
                            Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          widget.emptyText,
          style: widget.dataTextStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
