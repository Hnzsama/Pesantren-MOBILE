import 'package:pesantren_mobile/src/features/reports/models/report_models.dart';

class ReportService {
  // Mock Data
  static final List<AcademicYear> _years = [
    const AcademicYear(id: 'y1', name: '2025/2026', isActive: true),
    const AcademicYear(id: 'y2', name: '2024/2025', isActive: false),
    const AcademicYear(id: 'y3', name: '2023/2024', isActive: false),
  ];

  static final List<Semester> _semesters = [
    // 2025/2026
    const Semester(
      id: 's1_odd',
      academicYearId: 'y1',
      type: SemesterType.GANJIL,
    ),
    const Semester(
      id: 's1_even',
      academicYearId: 'y1',
      type: SemesterType.GENAP,
    ),
    // 2024/2025
    const Semester(
      id: 's2_odd',
      academicYearId: 'y2',
      type: SemesterType.GANJIL,
    ),
    const Semester(
      id: 's2_even',
      academicYearId: 'y2',
      type: SemesterType.GENAP,
    ),
    // 2023/2024
    const Semester(
      id: 's3_odd',
      academicYearId: 'y3',
      type: SemesterType.GANJIL,
    ),
    const Semester(
      id: 's3_even',
      academicYearId: 'y3',
      type: SemesterType.GENAP,
    ),
  ];

  static final List<StudentReport> _reports = [
    // Ahmad Fulan (id: 1) has specific reports
    const StudentReport(
      id: 'r1',
      studentId: '1',
      semesterId: 's2_odd',
      filePath: 'https://example.com/report1.pdf',
    ),
    const StudentReport(
      id: 'r2',
      studentId: '1',
      semesterId: 's2_even',
      filePath: 'https://example.com/report2.pdf',
    ),
    // 2025/2026 Odd is not yet uploaded
  ];

  Future<List<AcademicYear>> getAcademicYears() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _years;
  }

  Future<List<Semester>> getSemesters(String yearId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _semesters.where((s) => s.academicYearId == yearId).toList();
  }

  Future<StudentReport?> getReport(String studentId, String semesterId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      return _reports.firstWhere(
        (r) => r.studentId == studentId && r.semesterId == semesterId,
      );
    } catch (e) {
      return null;
    }
  }
}
