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

    // Colors
    final cardColor = Colors.white;
    final textColor = isCancelled ? Colors.grey : AppColors.textPrimary;

    // 2. Display Logic
    final displayDate = bill.displayDate;
    // Removed unused dateLabel
    final formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(displayDate);

    // 3. Status Badge Config
    Color badgeColor;
    String badgeText;
    Color badgeTextColor;
    IconData badgeIcon;

    switch (bill.status) {
      case BillStatus.PAID:
        badgeColor = const Color(0xFFD1FAE5); // Emerald 100
        badgeTextColor = const Color(0xFF065F46); // Emerald 800
        badgeText = "LUNAS";
        badgeIcon = Icons.check_circle;
        break;
      case BillStatus.UNPAID:
        badgeColor = const Color(0xFFFFEDD5); // Orange 100
        badgeTextColor = const Color(0xFF9A3412); // Orange 800
        badgeText = "BELUM BAYAR";
        badgeIcon = Icons.access_time_filled;
        break;
      case BillStatus.CANCELLED:
        badgeColor = Colors.grey.shade200;
        badgeTextColor = Colors.grey.shade600;
        badgeText = "BATAL";
        badgeIcon = Icons.cancel;
        break;
    }

    return ScaleButton(
      onTap: (isCancelled) ? null : (isPaid ? onPrint : onPay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24), // Rounded 24
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Subtle shadow
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20), // Increased padding
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label (Category/Event)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            bill.displayLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          bill.isEventBill && bill.event != null
                              ? bill.event!.title
                              : bill.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Side: Status & Amount (if concise) or just Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor),
                    ),
                    child: Row(
                      children: [
                        Icon(badgeIcon, size: 14, color: badgeTextColor),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 16),

              // Bottom Section: Amount & Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Tagihan",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bill.formattedAmount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isCancelled ? Colors.grey : AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Action Button
                  if (bill.status == BillStatus.UNPAID)
                    ElevatedButton(
                      onPressed: onPay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Bayar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (!isCancelled)
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
