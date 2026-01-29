import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/features/payment/pages/payment_webview_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() => _instance;

  PaymentService._internal();

  /// Start payment using WebView (fallback solution)
  /// This bypasses the native SDK which has Activity binding issues
  Future<bool?> startPayment(BuildContext context, String snapToken) async {
    print("[PaymentService] Starting payment. Web: $kIsWeb");
    print("[PaymentService] Snap Token: $snapToken");

    if (kIsWeb) {
      // Snap Redirect URL for Sandbox
      // Note: In production, this should be 'https://app.midtrans.com/snap/v2/vtweb/$snapToken'
      // You should probably check environment variables or config
      // For now using Sandbox URL as per development context
      final url = Uri.parse(
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken',
      );

      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          // On Web, we can't easily wait for the result from a new tab
          // So we return true to indicate the payment page was opened.
          return true;
        } else {
          print("Could not launch $url");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka halaman pembayaran'),
            ),
          );
          return false;
        }
      } catch (e) {
        print("Error launching URL: $e");
        return false;
      }
    }

    try {
      // Navigate to WebView payment page
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebviewPage(snapToken: snapToken),
        ),
      );

      if (result == true) {
        print("[PaymentService] Payment completed successfully");
      } else if (result == false) {
        print("[PaymentService] Payment failed or cancelled");
      } else {
        print("[PaymentService] Payment result unknown or user went back");
      }

      return result;
    } catch (e) {
      print("[PaymentService] Error during payment: $e");
      rethrow;
    }
  }

  /// Kept for API compatibility, but callbacks are handled via URL navigation in WebView
  void setCallback({required Function(dynamic) onTransactionFinished}) {
    // WebView implementation handles callbacks via URL navigation
    print("[PaymentService] Callback registration not needed for WebView");
  }
}
