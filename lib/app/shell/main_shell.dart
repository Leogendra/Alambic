import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/notifications/notification_providers.dart';
import '../../application/notifications/notification_target.dart';
import '../../application/onboarding/onboarding_providers.dart';
import '../../features/cards/card_navigation.dart';
import '../../features/groups/group_detail_screen.dart';
import '../../features/groups/groups_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/session/session_launcher.dart';
import '../../features/settings/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import 'alambic_tab_bar.dart';

/// Root screen: three tabs and the "+" button that creates a card. A
/// notification touched opens a session above it. Right after the
/// onboarding, the group it created opens with "Distill" highlighted.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFirstGroup());
  }

  void _openFirstGroup() {
    final groupId = ref.read(firstGroupProvider.notifier).take();
    if (groupId != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              GroupDetailScreen(groupId: groupId, highlightDistill: true),
        ),
      );
    }
  }

  @override
  void dispose() {
    _openedTargets?.cancel();
    super.dispose();
  }

  void _open(NotificationTarget target) =>
      openNotificationSession(context, ref, target);

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
            const SettingsScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: strings.addCardTooltip,
        onPressed: () => openNewCard(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AlambicTabBar(
        selectedIndex: _selectedTab,
        onSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          TabDestination(icon: Icons.home_outlined, label: strings.tabHome),
          TabDestination(icon: Icons.layers_outlined, label: strings.tabGroups),
          TabDestination(
            icon: Icons.settings_outlined,
            label: strings.tabSettings,
          ),
        ],
      ),
    );
  }
}
