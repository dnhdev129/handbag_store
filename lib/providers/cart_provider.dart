import 'package:flutter/foundation.dart';
import '../models/item.dart';

class CartProvider with ChangeNotifier {
  // Danh sách sản phẩm trong giỏ hàng
  List<Item> _items = [];

  // Getter cho items trong giỏ hàng
  List<Item> get items => _items;

  // Getter cho tổng số tiền giỏ hàng
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  // Thêm sản phẩm vào giỏ hàng
  void addItem(Item item) {
    // Kiểm tra nếu sản phẩm đã tồn tại trong giỏ hàng
    final existingItemIndex = _items.indexWhere(
        (element) => element.product.productId == item.product.productId);

    if (existingItemIndex >= 0) {
      // Nếu có, chỉ cần tăng số lượng
      _items[existingItemIndex].increaseQuantity();
    } else {
      // Nếu không có, thêm sản phẩm mới vào giỏ
      _items.add(item);
    }
    notifyListeners();
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }

  // Tăng số lượng sản phẩm
  void increaseQuantity(Item item) {
    item.increaseQuantity();
    notifyListeners();
  }

  // Giảm số lượng sản phẩm
  void decreaseQuantity(Item item) {
    item.decreaseQuantity();
    notifyListeners();
  }

  // Xóa tất cả sản phẩm trong giỏ hàng (dùng khi thanh toán)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
