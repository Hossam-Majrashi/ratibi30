import 'package:flutter/material.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/utils/responsive_helper.dart';
import 'package:ratibi30/l10n/l10n.dart';

class NavItem {
  const NavItem(this.labelKey, this.icon, this.route);

  final String labelKey;
  final IconData icon;
  final String route;
}

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
  });

  final String title;
  final String currentRoute;
  final Widget child;

  static const desktopItems = [
    NavItem('dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
    NavItem('expenses', Icons.receipt_long_outlined, AppRoutes.expenses),
    NavItem('add', Icons.add_circle_outline, AppRoutes.addExpense),
    NavItem('charityBox', Icons.volunteer_activism_outlined, AppRoutes.charity),
    NavItem('reports', Icons.pie_chart_outline, AppRoutes.reports),
    NavItem('calendar', Icons.calendar_month_outlined, AppRoutes.calendar),
    NavItem('savings', Icons.account_balance_wallet_outlined, AppRoutes.savings),
    NavItem('settings', Icons.settings_outlined, AppRoutes.settings),
  ];

  static const mobileItems = [
    NavItem('home', Icons.dashboard_outlined, AppRoutes.dashboard),
    NavItem('expenses', Icons.receipt_long_outlined, AppRoutes.expenses),
    NavItem('add', Icons.add_circle_outline, AppRoutes.addExpense),
    NavItem('charityBox', Icons.volunteer_activism_outlined, AppRoutes.charity),
    NavItem('reports', Icons.pie_chart_outline, AppRoutes.reports),
    NavItem('settings', Icons.settings_outlined, AppRoutes.settings),
  ];

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (isDesktop) {
      final rawIndex = desktopItems.indexWhere((e) => e.route == currentRoute);
      final selectedIndex = rawIndex < 0 ? 0 : rawIndex;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _go(context, desktopItems[index].route),
              destinations: desktopItems
                  .map((e) => NavigationRailDestination(icon: Icon(e.icon), label: Text(context.l10n.t(e.labelKey))))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Scaffold(
                appBar: AppBar(title: Text(title)),
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final mobileIndex = mobileItems.indexWhere((e) => e.route == currentRoute);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: context.l10n.t('calendar'),
            onPressed: () => _go(context, AppRoutes.calendar),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: context.l10n.t('savings'),
            onPressed: () => _go(context, AppRoutes.savings),
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 20 : 12),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: mobileIndex < 0 ? 0 : mobileIndex,
        onDestinationSelected: (index) => _go(context, mobileItems[index].route),
        destinations: mobileItems
            .map((e) => NavigationDestination(icon: Icon(e.icon), label: context.l10n.t(e.labelKey)))
            .toList(),
      ),
    );
  }
}
