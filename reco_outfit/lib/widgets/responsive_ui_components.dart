import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';

/// Enhanced button with responsive design and multiple variants
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final bool loading;
  final Color? customColor;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.loading = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getButtonHeight(context);
    final buttonPadding = _getButtonPadding(context);
    final textStyle = _getTextStyle(context);
    final buttonColor = customColor ?? _getButtonColor();
    final foregroundColor = _getForegroundColor();

    Widget child = loading
        ? SizedBox(
            height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
            width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: ResponsiveUtils.getResponsiveIconSize(context) - 2,
                  color: foregroundColor,
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
              ],
              Flexible(
                child: Text(
                  text, 
                  style: textStyle?.copyWith(color: foregroundColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );

    final button = _buildButtonVariant(
      context,
      child: child,
      onPressed: loading ? null : onPressed,
      buttonColor: buttonColor,
      foregroundColor: foregroundColor,
      padding: buttonPadding,
      height: buttonHeight,
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: buttonHeight,
      child: button,
    );
  }

  Widget _buildButtonVariant(
    BuildContext context, {
    required Widget child,
    required VoidCallback? onPressed,
    required Color buttonColor,
    required Color foregroundColor,
    required EdgeInsets padding,
    required double height,
  }) {
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: foregroundColor,
            elevation: ResponsiveUtils.getResponsiveElevation(context),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: padding,
          ),
          child: child,
        );
      case ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor, width: 2),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: padding,
          ),
          child: child,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: buttonColor,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: padding,
          ),
          child: child,
        );
      case ButtonVariant.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.3),
                blurRadius: ResponsiveUtils.getResponsiveElevation(context),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: borderRadius,
              child: Container(
                padding: padding,
                child: Center(child: child),
              ),
            ),
          ),
        );
    }
  }

  double _getButtonHeight(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return ResponsiveUtils.getResponsiveValue(context, mobile: 36, tablet: 40, desktop: 44);
      case ButtonSize.medium:
        return ResponsiveUtils.getButtonHeight(context);
      case ButtonSize.large:
        return ResponsiveUtils.getResponsiveValue(context, mobile: 56, tablet: 64, desktop: 72);
    }
  }

  EdgeInsets _getButtonPadding(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24),
          vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
        );
      case ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 32),
          vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
        );
      case ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40),
          vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24),
        );
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
    }
  }

  Color _getButtonColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
        return customColor ?? AppTheme.primaryColor;
      case ButtonVariant.secondary:
      case ButtonVariant.text:
        return customColor ?? AppTheme.primaryColor;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
        return Colors.white;
      case ButtonVariant.secondary:
      case ButtonVariant.text:
        return customColor ?? AppTheme.primaryColor;
    }
  }
}

/// Enhanced card with responsive design
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final bool border;
  final Color? borderColor;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.border = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final cardElevation = elevation ?? ResponsiveUtils.getResponsiveElevation(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: borderRadius,
        border: border 
            ? Border.all(
                color: borderColor ?? Theme.of(context).dividerColor,
                width: ResponsiveUtils.getResponsiveValue(context, mobile: 1, tablet: 1.5, desktop: 2),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: cardElevation,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: cardPadding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Responsive text input field
class ResponsiveTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final String? errorText;
  final bool required;

  const ResponsiveTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? Theme.of(context).cardColor : Theme.of(context).disabledColor.withOpacity(0.1),
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            border: Border.all(
              color: errorText != null ? Theme.of(context).colorScheme.error : Theme.of(context).dividerColor,
              width: errorText != null ? 2 : 1,
            ),
            boxShadow: [
              if (enabled)
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            keyboardType: keyboardType,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                      ),
                      onPressed: onSuffixIconTap,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Responsive loading indicator
class ResponsiveLoading extends StatelessWidget {
  final String? message;
  final LoadingSize size;

  const ResponsiveLoading({
    super.key,
    this.message,
    this.size = LoadingSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorSize = _getIndicatorSize(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: ResponsiveUtils.getResponsiveValue(context, mobile: 3, tablet: 4, desktop: 5),
              color: AppTheme.primaryColor,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  double _getIndicatorSize(BuildContext context) {
    switch (size) {
      case LoadingSize.small:
        return ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 28, desktop: 32);
      case LoadingSize.medium:
        return ResponsiveUtils.getResponsiveValue(context, mobile: 40, tablet: 48, desktop: 56);
      case LoadingSize.large:
        return ResponsiveUtils.getResponsiveValue(context, mobile: 64, tablet: 72, desktop: 80);
    }
  }
}

/// Responsive section header
class ResponsiveSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showDivider;

  const ResponsiveSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
        if (showDivider) ...[
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          Divider(
            color: Theme.of(context).dividerColor,
            thickness: ResponsiveUtils.getResponsiveValue(context, mobile: 1, tablet: 1.5, desktop: 2),
          ),
        ],
      ],
    );
  }
}

// Enums
enum ButtonVariant { primary, secondary, text, gradient }
enum ButtonSize { small, medium, large }
enum LoadingSize { small, medium, large }
