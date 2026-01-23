import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/reports/models/report_models.dart';
import 'package:pesantren_mobile/src/features/reports/service/report_service.dart';
import 'package:pesantren_mobile/src/shared/animations/scale_button.dart';

class StudentReportPage extends StatefulWidget {
  final SantriModel activeSantri;

  const StudentReportPage({super.key, required this.activeSantri});

  @override
  State<StudentReportPage> createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage> {
  final ReportService _service = ReportService();

  // Data Sources
  List<AcademicYear> _years = [];
  List<Semester> _semesters = [];

  // Selections
  AcademicYear? _selectedYear;
  Semester? _selectedSemester;

  // Async State
  bool _isLoadingFilters = true;
  bool _isLoadingReport = false;
  StudentReport? _report;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  @override
  void didUpdateWidget(covariant StudentReportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSantri.id != widget.activeSantri.id) {
      _loadReport(); // Reload report for new student with current filter
    }
  }

  Future<void> _loadFilters() async {
    try {
      final years = await _service.getAcademicYears();
      setState(() {
        _years = years;
        // Default to active year or first
        _selectedYear = years.firstWhere(
          (y) => y.isActive,
          orElse: () => years.first,
        );
        _isLoadingFilters = false;
      });

      if (_selectedYear != null) {
        await _loadSemesters(_selectedYear!.id);
      }
    } catch (e) {
      // Handle error
      if (mounted) setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _loadSemesters(String yearId) async {
    // When year changes, load semesters
    setState(() => _isLoadingReport = true); // Block UI while changing context
    try {
      final semesters = await _service.getSemesters(yearId);
      setState(() {
        _semesters = semesters;
        // Default to Ganjil (ODD) usually comes first, or first available
        _selectedSemester = semesters.firstOrNull;
      });

      _loadReport();
    } catch (e) {
      if (mounted) setState(() => _isLoadingReport = false);
    }
  }

  Future<void> _loadReport() async {
    if (_selectedSemester == null) return;

    setState(() => _isLoadingReport = true);
    try {
      final report = await _service.getReport(
        widget.activeSantri.id,
        _selectedSemester!.id,
      );
      if (mounted) {
        setState(() {
          _report = report;
          _isLoadingReport = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReport = false);
    }
  }

  void _onYearChanged(AcademicYear? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
        _selectedSemester = null; // Reset semester
        _report = null;
      });
      _loadSemesters(year.id);
    }
  }

  void _onSemesterChanged(Semester semester) {
    if (semester != _selectedSemester) {
      setState(() {
        _selectedSemester = semester;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgEmerald50 = Color(0xFFECFDF5);

    return Scaffold(
      backgroundColor: bgEmerald50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180, // Consistent with Achievements
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Rapor Santri",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.activeSantri.nama,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                radius: 24,
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Laporan Hasil Belajar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ];
        },
        body: _isLoadingFilters
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Filters Section
                    _buildFilters(),

                    const SizedBox(height: 24),

                    // 2. Report Content
                    _isLoadingReport
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _buildReportArea(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tahun Ajaran",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AcademicYear>(
                value: _selectedYear,
                isExpanded: true,
                items: _years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(
                      year.name + (year.isActive ? " (Aktif)" : ""),
                      style: TextStyle(
                        fontWeight: year.isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _onYearChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Semester",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Segmented Control Style
          Row(
            children: _semesters.map((sem) {
              final isSelected = _selectedSemester?.id == sem.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ScaleButton(
                    onTap: () => _onSemesterChanged(sem),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sem.type == SemesterType.GANJIL ? "GANJIL" : "GENAP",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_semesters.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "Tidak ada semester untuk tahun ini",
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportArea() {
    if (_report == null) {
      // Empty State
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.description_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Rapor belum tersedia",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Untuk Semester ${_selectedSemester?.type == SemesterType.GANJIL ? 'Ganjil' : 'Genap'} T.A ${_selectedYear?.name}",
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Report Available Card
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.task_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            "Rapor Tersedia",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _infoRow("Nama", widget.activeSantri.nama),
          _infoRow("Tahun Ajaran", _selectedYear?.name ?? "-"),
          _infoRow(
            "Semester",
            _selectedSemester?.type == SemesterType.GANJIL ? "Ganjil" : "Genap",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: View PDF logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mengunduh Rapor...")),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text("LIHAT RAPOR"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
