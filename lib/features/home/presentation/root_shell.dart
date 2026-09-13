import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../maps/presentation/map_placeholder_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../search/presentation/search_screen.dart';
import 'add_options_sheets.dart';
import 'home_tab_screen.dart';

/// Bottom navigation-и асосии PAYDO.TJ (banди 7 спецификатсия):
/// 🏠 Home · 🔎 Search · ➕ Add · 🗺️ Map · 👤 Profile
///
/// Қарори тарроҳӣ: "Add" tab нест — тугмаи амалӣ аст, ки bottom sheet
/// мекушояд (banди 4: маҳсулот/кор/хизмат/эълон). Бинобар ин indexKey
/// барои он мустақим ба IndexedStack намерасад.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tabIndex = 0; // 0=Home, 1=Search, 2=Map, 3=Profile (Add алоҳида)

  static const _searchTab = SearchScreen();
  static const _mapTab = MapPlaceholderScreen();
  static const _profileTab = ProfileScreen();

  void _onCategoryTap(String routeKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$routeKey" ҳоло дар марҳилаи баъдӣ илова мешавад.')),
    );
  }

  void _onNavTap(int navIndex) {
    // navIndex: 0=Home, 1=Search, 2=Add, 3=Map, 4=Profile
    if (navIndex == 2) {
      showAddOptionsSheet(context);
      return;
    }
    final tabIndex = navIndex < 2 ? navIndex : navIndex - 1;
    setState(() => _tabIndex = tabIndex);
  }

  int get _selectedNavIndex => _tabIndex < 2 ? _tabIndex : _tabIndex + 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          HomeTabScreen(
            onSearchTap: () => setState(() => _tabIndex = 1),
            onCategoryTap: _onCategoryTap,
          ),
          _searchTab,
          _mapTab,
          _profileTab,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: AppStrings.navSearch,
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 20),
            ),
            label: AppStrings.navAdd,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: AppStrings.navMap,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
