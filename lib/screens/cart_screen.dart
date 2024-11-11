import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/item.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: cart.items.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        leading: Image.network(item.product.images[0]),
                        title: Text(item.product.name),
                        subtitle: Text(
                            'Price: \$${item.product.price} x ${item.quantity}'),
                        trailing:
                            Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      Text('Total: \$${cart.totalAmount.toStringAsFixed(2)}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Proceed to checkout logic
                  },
                  child: Text('Checkout'),
                ),
              ],
            ),
    );
  }
}
