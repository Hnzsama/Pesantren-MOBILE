import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';

class PaymentSuccessPage extends StatefulWidget {
  final TransactionModel transaction;
  final String? studentName;

  const PaymentSuccessPage({
    super.key,
    required this.transaction,
    this.studentName,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isGeneratingPdf = false;

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    // Load Logo
    final logoImage = await imageFromAssetBundle('assets/logo_sandigi.png');
    // Using simple text checkmark for now to avoid needing another asset,
    // or draw a shape. Let's draw a shape.

    final trx = widget.transaction;

    // Formatters
    final dateFormat = DateFormat('dd MMMM yyyy | HH:mm', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Color Palette
    final primaryColor = PdfColor.fromInt(0xFF005697); // Bank Blue
    final white = PdfColors.white;

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat(
            80 * PdfPageFormat.mm,
            double.infinity,
            marginAll: 0,
          ),
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        ),
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              children: [
                // --- Header ---
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 20, bottom: 30),
                  decoration: pw.BoxDecoration(color: primaryColor),
                  child: pw.Column(
                    children: [
                      // Checkmark Circle
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green400,
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: white, width: 2),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            "✓",
                            style: pw.TextStyle(
                              color: white,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      // Logo
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Image(logoImage, width: 20, height: 20),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            "PESANTREN MOBILE",
                            style: pw.TextStyle(
                              color: white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "TRANSAKSI BERHASIL",
                        style: pw.TextStyle(
                          color: PdfColors.lightGreenAccent,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        dateFormat.format(trx.createdAt),
                        style: pw.TextStyle(color: white, fontSize: 8),
                      ),
                    ],
                  ),
                ),

                // --- Body Card Effect ---
                pw.Transform.translate(
                  offset: const PdfPoint(0, -10),
                  child: pw.Container(
                    margin: const pw.EdgeInsets.symmetric(horizontal: 10),
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: white,
                      borderRadius: pw.BorderRadius.circular(8),
                      // No shadow support in PDF explicitly simple, but white box on white bg needs border or contrast
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildRow(
                          "Jenis Pembayaran",
                          trx.category == 'TOPUP'
                              ? 'Isi Uang Saku'
                              : 'Pembayaran Tagihan',
                        ),
                        pw.SizedBox(height: 8),
                        _buildRow(
                          "Metode Pembayaran",
                          trx.paymentMethod.toUpperCase(),
                        ),
                        pw.SizedBox(height: 8),
                        _buildRow(
                          "Nama Santri",
                          widget.studentName ?? "Nama Santri",
                        ),
                        // NEW: Event Details for PDF
                        if (trx.eventName != null) ...[
                          pw.SizedBox(height: 8),
                          _buildRow("Nama Event", trx.eventName!),
                          pw.SizedBox(height: 8),
                          _buildRow(
                            "Tanggal Pelaksanaan",
                            dateFormat.format(trx.eventDate ?? DateTime.now()),
                          ),
                        ],

                        pw.SizedBox(height: 12),
                        pw.Divider(
                          borderStyle: pw.BorderStyle.dashed,
                          color: PdfColors.grey300,
                        ),
                        pw.SizedBox(height: 12),

                        _buildRow(
                          "No. Referensi",
                          trx.invoiceCode.isNotEmpty
                              ? trx.invoiceCode
                              : trx.id.substring(0, 10).toUpperCase(),
                        ),
                        pw.SizedBox(height: 8),
                        _buildRow(
                          "Status",
                          "LUNAS",
                          isBold: true,
                          valueColor: PdfColors.green700,
                        ),

                        pw.SizedBox(height: 12),
                        pw.Divider(
                          borderStyle: pw.BorderStyle.dashed,
                          color: PdfColors.grey300,
                        ),
                        pw.SizedBox(height: 12),

                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Nominal",
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(trx.amount),
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Biaya Aplikasi",
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(trx.adminFee),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Biaya Layanan",
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(trx.paymentFee),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),

                        pw.SizedBox(height: 8),
                        pw.Divider(color: PdfColors.grey300),
                        pw.SizedBox(height: 8),

                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "TOTAL BAYAR",
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(trx.grossAmount),
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Terima Kasih",
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  "Simpan struk ini sebagai bukti transaksi",
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey500,
                  ),
                ),
                pw.SizedBox(height: 20),
                // Bottom Bar
                pw.Container(
                  height: 5,
                  color: primaryColor,
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.Flexible(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? PdfColors.black,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  Future<void> _printOrShare() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await Printing.sharePdf(
        bytes: await _generatePdf(PdfPageFormat.roll80),
        filename: 'struk-${widget.transaction.invoiceCode}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal membagikan struk: $e")));
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pembayaran Berhasil!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Transaksi Anda telah berhasil diproses",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Transaction Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      "Tanggal",
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(widget.transaction.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow("Metode", widget.transaction.paymentMethod),
                    // NEW: Event Details
                    if (widget.transaction.eventName != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Nama Event",
                        widget.transaction.eventName!,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Tanggal Pelaksanaan",
                        DateFormat('d MMMM yyyy', 'id_ID').format(
                          widget.transaction.eventDate ?? DateTime.now(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      "Nominal Topup",
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.transaction.amount),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      "Biaya Aplikasi",
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.transaction.adminFee),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      "Biaya Layanan",
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.transaction.paymentFee),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      "Total Bayar",
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.transaction.grossAmount),
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Helper Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text("Beranda"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPdf ? null : _printOrShare,
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print, color: Colors.white),
                      label: Text(
                        _isGeneratingPdf ? "Memproses..." : "Cetak Struk",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
