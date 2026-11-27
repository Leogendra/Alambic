import 'package:alambic/data/about/app_about.dart';

/// The version and the repository of the app, without a phone: the browser
/// is never opened, only counted.
class FakeAppAbout implements AppAbout {
  int repositoryOpened = 0;

  @override
  Future<String> version() async => '1.0.0';

  @override
  Future<void> openRepository() async => repositoryOpened++;
}
