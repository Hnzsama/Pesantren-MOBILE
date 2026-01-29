import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/shared/animations/scale_button.dart';

class BillCard extends StatelessWidget {
  final StudentBill bill;
  final VoidCallback? onPay;
  final VoidCallback? onPrint;

  const BillCard({super.key, required this.bill, this.onPay, this.onPrint});

  @override
  Widget build(BuildContext context) {
    // 1. Logic: Cancelled vs Active
    final isCancelled = bill.status == BillStatus.CANCELLED;
    final isPaid = bill.status == BillStatus.PAID;

    // Muted color scheme for cancelled
    final cardColor = isCancelled
        ? Colors.grey.shade100
        : const Color(0xFFE8F5E9); // Mint/Sage Green
    final textColor = isCancelled ? Colors.grey : AppColors.textPrimary;
    final labelColor = isCancelled ? Colors.grey : AppColors.primary;
    final borderColor = isCancelled
        ? Colors.grey.shade300
        : Colors.transparent; // Remove border for clean look

    // 2. Display Logic
    final displayDate = bill.displayDate;
    final dateLabel = bill.isEventBill ? "Tanggal Event" : "Jatuh Tempo";
    final formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(displayDate);

    // 3. Status Badge Config
    Color badgeColor;
    String badgeText;
    Color badgeTextColor;

    switch (bill.status) {
      case BillStatus.PAID:
        badgeColor = const Color(0xFFD1FAE5); // Emerald 100
        badgeTextColor = const Color(0xFF065F46); // Emerald 800
        badgeText = "LUNAS";
        break;
      case BillStatus.UNPAID:
        badgeColor = const Color(0xFFFFEDD5); // Orange 100
        badgeTextColor = const Color(0xFF9A3412); // Orange 800
        badgeText = "BELUM BAYAR";
        break;
      case BillStatus.CANCELLED:
        badgeColor = Colors.grey.shade200;
        badgeTextColor = Colors.grey.shade600;
        badgeText = "DIBATALKAN";
        break;
    }

    return ScaleButton(
      onTap: (isCancelled || isPaid) ? null : onPay,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          // Match StudentIdCard Gradient for active/unpaid/paid bills coverage
          gradient: isCancelled
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFE8F5E9),
                    const Color(0xFFA5D6A7), // Darker end for volume
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
          color: isCancelled ? cardColor : null,
          borderRadius: BorderRadius.circular(20), // More rounded
          border: Border.all(color: borderColor),
          boxShadow: isCancelled
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Top Section: Label & Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Label (Event or Category)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: labelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bill.displayLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                          ),
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main Title (Event Title or Bill Title)
                  Text(
                    bill.isEventBill && bill.event != null
                        ? bill.event!.title
                        : bill.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Amount
                  // Amount Section
                  if (isPaid) ...[
                    const SizedBox(height: 4),
                    _buildSummaryRow("Tagihan", bill.formattedAmount),
                    if (bill.adminFee > 0)
                      _buildSummaryRow(
                        "Biaya Aplikasi",
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(bill.adminFee),
                      ),
                    if (bill.paymentFee > 0)
                      _buildSummaryRow(
                        "Biaya Layanan",
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(bill.paymentFee),
                      ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(
                            bill.amount + bill.adminFee + bill.paymentFee,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      bill.formattedAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isCancelled
                            ? Colors.grey
                            : AppColors.textPrimary,
                        fontFamily: 'Courier',
                      ),
                    ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, color: borderColor),

            // Bottom Section: Date & CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: isCancelled
                              ? Colors.grey.shade400
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: isCancelled
                                ? Colors.grey
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Logic used: Only show "Bayar" if UNPAID and NOT Cancelled
                  if (bill.status == BillStatus.UNPAID)
                    ElevatedButton(
                      onPressed: onPay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Bayar Sekarang",
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  else if (bill.status == BillStatus.PAID)
                    Row(
                      children: [
                        if (onPrint != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: onPrint,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.print,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Struk",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF065F46),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Lunas",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
