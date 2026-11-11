import 'package:flutter/material.dart';

import '../../features/cards/card_navigation.dart';
import '../../features/groups/groups_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';

/// Root screen: four tabs and the "+" button that creates a card.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            const HomeScreen(),
            const GroupsScreen(),
            Center(child: Text(strings.statisticsComingSoon)),
            const SettingsScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: strings.addCardTooltip,
        onPressed: () => openNewCard(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: strings.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: strings.tabGroups,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: strings.tabStatistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: strings.tabSettings,
          ),
        ],
      ),
    );
  }
}
