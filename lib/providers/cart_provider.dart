import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/products.dart';

class CartProvider with ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => _items;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    var index = _items
        .indexWhere((item) => item.product.productId == product.productId);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(Item(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    var index =
        _items.indexWhere((item) => item.product.productId == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
