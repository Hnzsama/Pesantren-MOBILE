import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/permissions/models/permission_model.dart';
import 'package:pesantren_mobile/src/features/permissions/services/permission_service.dart';
import 'package:pesantren_mobile/src/features/permissions/permission_form_page.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';

class PermissionsPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack;

  const PermissionsPage({super.key, required this.activeSantri, this.onBack});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PermissionService _permissionService = PermissionService();
  late Future<List<PermissionModel>> _permissionsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPermissions();
  }

  void _loadPermissions() {
    setState(() {
      _permissionsFuture = _permissionService.getPermissions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PermissionModel> _getFilteredPermissions(
    List<PermissionModel> allPermissions,
    int tabIndex,
  ) {
    if (tabIndex == 0) return allPermissions;
    if (tabIndex == 1) {
      return allPermissions
          .where((p) => p.status == PermissionStatus.pending)
          .toList();
    }
    if (tabIndex == 2) {
      return allPermissions
          .where((p) => p.status == PermissionStatus.approved)
          .toList();
    }
    return allPermissions
        .where((p) => p.status == PermissionStatus.rejected)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.40,
              child: Image.asset('assets/background.jpeg', fit: BoxFit.cover),
            ),
          ),

          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  expandedHeight: 300,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 40.0,
                              ), // Shift content up
                              child: Column(
                                children: [
                                  const Text(
                                    "Riwayat Perizinan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.activeSantri.nama,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Create Permission Button
                                  Material(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PermissionFormPage(
                                              activeSantri: widget.activeSantri,
                                            ),
                                          ),
                                        );

                                        // Refresh data if permission was submitted successfully
                                        if (result == true) {
                                          _loadPermissions();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Buat Izin Baru",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    centerTitle: true,
                    title:
                        const SizedBox.shrink(), // Custom title in FlexibleSpace
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80),
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white, // Tab bar bar bg
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(
                        4,
                      ), // Add padding for inner tab
                      child: TabBar(
                        controller: _tabController,
                        isScrollable:
                            false, // Make it fixed to fit width better if needed, or true
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        indicatorColor: Colors.transparent, // Hide default line
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: "Semua"),
                          Tab(text: "Menunggu"),
                          Tab(text: "Disetujui"),
                          Tab(text: "Ditolak"),
                        ],
                        onTap: (index) => setState(() {}),
                        dividerColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: FutureBuilder<List<PermissionModel>>(
              future: _permissionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPermissions,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final allPermissions = snapshot.data ?? [];

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadPermissions();
                    await _permissionsFuture;
                  },
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(4, (index) {
                      final permissions = _getFilteredPermissions(
                        allPermissions,
                        index,
                      );
                      if (permissions.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        primary: true,
                        itemCount: permissions.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          return _buildPermissionCard(permissions[i]);
                        },
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                size: 80,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Belum ada data perizinan",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(PermissionModel permission) {
    final dateFormat = DateFormat(
      'd MMM yyyy',
      'id_ID',
    ); // Ensure locale handling if available or generic
    // Fallback if locale not initialized
    String formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

    final dateRange =
        "${formatDate(permission.startDate)} - ${formatDate(permission.endDate)}";
    final duration =
        permission.endDate.difference(permission.startDate).inDays + 1;

    return GlassContainer(
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Strip
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: permission.statusColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: permission.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            permission.statusText.toUpperCase(),
                            style: TextStyle(
                              color: permission.statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          formatDate(permission.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      permission.reason,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateRange,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "($duration Hari)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (permission.adminNote != null) ...[
                      const Divider(height: 24, thickness: 0.5),
                      Text(
                        "Catatan Admin:",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        permission.adminNote!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
