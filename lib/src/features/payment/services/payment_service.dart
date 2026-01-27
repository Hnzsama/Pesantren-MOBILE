import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/features/payment/pages/payment_webview_page.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() => _instance;

  PaymentService._internal();

  /// Start payment using WebView (fallback solution)
  /// This bypasses the native SDK which has Activity binding issues
  Future<bool?> startPayment(BuildContext context, String snapToken) async {
    print("[PaymentService] Starting payment with WebView");
    print("[PaymentService] Snap Token: $snapToken");

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
