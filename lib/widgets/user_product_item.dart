// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_shop_app/models/http_exception.dart';
import 'package:flutter_shop_app/providers/product.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:flutter_shop_app/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final Product product;

  const UserProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(product.title),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: product.id);
              },
              color: Colors.amber,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (product.id != null) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('你确定吗？'),
                      content: const Text('你要删除这个产品吗？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await Provider.of<Products>(context,
                                      listen: false)
                                  .deleteProduct(product.id.toString());

                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('产品已删除。'),
                                ),
                              );
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('删除失败。'),
                                ),
                              );
                            } finally {
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: const Text('同意'),
                        ),
                      ],
                    ),
                  );
                }
              },
              color: Colors.red,
            )
          ],
        ),
      ),
    );
  }
}
