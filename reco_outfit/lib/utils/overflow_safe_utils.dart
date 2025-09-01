import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// Utility class for creating overflow-safe widgets and layouts
class OverflowSafeUtils {
  /// Creates an overflow-safe text widget with responsive sizing
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign textAlign = TextAlign.start,
    bool flexible = true,
  }) {
    final textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );

    return flexible ? Flexible(child: textWidget) : textWidget;
  }

  /// Creates an overflow-safe column with proper constraints
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    bool scrollable = false,
  }) {
    final column = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );

    return scrollable
        ? SingleChildScrollView(child: column)
        : column;
  }

  /// Creates an overflow-safe row with proper constraints
  static Widget safeRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    bool intrinsicHeight = false,
  }) {
    final row = Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );

    return intrinsicHeight ? IntrinsicHeight(child: row) : row;
  }

  /// Creates a responsive container with overflow protection
  static Widget safeContainer({
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Decoration? decoration,
    bool flexible = false,
    bool expanded = false,
  }) {
    var container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      child: child,
    );

    if (expanded) {
      return Expanded(child: container);
    } else if (flexible) {
      return Flexible(child: container);
    }

    return container;
  }

  /// Creates a responsive card with overflow-safe content
  static Widget safeCard({
    required BuildContext context,
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool flexible = false,
  }) {
    final card = Card(
      color: color,
      elevation: elevation ?? 4.0,
      shape: shape,
      margin: margin ?? EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16) * 0.5),
      child: Padding(
        padding: padding ?? EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        child: child,
      ),
    );

    return flexible ? Flexible(child: card) : card;
  }

  /// Creates a responsive grid with overflow protection
  static Widget safeGrid({
    required BuildContext context,
    required List<Widget> children,
    int? crossAxisCount,
    double? aspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = true,
    ScrollPhysics? physics,
  }) {
    final defaultSpacing = ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16).toDouble();
    final defaultCrossAxis = ResponsiveUtils.getResponsiveValue(context, mobile: 2, tablet: 3, desktop: 4);
    
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.all(defaultSpacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount ?? defaultCrossAxis.toInt(),
        childAspectRatio: aspectRatio ?? 0.8,
        mainAxisSpacing: mainAxisSpacing ?? defaultSpacing,
        crossAxisSpacing: crossAxisSpacing ?? defaultSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Creates a responsive list with overflow protection
  static Widget safeList({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = true,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool separated = false,
    Widget? separator,
  }) {
    if (separated && separator != null) {
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        scrollDirection: scrollDirection,
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => separator,
      );
    }

    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      scrollDirection: scrollDirection,
      children: children,
    );
  }

  /// Creates a responsive expansion layout that prevents overflow
  static Widget safeExpansion({
    required Widget title,
    required List<Widget> children,
    bool initiallyExpanded = false,
    EdgeInsetsGeometry? tilePadding,
    EdgeInsetsGeometry? childrenPadding,
  }) {
    return ExpansionTile(
      title: title,
      initiallyExpanded: initiallyExpanded,
      tilePadding: tilePadding,
      childrenPadding: childrenPadding,
      children: children.map((child) {
        if (child is Text) {
          return safeText(
            child.data ?? '',
            style: child.style,
            maxLines: child.maxLines,
          );
        }
        return child;
      }).toList(),
    );
  }

  /// Creates responsive spacing that scales with screen size
  static Widget responsiveSpacing(BuildContext context, {
    double? horizontal,
    double? vertical,
    double multiplier = 1.0,
  }) {
    final scaleFactor = MediaQuery.of(context).size.width / 400; // Base scale
    
    return SizedBox(
      width: horizontal != null 
          ? horizontal * multiplier * scaleFactor
          : null,
      height: vertical != null 
          ? vertical * multiplier * scaleFactor
          : null,
    );
  }

  /// Creates a responsive wrap widget for overflow-safe layouts
  static Widget safeWrap({
    required List<Widget> children,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Creates a responsive sized box with screen-relative dimensions
  static Widget responsiveSizedBox(
    BuildContext context, {
    double? width,
    double? height,
    double? widthFactor,
    double? heightFactor,
    Widget? child,
  }) {
    final screenSize = MediaQuery.of(context).size;
    
    return SizedBox(
      width: width ?? (widthFactor != null ? screenSize.width * widthFactor : null),
      height: height ?? (heightFactor != null ? screenSize.height * heightFactor : null),
      child: child,
    );
  }

  /// Validates if content fits in available space
  static bool contentFitsInSpace(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    return !textPainter.didExceedMaxLines;
  }

  /// Creates adaptive text that scales down if needed
  static Widget adaptiveText(
    BuildContext context,
    String text, {
    TextStyle? style,
    double? maxWidth,
    int? maxLines = 1,
  }) {
    if (maxWidth == null) {
      return safeText(text, style: style, maxLines: maxLines);
    }

    // Start with the provided style or default
    var currentStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    var fontSize = currentStyle.fontSize ?? 14.0;

    // Check if text fits, if not reduce font size
    while (fontSize > 8.0) {
      final testStyle = currentStyle.copyWith(fontSize: fontSize);
      if (contentFitsInSpace(context, text, testStyle, maxWidth)) {
        break;
      }
      fontSize -= 1.0;
    }

    return safeText(
      text,
      style: currentStyle.copyWith(fontSize: fontSize),
      maxLines: maxLines,
    );
  }
}
