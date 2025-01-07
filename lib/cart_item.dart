class CartItem {
  final String name;
  final String price;
  final String imageUrl;
  final String paymentUrl;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.paymentUrl,
    
    this.quantity =
        1, // Pastikan quantity memiliki nilai default jika tidak diberikan
  });

  // Menambahkan metode untuk meningkatkan jumlah
  void increaseQuantity() {
    quantity++;
  }

  // Method untuk mengurangi jumlah
  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}
