import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/activities/models/activity_model.dart';
import 'package:pesantren_mobile/src/features/activities/service/activity_service.dart';
import 'package:pesantren_mobile/src/features/activities/widgets/activity_card.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _service = ActivityService();

  // State
  DateTime _selectedDate = DateTime.now();
  ActivityType? _selectedType; // null means 'Semua'

  // Future
  late Future<List<ActivityWithStatus>> _activitiesFuture;

  // Mock Student Context (Ensure this matches your App's Auth State in real app)
  final String _studentId = 'student-1';
  final String _studentLevel =
      'level-high'; // or 'level-low', or anything matching mock

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _activitiesFuture = _service.getStudentActivities(
        studentId: _studentId,
        levelId: _studentLevel,
        date: _selectedDate,
        type: _selectedType,
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // bgEmerald50 equivalent
      appBar: AppBar(
        title: const Text("Aktivitas"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildLegend(),
          Expanded(child: _buildActivityList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Build Type Selector (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Semua", null),
                const SizedBox(width: 8),
                _buildFilterChip("Harian", ActivityType.daily),
                const SizedBox(width: 8),
                _buildFilterChip("Rutinan", ActivityType.rutinan),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Date Selector
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(_selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ActivityType? type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
          });
          _fetchData();
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[100],
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(Colors.green, "Hadir"),
          _legendItem(Colors.orange, "Terlambat"),
          _legendItem(Colors.red, "Absen"),
          _legendItem(Colors.blue, "Izin"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActivityList() {
    return FutureBuilder<List<ActivityWithStatus>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Belum ada aktivitas untuk tanggal ini",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final item = activities[index];
            return ActivityCard(
              item: item,
              onTap: () => _showDetailModal(context, item),
            );
          },
        );
      },
    );
  }

  void _showDetailModal(BuildContext context, ActivityWithStatus item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow it to be taller if content needs
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.activity.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, d MMMM yyyy (HH:mm)', 'id_ID').format(
                  // Use attendance date if exists, else selected date
                  item.attendance?.date ?? _selectedDate,
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              const Text(
                "Deskripsi:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(item.activity.description ?? "Tidak ada deskripsi."),

              const SizedBox(height: 16),
              const Text(
                "Status Kehadiran:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusText(item.status),
                style: const TextStyle(fontSize: 16),
              ),

              if (item.attendance?.remarks != null) ...[
                const SizedBox(height: 16),
                const Text(
                  "Catatan:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade200),
                  ),
                  child: Text(item.attendance!.remarks!),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return "Hadir";
      case AttendanceStatus.late:
        return "Terlambat";
      case AttendanceStatus.absent:
        return "Tidak Hadir";
      case AttendanceStatus.permission:
        return "Izin";
      default:
        return "Belum Dicatat";
    }
  }
}
