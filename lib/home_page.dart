import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toko_buah/profile_page.dart';
import 'cart_page.dart';
import 'cart_item.dart';
import 'payment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference realtimeDb = FirebaseDatabase.instance.ref();
  String userName = '';
  List<CartItem> cartItems = []; // Menyimpan item keranjang

  // Daftar item menu yang akan ditampilkan
  final List<Map<String, String>> menuItems = [
    {
      'name': 'Buah Naga Tanpa Biji/pcs',
      'price': 'Rp 30.000',
      'imageUrl':
          'https://foto.kontan.co.id/-7OEaeIu3K_oAtIizOPrHnl3IR8=/smart/2023/02/14/848912383p.jpg',
      'paymentUrl':
          'https://app.sandbox.midtrans.com/payment-links/1735787614089',
    },
    {
      'name': 'Buah Apel Cina/pcs',
      'price': 'Rp 10.000',
      'imageUrl':
          'https://st2.depositphotos.com/6782220/9966/i/450/depositphotos_99668474-stock-photo-isolated-mandarin-date-ripe-natural.jpg',
      'paymentUrl':
          'https://app.sandbox.midtrans.com/payment-links/1735787716705',
    },
    {
      'name': 'Buah Kecapi/pcs',
      'price': 'Rp 11.000',
      'imageUrl':
          'https://res.cloudinary.com/dk0z4ums3/image/upload/v1670839318/attached_image/6-manfaat-buah-kecapi-untuk-kesehatan-yang-jarang-diketahui.jpg',
      'paymentUrl':
          'https://app.sandbox.midtrans.com/payment-links/1735787766762',
    },
  ];

  // Menambahkan item ke keranjang
  void addToCart(CartItem item) {
    setState(() {
      cartItems.add(item); // Menambahkan item ke dalam cartItems
    });

    // Data yang akan disimpan
    Map<String, dynamic> cartData = {
      'name': item.name,
      'price': item.price,
      'imageUrl': item.imageUrl,
      'quantity': item.quantity,
    };

    // Simpan ke Firestore dan Realtime Database
    saveDataToDatabases('cart', cartData);
  }

  // Menghapus item dari keranjang
  void removeFromCart(CartItem item) {
    setState(() {
      cartItems.remove(item); // Menghapus item dari cartItems
    });
  }

  // Fungsi untuk menyimpan data ke Firestore dan Realtime Database
  Future<void> saveDataToDatabases(
      String collection, Map<String, dynamic> data) async {
    try {
      // Simpan ke Firestore
      DocumentReference docRef =
          await firestore.collection(collection).add(data);

      // Simpan ke Realtime Database
      await realtimeDb.child(collection).child(docRef.id).set(data);

      print('Data berhasil disimpan ke Firestore dan Realtime Database.');
    } catch (e) {
      print('Error menyimpan data: $e');
    }
  }

  // Fungsi untuk pembelian langsung
  void _directPurchase(
      String name, String price, String imageUrl, String paymentUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(paymentUrl: paymentUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Anda mau keluar?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Keluar'),
                ),
              ],
            );
          },
        );

        if (shouldExit == true) {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (Route<dynamic> route) => false,
          );
        }

        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.teal[100],
        appBar: AppBar(
          title: const Text('Freshly'),
          backgroundColor: Colors.greenAccent[400],
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      cartItems: cartItems,
                      removeFromCart: removeFromCart,
                      updateCart: (CartItem item, int newQuantity) {
                        setState(() {
                          final index = cartItems.indexWhere(
                              (cartItem) => cartItem.name == item.name);
                          if (index != -1) {
                            cartItems[index].quantity = newQuantity;
                            if (newQuantity == 0) {
                              cartItems.removeAt(index);
                            }
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: user != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .get()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found.'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            userName = userData['username'] ?? 'User';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://cdn.icon-icons.com/icons2/3939/PNG/512/camera_image_picture_photo_profile_icon_250753.png',
                          ),
                          radius: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Hallo, $userName\nSelamat Belanja.',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        'https://ukmindonesia.id/uploads/news-content/18631-0.png',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      var menuItem = menuItems[index];
                      return _buildMenuItem(
                        menuItem['name']!,
                        menuItem['price']!,
                        menuItem['imageUrl']!,
                        menuItem['paymentUrl']!,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      String name, String price, String imageUrl, String paymentUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(price),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                CartItem cartItem = CartItem(
                  name: name,
                  price: price,
                  imageUrl: imageUrl,
                  paymentUrl: paymentUrl,
                );
                addToCart(cartItem);
              },
            ),
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () {
                _directPurchase(name, price, imageUrl, paymentUrl);
              },
            ),
          ],
        ),
      ),
    );
  }
}
