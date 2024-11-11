import 'products.dart';

class Item {
  final Product product;
  int quantity;

  double get totalPrice => product.price * quantity;

  Item({required this.product, this.quantity = 1});

  void increaseQuantity() {
    quantity++;
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}
