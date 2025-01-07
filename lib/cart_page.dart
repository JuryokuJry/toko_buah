import 'package:flutter/material.dart';
import 'package:toko_buah/cart_item.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final void Function(CartItem item) removeFromCart;
  final void Function(CartItem item, int newQuantity) updateCart;

  const CartPage({
    Key? key,
    required this.cartItems,
    required this.removeFromCart,
    required this.updateCart,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> cartItems;

  @override
  void initState() {
    super.initState();
    _combineCartItems();
  }

  void _combineCartItems() {
    final Map<String, CartItem> uniqueItems = {};
    for (var item in widget.cartItems) {
      if (uniqueItems.containsKey(item.name)) {
        uniqueItems[item.name]!.quantity += item.quantity;
      } else {
        uniqueItems[item.name] = CartItem(
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          imageUrl: item.imageUrl,
          paymentUrl: item.paymentUrl,
        );
      }
    }
    cartItems = uniqueItems.values.toList();
  }

  void removeSingleQuantity(CartItem item, int index) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity -= 1;
        widget.updateCart(item, item.quantity);
      } else {
        widget.removeFromCart(item);
        cartItems.removeAt(index);
        widget.cartItems.removeWhere((cartItem) => cartItem.name == item.name);
      }
    });
  }

  void _clearCart() {
    setState(() {
      cartItems.clear();
      widget.cartItems.clear();
    });
  }

  void _openPaymentWebView(BuildContext context) {
    const String paymentUrl =
        'https://app.sandbox.midtrans.com/payment-links/1735626717876';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Pembayaran'),
            backgroundColor: Colors.greenAccent[400],
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(paymentUrl))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) {
                    if (request.url.contains('success-redirect-url')) {
                      Navigator.pop(context);
                      _clearCart(); // Kosongkan keranjang setelah pembayaran sukses
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Keranjang Anda kosong!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final CartItem item = cartItems[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(item.imageUrl,
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(item.name),
                    subtitle: Text('${item.price} - Jumlah: ${item.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        removeSingleQuantity(item, index);
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Rp ${cartItems.map((item) {
                      return (int.tryParse(item.price
                                  .replaceAll(RegExp(r'[^0-9]'), '')) ??
                              0) *
                          item.quantity;
                    }).reduce((a, b) => a + b)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _openPaymentWebView(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                    ),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}
