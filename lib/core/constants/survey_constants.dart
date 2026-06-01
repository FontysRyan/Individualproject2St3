/// Constants for the SurveyDayScreen flow.
/// Keep magic numbers here so they're easy to find and adjust.
class SurveyConstants {
  SurveyConstants._();

  // ── Steps ─────────────────────────────────────────────────────────────────

  /// Total number of survey steps (drives the progress bar).
  static const int totalSteps = 3;

  static const int stepTime = 0;
  static const int stepActivities = 1;
  static const int stepReady = 2;

  // ── Time step defaults ────────────────────────────────────────────────────

  static const int defaultAvailableHours = 4;
  static const int defaultAvailableMinutes = 0;

  /// Minimum available hours — must be at least 1 to allow activity planning.
  static const int minAvailableHours = 1;

  static const int maxAvailableHours = 24;
  static const int minuteStep = 15; // stepper jumps: 0 / 15 / 30 / 45
  static const int maxAvailableMinutes = 45;

  // ── Activity step limits ──────────────────────────────────────────────────

  static const int activityMinHours = 0;
  static const int activityMaxHours = 12;
  static const int activityMinMinutes = 0;
  static const int activityMaxMinutes = 45;

  /// Minimum duration for a single activity (minutes).
  static const int activityMinDurationMinutes = 15;

  static const int defaultActivityHours = 1;
  static const int defaultActivityMinutes = 0;

  // ── Intro animation timings ───────────────────────────────────────────────

  static const Duration introAnimationDuration = Duration(milliseconds: 2800);
  static const Duration stepSwitchDuration = Duration(milliseconds: 320);

  // ── Layout ────────────────────────────────────────────────────────────────

  static const double cardHorizontalGap = 12.0;
  static const double cardTopGap = 96.0;
  static const double cardBottomGap = 80.0;

  static const double cardMinWidth = 100.0;
  static const double cardMinHeight = 88.0;

  static const double archBorderRadius = 80.0;
  static const double m3BorderRadius = 28.0;
}