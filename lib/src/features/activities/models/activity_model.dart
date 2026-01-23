enum ActivityType { daily, rutinan }

enum AttendanceStatus { present, late, absent, permission, pending }

/// Represents a defined activity in the school
class Activity {
  final String id;
  final String schoolId;
  final String? levelId; // If null, applies to all levels
  final String name;
  final ActivityType type;
  final String? description;

  const Activity({
    required this.id,
    required this.schoolId,
    this.levelId,
    required this.name,
    required this.type,
    this.description,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      schoolId: json['school_id'],
      levelId: json['level_id'],
      name: json['name'],
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.daily,
      ),
      description: json['description'],
    );
  }
}

/// Represents a student's attendance for a specific activity on a specific date
class ActivityAttendance {
  final String id;
  final String activityId;
  final String studentId;
  final DateTime date;
  final AttendanceStatus status; // present, late, absent, permission
  final String? remarks;

  const ActivityAttendance({
    required this.id,
    required this.activityId,
    required this.studentId,
    required this.date,
    required this.status,
    this.remarks,
  });
}

/// Helper model to combine Activity with its daily status
class ActivityWithStatus {
  final Activity activity;
  final ActivityAttendance? attendance;

  const ActivityWithStatus({required this.activity, this.attendance});

  AttendanceStatus get status => attendance?.status ?? AttendanceStatus.pending;
}
