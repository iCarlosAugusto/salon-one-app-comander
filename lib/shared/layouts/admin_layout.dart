import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/services/session_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../routes/app_routes.dart';

/// Main admin layout with responsive sidebar/drawer navigation
class AdminLayout extends StatelessWidget {
  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _MobileLayout(currentRoute: currentRoute, child: child),
      tablet: _TabletLayout(currentRoute: currentRoute, child: child),
      desktop: _DesktopLayout(currentRoute: currentRoute, child: child),
    );
  }
}

/// Desktop layout with expanded sidebar
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.child, required this.currentRoute});

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      body: Row(
        children: [
          _Sidebar(currentRoute: currentRoute, isExpanded: true),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Tablet layout with collapsed sidebar
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.child, required this.currentRoute});

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      body: Row(
        children: [
          _Sidebar(currentRoute: currentRoute, isExpanded: false),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Mobile layout with drawer
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.child, required this.currentRoute});

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.card,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.foreground),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Salon One',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: theme.colorScheme.card,
        child: _DrawerContent(currentRoute: currentRoute),
      ),
      body: child,
    );
  }
}

/// Sidebar widget for desktop and tablet
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentRoute, required this.isExpanded});

  final String currentRoute;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final sessionService = Get.find<SessionService>();

    return Container(
      width: isExpanded ? 256 : 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          right: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded
                  ? AppConstants.spacingMd
                  : AppConstants.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    'Salon One',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation items
          Expanded(
            child: FutureBuilder(
              future: sessionService.getUserData(),
              builder: (context, snapshot) {
                final isAdmin = snapshot.data?.isAdmin ?? false;

                return ListView(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.spacingMd,
                    horizontal: isExpanded ? AppConstants.spacingSm : 0,
                  ),
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard,
                      label: 'Dashboard',
                      route: Routes.dashboard,
                      currentRoute: currentRoute,
                      isExpanded: isExpanded,
                    ),
                    _NavItem(
                      icon: Icons.calendar_today_outlined,
                      selectedIcon: Icons.calendar_today,
                      label: 'Appointments',
                      route: Routes.appointments,
                      currentRoute: currentRoute,
                      isExpanded: isExpanded,
                    ),
                    // Admin-only items
                    if (isAdmin) ...[
                      _NavItem(
                        icon: Icons.spa_outlined,
                        selectedIcon: Icons.spa,
                        label: 'Services',
                        route: Routes.services,
                        currentRoute: currentRoute,
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.people_outline,
                        selectedIcon: Icons.people,
                        label: 'Employees',
                        route: Routes.employees,
                        currentRoute: currentRoute,
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings,
                        label: 'Settings',
                        route: Routes.settings,
                        currentRoute: currentRoute,
                        isExpanded: isExpanded,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer content for mobile
class _DrawerContent extends StatelessWidget {
  const _DrawerContent({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final sessionService = Get.find<SessionService>();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salon One',
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Navigation items
          Expanded(
            child: FutureBuilder(
              future: sessionService.getUserData(),
              builder: (context, snapshot) {
                final isAdmin = snapshot.data?.isAdmin ?? false;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingSm,
                  ),
                  children: [
                    _DrawerNavItem(
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard,
                      label: 'Dashboard',
                      route: Routes.dashboard,
                      currentRoute: currentRoute,
                    ),
                    _DrawerNavItem(
                      icon: Icons.calendar_today_outlined,
                      selectedIcon: Icons.calendar_today,
                      label: 'Appointments',
                      route: Routes.appointments,
                      currentRoute: currentRoute,
                    ),
                    // Admin-only items
                    if (isAdmin) ...[
                      _DrawerNavItem(
                        icon: Icons.spa_outlined,
                        selectedIcon: Icons.spa,
                        label: 'Services',
                        route: Routes.services,
                        currentRoute: currentRoute,
                      ),
                      _DrawerNavItem(
                        icon: Icons.people_outline,
                        selectedIcon: Icons.people,
                        label: 'Employees',
                        route: Routes.employees,
                        currentRoute: currentRoute,
                      ),
                      _DrawerNavItem(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings,
                        label: 'Settings',
                        route: Routes.settings,
                        currentRoute: currentRoute,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation item for sidebar
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.isExpanded,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String currentRoute;
  final bool isExpanded;

  bool get isSelected => currentRoute.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded
            ? AppConstants.spacingXs
            : AppConstants.spacingSm,
        vertical: AppConstants.spacingXs / 2,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          onTap: () => Get.toNamed(route),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? AppConstants.spacingMd : 0,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: isSelected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.mutedForeground,
                  size: 22,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : theme.colorScheme.foreground,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item for mobile drawer
class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String currentRoute;

  bool get isSelected => currentRoute.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ListTile(
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected
            ? AppColors.primary
            : theme.colorScheme.mutedForeground,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : theme.colorScheme.foreground,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      onTap: () {
        Navigator.pop(context);
        Get.toNamed(route);
      },
    );
  }
}
