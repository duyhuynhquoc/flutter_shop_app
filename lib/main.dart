import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/auth.dart';
import 'package:flutter_shop_app/providers/cart.dart';
import 'package:flutter_shop_app/providers/orders.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:flutter_shop_app/screens/auth_screen.dart';
import 'package:flutter_shop_app/screens/cart_screen.dart';
import 'package:flutter_shop_app/screens/edit_product_screen.dart';
import 'package:flutter_shop_app/screens/orders_screen.dart';
import 'package:flutter_shop_app/screens/product_detail_screen.dart';
import 'package:flutter_shop_app/screens/products_overview_screen.dart';
import 'package:flutter_shop_app/screens/splash_screen.dart';
import 'package:flutter_shop_app/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
      primarySwatch: Colors.purple,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(null, null, []),
          update: (context, auth, previousProducts) =>
              Products(auth.token, auth.userId, previousProducts == null ? [] : previousProducts.allItems),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (ctx) => Cart(),
          update: (ctx, auth, prevCart) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(null, null, []),
          update: (context, auth, prevOrders) =>
              Orders(auth.token, auth.userId, prevOrders == null ? [] : prevOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: '阿里哈哈',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.purple,
            colorScheme: themeData.colorScheme.copyWith(secondary: Colors.deepOrange),
          ),
          home: auth.isAuth
              ? ProductsOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductScreen.routeName: (context) => UserProductScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen()
          },
        ),
      ),
    );
  }
}
