import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';

/// A responsive sheet that shows as:
/// - Bottom sheet on mobile devices
/// - Centered modal dialog on desktop/web
///
/// Features:
/// - Drag handle on mobile for intuitive dismissal
/// - Smooth animations
/// - Consistent styling across platforms
/// - Optional header with title and close button
/// - Scrollable content area
class ResponsiveSheet extends StatelessWidget {
  const ResponsiveSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.maxHeight,
    this.padding,
    this.actions,
  });

  /// The main content of the sheet
  final Widget child;

  /// Optional title displayed in the header
  final String? title;

  /// Optional subtitle below the title
  final String? subtitle;

  /// Whether to show the close button (default: true)
  final bool showCloseButton;

  /// Whether to show the drag handle on mobile (default: true)
  final bool showDragHandle;

  /// Maximum height of the sheet (defaults to 85% of screen height)
  final double? maxHeight;

  /// Custom padding for the content
  final EdgeInsets? padding;

  /// Optional action buttons at the bottom
  final List<Widget>? actions;

  /// Shows the sheet - automatically chooses between bottom sheet and dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    bool showCloseButton = true,
    bool showDragHandle = true,
    double? maxHeight,
    EdgeInsets? padding,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final isDesktop = Responsive.isDesktop(context);

    final sheet = ResponsiveSheet(
      title: title,
      subtitle: subtitle,
      showCloseButton: showCloseButton,
      showDragHandle: showDragHandle && !isDesktop,
      maxHeight: maxHeight,
      padding: padding,
      actions: actions,
      child: child,
    );

    if (isDesktop) {
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) => _DesktopModal(maxHeight: maxHeight, child: sheet),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (showDragHandle) _buildDragHandle(theme),

          // Header
          if (title != null || showCloseButton) _buildHeader(context, theme),

          // Divider after header
          if (title != null)
            Divider(
              height: 1,
              color: theme.colorScheme.border.withValues(alpha: 0.5),
            ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: padding ?? const EdgeInsets.all(AppConstants.spacingLg),
              child: child,
            ),
          ),

          // Actions
          if (actions != null && actions!.isNotEmpty) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.border.withValues(alpha: 0.5),
            ),
            _buildActions(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDragHandle(ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.mutedForeground.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ShadThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        showDragHandle ? 0 : AppConstants.spacingMd,
        showCloseButton ? AppConstants.spacingSm : AppConstants.spacingLg,
        AppConstants.spacingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close, color: theme.colorScheme.mutedForeground),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ShadThemeData theme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Row(
          children: actions!.map((action) {
            final index = actions!.indexOf(action);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index > 0 ? AppConstants.spacingSm : 0,
                ),
                child: action,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Desktop modal wrapper
class _DesktopModal extends StatelessWidget {
  const _DesktopModal({required this.child, this.maxHeight});

  final Widget child;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.8;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: effectiveMaxHeight,
          ),
          margin: const EdgeInsets.all(AppConstants.spacingXl),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Confirmation sheet with icon, title, message, and action buttons
class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.isLoading = false,
    this.details,
  });

  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool isLoading;
  final List<ConfirmationDetail>? details;

  /// Shows confirmation sheet and returns true if confirmed
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    List<ConfirmationDetail>? details,
  }) {
    return ResponsiveSheet.show<bool>(
      context: context,
      showCloseButton: false,
      child: ConfirmationSheet(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        details: details,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final effectiveIconColor =
        iconColor ??
        (isDestructive
            ? theme.colorScheme.destructive
            : theme.colorScheme.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: effectiveIconColor),
          ),
          const SizedBox(height: AppConstants.spacingMd),
        ],

        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),

        // Message
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),

        // Details
        if (details != null && details!.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingLg),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: details!.map((detail) {
                final index = details!.indexOf(detail);
                return Padding(
                  padding: EdgeInsets.only(
                    top: index > 0 ? AppConstants.spacingSm : 0,
                  ),
                  child: Row(
                    children: [
                      if (detail.icon != null) ...[
                        Icon(
                          detail.icon,
                          size: 16,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: AppConstants.spacingSm),
                      ],
                      Text(
                        '${detail.label}:',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingXs),
                      Expanded(
                        child: Text(
                          detail.value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.foreground,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: AppConstants.spacingXl),

        // Actions
        Row(
          children: [
            Expanded(
              child: ShadButton.outline(
                onPressed: isLoading ? null : onCancel,
                child: Text(cancelText),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: isDestructive
                  ? ShadButton.destructive(
                      onPressed: isLoading ? null : onConfirm,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(confirmText),
                    )
                  : ShadButton(
                      onPressed: isLoading ? null : onConfirm,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(confirmText),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Detail item for confirmation sheets
class ConfirmationDetail {
  const ConfirmationDetail({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}
