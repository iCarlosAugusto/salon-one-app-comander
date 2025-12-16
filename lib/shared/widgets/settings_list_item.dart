import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_theme.dart';

/// Reusable settings list item following Material Design guidelines
///
/// Features:
/// - Leading icon in a colored container
/// - Title and optional subtitle
/// - Trailing navigation indicator
/// - 48dp minimum tap target for accessibility
/// - Proper tap feedback
class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.trailing,
    this.showChevron = true,
  });

  /// Leading icon
  final IconData icon;

  /// Primary text
  final String title;

  /// Secondary text (optional)
  final String? subtitle;

  /// Tap callback
  final VoidCallback? onTap;

  /// Icon color (defaults to primary)
  final Color? iconColor;

  /// Icon background color (defaults to primary with opacity)
  final Color? iconBackgroundColor;

  /// Custom trailing widget (replaces chevron if provided)
  final Widget? trailing;

  /// Whether to show chevron indicator (default true)
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveIconBgColor =
        iconBackgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64), // Accessibility
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          child: Row(
            children: [
              // Leading icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 22),
              ),
              const SizedBox(width: AppConstants.spacingMd),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: context.appTextTheme.titleSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: context.appTextTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              if (trailing != null)
                trailing!
              else if (showChevron && onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.mutedForeground,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section header for grouping settings items
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  /// Section header text
  final String title;

  /// List items in this section
  final List<Widget> children;

  /// Optional padding override
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: Text(
              title.toUpperCase(),
              style: context.appTextTheme.labelSmall.copyWith(
                letterSpacing: 1.2,
              ),
            ),
          ),
          ShadCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingXs,
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
