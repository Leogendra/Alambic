import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../clock.dart';

/// The current moment, refreshed every minute so that "due" counts follow the
/// time of day without any data change.
final currentMomentProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return Stream<DateTime>.multi((controller) {
    controller.add(clock());
    final ticks = Stream<void>.periodic(const Duration(minutes: 1))
        .listen((_) => controller.add(clock()));
    controller.onCancel = ticks.cancel;
  });
});
