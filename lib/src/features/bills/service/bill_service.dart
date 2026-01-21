import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';

class BillService {
  // Mock Data
  static final BillCategory _sppCategory = BillCategory(
    id: 'cat_01',
    name: 'SPP',
    description: 'Sumbangan Pembinaan Pendidikan',
  );

  static final BillCategory _registrationCategory = BillCategory(
    id: 'cat_02',
    name: 'Pendaftaran Ulang',
  );

  static final BillCategory _otherCategory = BillCategory(
    id: 'cat_03',
    name: 'Lainnya',
  );

  static final BillEvent _studyTourEvent = BillEvent(
    id: 'evt_01',
    title: 'Ziarah Wali Songo',
    eventDate: DateTime.now().add(const Duration(days: 14)),
    amount: 1500000,
  );

  Future<List<StudentBill>> getBills(String santriId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock response based on santri ID to test switching
    // In real app, this would filter by student_id from DB

    final List<StudentBill> allBills = [
      // 1. Unpaid Monthly SPP (Regular)
      StudentBill(
        id: 'bill_001',
        studentId: '1',
        title: 'SPP Januari 2026',
        amount: 350000,
        status: BillStatus.UNPAID,
        dueDate: DateTime(2026, 1, 10),
        category: _sppCategory,
      ),

      // 2. Paid Registration (Regular)
      StudentBill(
        id: 'bill_002',
        studentId: '1',
        title: 'Daftar Ulang Semester Genap',
        amount: 1000000,
        status: BillStatus.PAID,
        dueDate: DateTime(2025, 12, 20),
        paidAt: DateTime(2025, 12, 19),
        category: _registrationCategory,
      ),

      // 3. Unpaid Event Bill (Shows Event Title)
      StudentBill(
        id: 'bill_003',
        studentId: '1',
        title: 'Biaya Transportasi & Akomodasi', // Title of the bill
        amount: 1500000,
        status: BillStatus.UNPAID,
        dueDate: DateTime(
          2026,
          2,
          1,
        ), // Should use eventDate for display if event bill
        event: _studyTourEvent,
        // Even if category is present, UI should prioritize event label
        category: _otherCategory,
      ),

      // 4. Cancelled Bill (Cancelled by Admin)
      StudentBill(
        id: 'bill_004',
        studentId: '1',
        title: 'Tagihan Salah Input',
        amount: 50000,
        status: BillStatus.CANCELLED,
        dueDate: DateTime(2026, 1, 15),
        category: _otherCategory,
      ),

      // 5. Another Paid SPP (for history)
      StudentBill(
        id: 'bill_005',
        studentId: '1',
        title: 'SPP Desember 2025',
        amount: 350000,
        status: BillStatus.PAID,
        dueDate: DateTime(2025, 12, 10),
        paidAt: DateTime(2025, 12, 5),
        category: _sppCategory,
      ),
    ];

    // For testing santri switch, we can return empty or different list
    if (santriId == '2') {
      return [
        StudentBill(
          id: 'bill_006',
          studentId: '2',
          title: 'SPP Januari 2026',
          amount: 350000,
          status: BillStatus.UNPAID,
          dueDate: DateTime(2026, 1, 10),
          category: _sppCategory,
        ),
      ];
    }

    return allBills;
  }
}
