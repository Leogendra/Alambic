/// What the app says about itself: its version and where its code lives. The
/// platform plugins are behind this interface so that the screens showing
/// them are tested without a phone.
abstract interface class AppAbout {
  /// The version of the installed app, without its build number ("0.2.0").
  Future<String> version();

  /// Opens the GitHub repository of the app in the browser.
  Future<void> openRepository();
}
