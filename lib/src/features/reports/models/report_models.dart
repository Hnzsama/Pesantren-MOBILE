// ignore_for_file: constant_identifier_names

class AcademicYear {
  final String id;
  final String name; // e.g. "2024/2025"
  final bool isActive;

  const AcademicYear({
    required this.id,
    required this.name,
    required this.isActive,
  });
}

enum SemesterType { GANJIL, GENAP }

class Semester {
  final String id;
  final String academicYearId;
  final SemesterType type;

  const Semester({
    required this.id,
    required this.academicYearId,
    required this.type,
  });

  String get label =>
      type == SemesterType.GANJIL ? "Semester Ganjil" : "Semester Genap";
}

class StudentReport {
  final String id;
  final String studentId;
  final String semesterId;
  final String?
  filePath; // Nullable if not yet uploaded? Schema says 'file_path', typically non-nullable but logic says "Belum Tersedia"
  // Actually schema says `file_path` is string, presumably required for the row to exist.
  // But for the UI "Status: Belum Tersedia", we might return null if no record exists.
  // We'll define the model as having the path, and the Service will return null if no report found.

  const StudentReport({
    required this.id,
    required this.studentId,
    required this.semesterId,
    this.filePath,
  });
}
