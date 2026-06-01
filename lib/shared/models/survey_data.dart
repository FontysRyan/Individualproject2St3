/// Simple data class that collects all survey answers before
/// handing them off to the swipe-game page.
class ActivityEntry {
  final String name;
  final int hours;
  final int minutes;

  const ActivityEntry({
    required this.name,
    required this.hours,
    required this.minutes,
  });

  /// Total duration in minutes.
  int get totalMinutes => hours * 60 + minutes;

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

class SurveyDayData {
  final int availableHours;
  final int availableMinutes;
  final DateTime? startTime;
  final List<ActivityEntry> activities;

  const SurveyDayData({
    this.availableHours = 4,
    this.availableMinutes = 0,
    this.startTime,
    this.activities = const [],
  });

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

  int get totalAvailableMinutes => availableHours * 60 + availableMinutes;
}