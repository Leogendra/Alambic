import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/groups/card_group.dart';

final groupsProvider = StreamProvider<List<CardGroup>>(
  (ref) => ref.watch(groupRepositoryProvider).watchAll(),
);

final groupProvider = StreamProvider.family<CardGroup?, int>(
  (ref, groupId) => ref.watch(groupRepositoryProvider).watchById(groupId),
);
