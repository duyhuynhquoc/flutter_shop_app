// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_shop_app/providers/cart.dart';
import 'package:flutter_shop_app/providers/product.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final Product product;
  final int quantity;

  const CartItem(
    this.id,
    this.product,
    this.quantity,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (product.id != null) {
          Provider.of<Cart>(context, listen: false)
              .removeItem(product.id.toString());
        }
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('你确定吗？'),
            content: const Text('你要删除这个产品从购物车吗？'),
            actions: [
              TextButton(
                onPressed: (() {
                  Navigator.of(ctx).pop(false);
                }),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: (() {
                  Navigator.of(ctx).pop(true);
                }),
                child: const Text('同意'),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
          trailing: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text('x $quantity')),
        ),
      ),
    );
  }
}
