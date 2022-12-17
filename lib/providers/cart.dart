import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/product.dart';
import 'package:provider/provider.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  void addItem(Product product) {
    if (product.id != null && _items.containsKey(product.id)) {
      // change quantity...
      _items.update(
        product.id.toString(),
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id.toString(),
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  int get numberOfItems {
    int cnt = 0;
    _items.forEach((key, item) {
      cnt += item.quantity;
    });
    return cnt;
  }

  double get totalAmount {
    double total = 0;

    _items.forEach((key, item) {
      total += item.product.price * item.quantity;
    });

    return total;
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decreaseItemQuantity(String productId) {
    _items.forEach((key, item) {
      if (key != productId) return;

      if (item.quantity > 1) {
        _items.update(
          productId,
          (currentItem) => CartItem(
              id: currentItem.id,
              product: currentItem.product,
              quantity: currentItem.quantity - 1),
        );
      } else {
        removeItem(productId);
      }
    });
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
