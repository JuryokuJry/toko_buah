import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentPage({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Inisialisasi WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('success-redirect-url')) {
              // Redirect sukses atau pembayaran berhasil
              Navigator.pop(context);
              _clearCart(); // Kosongkan keranjang setelah pembayaran sukses
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  // Fungsi untuk membersihkan keranjang setelah pembayaran
  void _clearCart() {
    // Anda dapat menambahkan logika untuk mengosongkan keranjang atau memperbarui status.
    print("Keranjang telah dikosongkan setelah pembayaran.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
