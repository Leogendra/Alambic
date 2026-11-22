import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/about/app_about.dart';
import '../../data/about/plugin_app_about.dart';

/// The version and the repository of the app; replaced in tests.
final appAboutProvider = Provider<AppAbout>((ref) => const PluginAppAbout());

final appVersionProvider = FutureProvider<String>(
  (ref) => ref.watch(appAboutProvider).version(),
);
