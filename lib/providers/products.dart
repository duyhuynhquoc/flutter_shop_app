import 'dart:convert';

import 'package:flutter_shop_app/models/http_exception.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: '红色的T恤',
    //   description: '一个红T恤-这个比较红！',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: '裤子',
    //   description: '一条好裤子',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: '黄围巾',
    //   description: '暖和-正是你冬天需要的',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: '平底锅',
    //   description: '准备任何你要的饭菜',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get allItems {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return [..._items.where((item) => item.isFavorite)];
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/products.json');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;

      final List<Product> fetchedProducts = [];
      data.forEach((prodId, prodData) {
        fetchedProducts.insert(
            0,
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: prodData['isFavorite'],
            ));
      });
      _items = fetchedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/products.json');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      // _items.add(newProduct);
      _items.insert(0, newProduct);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product newProduct) async {
    final i = _items.indexWhere((p) => p.id == newProduct.id);
    if (i >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/products/${newProduct.id}.json');

      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'isFavorite': newProduct.isFavorite,
          },
        ),
      );

      _items[i] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url = Uri.parse(
        'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json');
    final existingProductIndex =
        _items.indexWhere((prod) => prod.id == productId);

    dynamic existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw const HttpException('Could not delete product');
    }

    notifyListeners();
    existingProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }
}
