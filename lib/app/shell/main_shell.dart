import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/notifications/notification_providers.dart';
import '../../application/notifications/notification_target.dart';
import '../../features/cards/card_navigation.dart';
import '../../features/groups/group_detail_screen.dart';
import '../../features/groups/groups_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';

/// Root screen: four tabs and the "+" button that creates a card. A grouped
/// reminder touched in the notifications opens its group above it, the
/// digest of a moment opens Home.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedTab = 0;
  StreamSubscription<NotificationTarget>? _openedTargets;

  @override
  void initState() {
    super.initState();
    _openedTargets = ref.read(notificationTargetsProvider).listen(_open);
  }

  @override
  void dispose() {
    _openedTargets?.cancel();
    super.dispose();
  }

  void _open(NotificationTarget target) {
    final navigator = Navigator.of(context)..popUntil((route) => route.isFirst);
    switch (target.groupId) {
      case final groupId?:
        navigator.push(
          MaterialPageRoute<void>(
            builder: (context) => GroupDetailScreen(groupId: groupId),
          ),
        );
      case null:
        setState(() => _selectedTab = 0);
    }
  }

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
