import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../ride/search_ride_screen.dart';
import '../ride/create_ride_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Hosts the four main tabs and swaps between a bottom navigation bar
/// (phones) and a side navigation rail (tablets/desktop/web) using
/// [ResponsiveBuilder] so one shell serves every screen size.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    SearchRideScreen(),
    CreateRideScreen(),
    ProfileScreen(),
  ];

  static const _destinations = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.search_outlined, selectedIcon: Icons.search_rounded, label: 'Find Ride'),
    (icon: Icons.add_circle_outline_rounded, selectedIcon: Icons.add_circle_rounded, label: 'Post Ride'),
    (icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => Scaffold(
        body: IndexedStack(index: _index, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
          ],
        ),
      ),
      tablet: (_) => _railLayout(),
      desktop: (_) => _railLayout(),
    );
  }

  Widget _railLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.surface,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: IndexedStack(index: _index, children: _tabs)),
        ],
      ),
    );
  }
}
