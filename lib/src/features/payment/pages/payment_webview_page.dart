import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';

class PaymentWebviewPage extends StatefulWidget {
  final String snapToken;

  const PaymentWebviewPage({super.key, required this.snapToken});

  @override
  State<PaymentWebviewPage> createState() => _PaymentWebviewPageState();
}

class _PaymentWebviewPageState extends State<PaymentWebviewPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Delay WebView initialization until after the first frame
    // This ensures the platform channel is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  void _initializeWebView() {
    if (_isInitialized) return;

    // Construct the Snap Redirect URL with QRIS QR mode
    // According to Midtrans docs, use ?uiMode=qr to force QR code display
    final url =
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}?uiMode=qr';

    print('[PaymentWebview] Initializing WebView...');
    print('[PaymentWebview] Loading URL: $url');
    print('[PaymentWebview] Snap Token: ${widget.snapToken}');

    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('[PaymentWebview] Page started: $url');
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
              }
            },
            onPageFinished: (String url) {
              print('[PaymentWebview] Page finished: $url');
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('[PaymentWebview] WebResource Error: ${error.description}');
              print('[PaymentWebview] Error Code: ${error.errorCode}');
              print('[PaymentWebview] Error Type: ${error.errorType}');

              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage =
                      'Error loading payment page: ${error.description}';
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              print('[PaymentWebview] Navigation request: ${request.url}');

              // Handle success callbacks
              if (request.url.contains('finish') ||
                  request.url.contains('status_code=200') ||
                  request.url.contains('transaction_status=settlement')) {
                print('[PaymentWebview] Payment SUCCESS detected');
                if (mounted) Navigator.pop(context, true);
                return NavigationDecision.prevent;
              }

              // Handle failure callbacks
              if (request.url.contains('error') ||
                  request.url.contains('failed')) {
                print('[PaymentWebview] Payment FAILED detected');
                if (mounted) Navigator.pop(context, false);
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        );

      // Load the URL
      controller.loadRequest(Uri.parse(url));

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

      print('[PaymentWebview] WebView initialized successfully');
    } catch (e) {
      print('[PaymentWebview] Error initializing WebView: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize payment: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_controller != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final url =
                    'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}?uiMode=qr';
                _controller!.loadRequest(Uri.parse(url));
              },
              tooltip: 'Reload',
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage == null && _controller != null)
            WebViewWidget(controller: _controller!)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isInitialized = false;
                        });
                        _initializeWebView();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading && _errorMessage == null)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
