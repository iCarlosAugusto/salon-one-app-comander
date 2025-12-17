import 'package:flutter/material.dart';
import 'package:salon_one_comander/core/utils/responsive.dart';

/// A reusable, generic list component with built-in support for:
/// - Responsive layouts (single column on mobile, adaptive grid on desktop)
/// - Pull-to-refresh functionality
/// - Loading, error, and empty states
/// - Fully customizable item rendering via itemBuilder
///
/// Not coupled to any state management solution - uses simple callbacks.
class GenericListView<T> extends StatelessWidget {
  const GenericListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.errorMessage = "Alguma coisa deu errado. Tente novamente mais tarde",
    this.hasError = false,
    this.onRetry,
    this.onRefresh,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyAction,
    this.emptyActionLabel,
    this.padding,
    this.mobileBreakpoint = 600,
    this.desktopItemWidth = 350,
    this.desktopSpacing = 16,
  });

  /// The list of items to display
  final List<T> items;

  /// Builder function to render each item
  /// Provides the BuildContext, item, and index
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Whether the list is in a loading state
  final bool isLoading;

  /// Error message to display (if not null, shows error state)
  final String errorMessage;

  /// Whether the list has an error state
  final bool hasError;

  /// Callback when user taps retry in error state
  final VoidCallback? onRetry;

  /// Callback for pull-to-refresh
  /// If null, pull-to-refresh is disabled
  final Future<void> Function()? onRefresh;

  /// Icon to show in empty state
  final IconData? emptyIcon;

  /// Title for empty state
  final String? emptyTitle;

  /// Message for empty state
  final String? emptyMessage;

  /// Callback for empty state action button
  final VoidCallback? emptyAction;

  /// Label for empty state action button
  final String? emptyActionLabel;

  /// Padding around the list
  final EdgeInsets? padding;

  /// Screen width threshold for mobile/desktop switch
  final double mobileBreakpoint;

  /// Preferred width for items on desktop (used for grid calculation)
  final double desktopItemWidth;

  /// Spacing between items on desktop grid
  final double desktopSpacing;

  @override
  Widget build(BuildContext context) {
    // Priority: Loading > Error > Empty > List
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (hasError) {
      return _buildErrorState(context);
    }

    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildList(context);
  }

  /// Loading state with centered spinner
  Widget _buildLoadingState(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  /// Error state with message and optional retry button
  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Empty state with optional icon, message, and action
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              emptyIcon ?? Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle ?? 'No items found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (emptyMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                emptyMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (emptyAction != null && emptyActionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: emptyAction,
                child: Text(emptyActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Main list content with responsive layout
  Widget _buildList(BuildContext context) {
    final listContent = LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > mobileBreakpoint;

        if (isDesktop) {
          return _buildDesktopGrid(context, constraints);
        } else {
          return _buildMobileList(context);
        }
      },
    );

    // Wrap with RefreshIndicator if onRefresh is provided
    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: listContent);
    }

    return listContent;
  }

  /// Single-column list for mobile
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          itemBuilder(context, items[index], index),
    );
  }

  /// Adaptive grid for desktop
  Widget _buildDesktopGrid(BuildContext context, BoxConstraints constraints) {
    // Calculate number of columns based on available width
    final availableWidth = constraints.maxWidth - (padding?.horizontal ?? 32);
    final crossAxisCount = (availableWidth / desktopItemWidth).floor().clamp(
      1,
      6,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ResponsiveGrid(
        mobileColumns: 1,
        tabletColumns: 2,
        desktopColumns: 3,
        children: List.generate(
          items.length,
          (index) => itemBuilder(context, items[index], index),
        ),
      ),
    );
  }
}
