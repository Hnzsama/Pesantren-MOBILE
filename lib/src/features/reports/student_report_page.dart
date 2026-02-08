import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/reports/models/report_models.dart';
import 'package:pesantren_mobile/src/features/reports/service/report_service.dart';
import 'package:pesantren_mobile/src/shared/animations/scale_button.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentReportPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack;

  const StudentReportPage({super.key, required this.activeSantri, this.onBack});

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
  bool _isDownloading = false;
  String? _filterError;
  String? _reportError;
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
    setState(() {
      _isLoadingFilters = true;
      _filterError = null;
    });
    try {
      final years = await _service.getAcademicFilters();
      if (mounted) {
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
          _updateSemesters(_selectedYear!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _filterError = ErrorHandler.getErrorMessage(e);
          _isLoadingFilters = false;
        });
      }
    }
  }

  void _updateSemesters(AcademicYear year) {
    setState(() {
      _semesters = year.semesters;
      // Default to first semester available
      _selectedSemester = _semesters.firstOrNull;
    });

    if (_selectedSemester != null) {
      _loadReport();
    } else {
      setState(() {
        _report = null;
        _reportError = null;
      });
    }
  }

  Future<void> _loadReport() async {
    if (_selectedSemester == null) return;

    setState(() {
      _isLoadingReport = true;
      _reportError = null;
    });
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
      if (mounted) {
        setState(() {
          _reportError = ErrorHandler.getErrorMessage(e);
          _isLoadingReport = false;
        });
      }
    }
  }

  void _onYearChanged(AcademicYear? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
        _selectedSemester = null; // Reset semester
        _report = null;
      });
      _updateSemesters(year);
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

  Future<void> _downloadReport() async {
    // Extra safety check for the report instance
    final reportToken = _report;
    if (reportToken == null || reportToken.fileUrls.isEmpty) {
      debugPrint("No files available for download");
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final baseUrlRaw = dotenv.env['APP_URL'] ?? '';
      final baseUri = Uri.parse(baseUrlRaw);
      final rootUri = Uri(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.port,
      );

      if (kIsWeb) {
        // Web Implementation: Open URLs in new tabs
        for (var urlString in _report!.fileUrls) {
          Uri finalUri;
          if (urlString.startsWith('http')) {
            finalUri = Uri.parse(urlString);
          } else {
            finalUri = rootUri.resolve(urlString);
          }

          if (await canLaunchUrl(finalUri)) {
            await launchUrl(finalUri, mode: LaunchMode.externalApplication);
          }
        }
        if (mounted) setState(() => _isDownloading = false);
        return;
      }

      // Mobile Implementation: Download to temp and share
      List<XFile> downloadedFiles = [];

      for (int i = 0; i < _report!.fileUrls.length; i++) {
        var urlString = _report!.fileUrls[i];

        Uri finalUri;
        if (urlString.startsWith('http')) {
          finalUri = Uri.parse(urlString);
        } else {
          finalUri = rootUri.resolve(urlString);
        }

        debugPrint("Downloading page ${i + 1} from: ${finalUri.toString()}");

        final response = await http.get(finalUri);

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          // Resolve extension
          String extension = '.pdf';
          final path = finalUri.path.toLowerCase();
          if (path.endsWith('.webp'))
            extension = '.webp';
          else if (path.endsWith('.png'))
            extension = '.png';
          else if (path.endsWith('.jpg'))
            extension = '.jpg';
          else if (path.endsWith('.jpeg'))
            extension = '.jpeg';

          final fileName =
              "Rapor_${widget.activeSantri.nama.replaceAll(' ', '_')}_${_selectedYear?.name.replaceAll('/', '-')}_${_selectedSemester?.type == SemesterType.GANJIL ? 'Ganjil' : 'Genap'}_Hal${i + 1}$extension";

          final tempDir = await getTemporaryDirectory();
          final file = io.File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          downloadedFiles.add(XFile(file.path));
        } else {
          debugPrint(
            "Failed to download page ${i + 1}: ${response.statusCode}",
          );
        }
      }

      if (mounted) {
        setState(() => _isDownloading = false);

        if (downloadedFiles.isNotEmpty) {
          await Share.shareXFiles(
            downloadedFiles,
            subject: 'Unduh Rapor ${widget.activeSantri.nama}',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Gagal mengunduh file rapor. Silakan coba lagi nanti.",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Download error: $e");
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Terjadi kesalahan: ${ErrorHandler.getErrorMessage(e)}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fixed Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.40,
              child: Image.asset('assets/background.jpeg', fit: BoxFit.cover),
            ),
          ),

          // 2. Main Content
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 160,
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
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 24,
                            right: 24,
                            bottom: 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
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
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadFilters,
                    ),
                  ],
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
            body: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingFilters) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filterError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _filterError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadFilters,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Filters Section
          _buildFilters(),

          const SizedBox(height: 24),

          // 2. Report Content
          if (_isLoadingReport)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reportError != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _reportError!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadReport,
                    child: const Text(
                      "Gagal memuat rapor, klik untuk mencoba lagi",
                    ),
                  ),
                ],
              ),
            )
          else
            _buildReportArea(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              onPressed: _isDownloading ? null : _downloadReport,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isDownloading ? "MENGUNDUH..." : "UNDUH RAPOR"),
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
