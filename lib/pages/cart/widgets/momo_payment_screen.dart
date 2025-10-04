import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;

class MoMoPaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const MoMoPaymentScreen({
    Key? key,
    required this.paymentUrl,
  }) : super(key: key);

  @override
  State<MoMoPaymentScreen> createState() => _MoMoPaymentScreenState();
}

class _MoMoPaymentScreenState extends State<MoMoPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      developer.log('Invalid payment URL: ${widget.paymentUrl}',
          name: 'MoMoPayment');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBarSafely('URL thanh toán không hợp lệ', Colors.red);
        Navigator.of(context).pop();
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            developer.log('WebView loading progress: $progress%',
                name: 'MoMoPayment');
          },
          onPageStarted: (String url) {
            developer.log('WebView page started: $url', name: 'MoMoPayment');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            developer.log('WebView page finished: $url', name: 'MoMoPayment');
            setState(() {
              _isLoading = false;
            });
            // Adjust for MoMo dev environment
            if (url.contains('result') ||
                url.contains('success') ||
                url.contains('completed')) {
              _showPaymentSuccessDialog();
            } else if (url.contains('cancel') ||
                url.contains('failed') ||
                url.contains('error')) {
              _showPaymentFailedDialog();
            }
          },
          onWebResourceError: (WebResourceError error) {
            developer.log(
              'WebView error: ${error.description}, code: ${error.errorCode}',
              name: 'MoMoPayment',
            );
            _showSnackBarSafely(
                'Lỗi tải trang: ${error.description}', Colors.red);
          },
          onNavigationRequest: (NavigationRequest request) {
            developer.log('Navigation request: ${request.url}',
                name: 'MoMoPayment');
            // Allow MoMo dev and production URLs
            if (request.url.contains('momo.vn') ||
                request.url.contains('test.momo.vn') ||
                request.url.contains('payment') ||
                request.url.contains('result') ||
                request.url.contains('success') ||
                request.url.contains('cancel') ||
                request.url.contains('error')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(uri);
  }

  void _showSnackBarSafely(String message, Color color) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thanh toán thành công'),
          content:
              const Text('Đơn hàng của bạn đã được thanh toán thành công!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thanh toán thất bại'),
          content: const Text('Thanh toán không thành công. Vui lòng thử lại.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close payment screen
              },
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán MoMo'),
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hủy thanh toán'),
                content: const Text('Bạn có chắc muốn hủy thanh toán?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Không'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Có'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1D7020),
              ),
            ),
        ],
      ),
    );
  }
}
