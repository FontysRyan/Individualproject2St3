/// Typed data classes that travel from the survey flow into the swipe game.
///
/// Validation rules live here rather than in widgets so any screen that builds
/// or mutates an ActivityEntry uses the same thresholds, no duplicated magic

/// The rule: at least 15 minutes OR at least 1 full hour.
/// Both thresholds must stay here so validation messages and the guard
/// in [ActivityEntry.isValidDuration] always agree.
const int activityMinMinutes = 15;
const int activityMinHours = 1;

// ActivityEntry represents a single planned activity with a name and duration.
class ActivityEntry {
  final String name;
  final int hours;
  final int minutes;

  const ActivityEntry({
    required this.name,
    required this.hours,
    required this.minutes,
  });

  int get totalMinutes => hours * 60 + minutes;

  /// An activity passes duration validation when its total is at least
  /// [activityMinMinutes] (15 m), OR the hours field alone is ≥ [activityMinHours].
  /// This means 0h 15m = okey, 1h 0m = is okey, 0h 0m = is not okey.
  bool get isValidDuration =>
      totalMinutes >= activityMinMinutes || hours >= activityMinHours;

  bool get hasName => name.trim().isNotEmpty;

  /// True when both the name and duration pass validation.
  bool get isValid => hasName && isValidDuration;

  String get durationLabel {
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  ActivityEntry copyWith({String? name, int? hours, int? minutes}) {
    return ActivityEntry(
      name: name ?? this.name,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
    );
  }
}

// SurveyDayData represents the full set of data collected in the survey flow for a single day.
class SurveyDayData {
  final int availableHours;
  final int availableMinutes;

  /// Null means the user hasn't picked a start time yet.
  /// The time screen must reject "Continue" while this is null.
  /// if you wanna export your planning to calendar, we should make sure that start time is always set when you continue to the next step. 
  final DateTime? startTime;

  final List<ActivityEntry> activities;

  const SurveyDayData({
    this.availableHours = 4,
    this.availableMinutes = 0,
    this.startTime,
    this.activities = const [],
  });

  int get totalAvailableMinutes => availableHours * 60 + availableMinutes;

  /// Sum of every activity's duration in minutes. Why? To compare against available time and show warnings when the user plans too much.
  int get totalPlannedMinutes =>
      activities.fold(0, (sum, a) => sum + a.totalMinutes);

  /// True when planned activities would fit inside the available window we set at the available time screen.
  bool get activitiesFitAvailableTime =>
      totalPlannedMinutes <= totalAvailableMinutes;

  SurveyDayData copyWith({
    int? availableHours,
    int? availableMinutes,
    DateTime? startTime,
    List<ActivityEntry>? activities,
  }) {
    return SurveyDayData(
      availableHours: availableHours ?? this.availableHours,
      availableMinutes: availableMinutes ?? this.availableMinutes,
      startTime: startTime ?? this.startTime,
      activities: activities ?? this.activities,
    );
  }
}