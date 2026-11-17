import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/groups/card_group.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../presets/preset_providers.dart';
import '../scheduling/scheduling_providers.dart';
import '../time/minute_ticker.dart';
import 'group_overview.dart';
import 'group_service.dart';
import 'group_summary.dart';

final groupsProvider = StreamProvider<List<CardGroup>>(
  (ref) => ref.watch(groupRepositoryProvider).watchAll(),
);

final groupProvider = StreamProvider.family<CardGroup?, int>(
  (ref, groupId) => ref.watch(groupRepositoryProvider).watchById(groupId),
);

final groupOverviewProvider = Provider(
  (ref) => GroupOverview(ref.watch(duePolicyProvider)),
);

/// Every group, with its counts; empty while loading.
final groupSummariesProvider = Provider<List<GroupSummary>>((ref) {
  final groups = ref.watch(groupsProvider).value;
  final cards = ref.watch(allCardsProvider).value;
  final catalog = ref.watch(presetCatalogProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  if (groups == null || cards == null || catalog == null || now == null) {
    return const [];
  } else {
    return ref
        .watch(groupOverviewProvider)
        .summarize(groups: groups, cards: cards, catalog: catalog, now: now);
  }
});

/// Summary of one group; `null` while loading or once deleted.
final groupSummaryProvider = Provider.family<GroupSummary?, int>(
  (ref, groupId) => ref
      .watch(groupSummariesProvider)
      .where((summary) => summary.groupId == groupId)
      .firstOrNull,
);

final groupServiceProvider = Provider(
  (ref) => GroupService(
    groups: ref.watch(groupRepositoryProvider),
    cards: ref.watch(cardRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    settings: ref.watch(notificationSettingsRepositoryProvider),
    images: ref.watch(imageStoreProvider),
    scheduler: ref.watch(reviewSchedulerProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);
