import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_about.dart';

/// The version of the installed package and the browser of the phone,
/// through the package_info_plus and url_launcher plugins.
class PluginAppAbout implements AppAbout {
  const PluginAppAbout();

  static final Uri _repository = Uri.parse(
    'https://github.com/Leogendra/Alambic',
  );

  @override
  Future<String> version() async => (await PackageInfo.fromPlatform()).version;

  @override
  Future<void> openRepository() =>
      launchUrl(_repository, mode: LaunchMode.externalApplication);
}
