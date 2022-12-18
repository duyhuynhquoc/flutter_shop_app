// ignore_for_file: use_key_in_widget_constructors

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/cart.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:flutter_shop_app/screens/cart_screen.dart';
import 'package:flutter_shop_app/widgets/app_drawer.dart';

import 'package:flutter_shop_app/widgets/products_grid.dart';
import 'package:provider/provider.dart';

enum FilterOption { all, favorite }

class ProductsOverViewScreen extends StatefulWidget {
  @override
  State<ProductsOverViewScreen> createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  FilterOption _filterOption = FilterOption.all;

  bool _isInit = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("阿里哈哈"),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (FilterOption value) {
              setState(() {
                _filterOption = value;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOption.all,
                child: Text('全部'),
              ),
              const PopupMenuItem(
                value: FilterOption.favorite,
                child: Text('喜欢的'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, child) => Badge(
              badgeContent: Container(
                width: 12,
                height: 12,
                child: FittedBox(
                  child: Text(
                    cart.numberOfItems.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              position: BadgePosition.topEnd(top: 6, end: 6),
              padding: const EdgeInsets.all(2),
              toAnimate: false,
              child: child,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () {
                return _refreshProducts(context);
              },
              child: ProductsGrid(_filterOption)),
    );
  }
}
