/// Development flags — flip these during development, set all to false before release.
class DevFlags {
  DevFlags._();

  /// Set to true to always show onboarding, even if a name is already saved.
  /// Useful for testing the onboarding flow without clearing app data.
  static const bool forceShowOnboarding = false;
}