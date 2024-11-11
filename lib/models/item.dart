import 'products.dart';

class Item {
  final Product product;
  int quantity;
  double get totalPrice => product.price * quantity;

  Item({required this.product, this.quantity = 1});
}
