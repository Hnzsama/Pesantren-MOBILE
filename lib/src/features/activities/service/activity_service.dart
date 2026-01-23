import 'package:pesantren_mobile/src/features/activities/models/activity_model.dart';

class ActivityService {
  // Mock 'Activities' Table
  final List<Activity> _mockActivities = [
    // Daily
    const Activity(
      id: 'act1',
      schoolId: 'school-1',
      name: 'Shalat Subuh Berjamaah',
      type: ActivityType.daily,
      description: 'Wajib hadir di masjid sebelum iqamah.',
    ),
    const Activity(
      id: 'act2',
      schoolId: 'school-1',
      name: 'Mengaji Kitab Pagi',
      type: ActivityType.daily,
      description: 'Membaca kitab kuning sesuai kelas.',
    ),
    const Activity(
      id: 'act3',
      schoolId: 'school-1',
      name: 'Shalat Isya Berjamaah',
      type: ActivityType.daily,
    ),
    // Rutinan (Weekly)
    const Activity(
      id: 'act4',
      schoolId: 'school-1',
      name: 'Rotibul Haddad',
      type: ActivityType.rutinan,
      description: 'Setiap malam Jumat.',
    ),
    const Activity(
      id: 'act5',
      schoolId: 'school-1',
      name: 'Roan Akbar',
      type: ActivityType.rutinan,
      description: 'Kerja bakti setiap hari Minggu pagi.',
    ),
    // Level Specific
    const Activity(
      id: 'act6',
      schoolId: 'school-1',
      levelId: 'level-high', // Mock Level ID
      name: 'Pendalaman Materi Fiqih',
      type: ActivityType.daily,
      description: 'Khusus tingkat Ulya/Aliyah.',
    ),
  ];

  // Mock 'ActivityAttendances' Table
  final List<ActivityAttendance> _mockAttendances = [
    // Yesterday: Subuh (Present)
    ActivityAttendance(
      id: 'att1',
      activityId: 'act1',
      studentId: 'student-1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: AttendanceStatus.present,
    ),
    // Today: Subuh (Late)
    ActivityAttendance(
      id: 'att2',
      activityId: 'act1',
      studentId: 'student-1',
      date: DateTime.now(),
      status: AttendanceStatus.late,
      remarks: 'Bangun kesiangan dikit.',
    ),
    // Today: Mengaji Pagi (Present)
    ActivityAttendance(
      id: 'att3',
      activityId: 'act2',
      studentId: 'student-1',
      date: DateTime.now(),
      status: AttendanceStatus.present,
    ),
    // Today: Shalat Isya (Absent - example future/not recorded yet or absent)
    // Let's assume we fetch data. If no record, it's 'pending/not recorded'.
  ];

  /// Simulates fetching activities for a student on a specific date.
  ///
  /// Logic:
  /// 1. Get definitions suitable for student (level check).
  /// 2. Filter definitions by type (optional).
  /// 3. Find attendance records for (student + date + activity).
  /// 4. Merge.
  Future<List<ActivityWithStatus>> getStudentActivities({
    required String studentId,
    required String? levelId,
    required DateTime date,
    ActivityType? type, // null for 'Semua'
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Sim network

    // 1. Filter Definitions
    final availableActivities = _mockActivities.where((act) {
      // Level Check: Null means all levels. If set, must match student's level.
      final matchesLevel = act.levelId == null || act.levelId == levelId;

      // Type Check
      final matchesType = type == null || act.type == type;

      return matchesLevel && matchesType;
    }).toList();

    // 2. Map Status
    final List<ActivityWithStatus> results = availableActivities.map((
      activity,
    ) {
      final attendance = _mockAttendances.firstWhere(
        (att) =>
            att.activityId == activity.id &&
            att.studentId == studentId &&
            isSameDate(att.date, date),
        orElse: () => ActivityAttendance(
          // Return a dummy or handle null
          id: 'temp',
          activityId: activity.id,
          studentId: studentId,
          date: date,
          status: AttendanceStatus.pending,
        ),
      );

      // If ID is 'temp', it means no record found => Pending/Belum Dicatat
      return ActivityWithStatus(
        activity: activity,
        attendance: attendance.id == 'temp' ? null : attendance,
      );
    }).toList();

    return results;
  }

  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
