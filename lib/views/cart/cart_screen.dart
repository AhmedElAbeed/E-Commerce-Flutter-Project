


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/demand_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/demand_provider.dart';
import '../../providers/product_provider.dart';
import '../demands/demand_confirmation_screen.dart';
import '../products/product_details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              return provider.cartItems.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Cart'),
                      content: const Text(
                          'Are you sure you want to clear your cart?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await provider.clearCart();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.cartItems[index];
                    return Dismissible(
                      key: Key(item.productId.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await provider.removeFromCart(item.productId);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image),
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${item.price.toStringAsFixed(2)}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () => provider.updateQuantity(
                                      item.productId,
                                      item.quantity - 1,
                                    ),
                                  ),
                                  Text(item.quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => provider.updateQuantity(
                                      item.productId,
                                      item.quantity + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            final productProvider =
                            Provider.of<ProductProvider>(context,
                                listen: false);
                            final product = productProvider.products.firstWhere(
                                  (p) => p.id == item.productId,
                              orElse: () => ProductModel(
                                id: item.productId,
                                title: item.title,
                                description: '',
                                price: item.price,
                                image: item.image,
                                stock: 0,
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Consumer<CouponProvider>(
                builder: (context, couponProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (couponProvider.appliedCoupon != null)
                          ListTile(
                            title: Text(
                                'Applied Coupon: ${couponProvider.appliedCoupon!.code}'),
                            subtitle: Text(
                                '${couponProvider.appliedCoupon!.discountPercentage}% off'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => couponProvider.removeCoupon(),
                            ),
                          ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Coupon Code',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () {
                                final code = _couponController.text.trim();
                                if (code.isNotEmpty) {
                                  couponProvider.applyCoupon(code).catchError((e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                          controller: _couponController,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${provider.totalItems} items):',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (Provider.of<CouponProvider>(context)
                                .appliedCoupon !=
                                null)
                              Text(
                                '\$${provider.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            Text(
                              '\$${provider.getDiscountedTotal(context).toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
// Update your CartScreen's proceed to checkout button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final user = Provider.of<UserAuthProvider>(context, listen: false).user;
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          final couponProvider = Provider.of<CouponProvider>(context, listen: false);
                          final demandProvider = Provider.of<DemandProvider>(context, listen: false);

                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login to proceed')),
                            );
                            return;
                          }

                          try {
                            final demand = DemandModel(
                              userEmail: user.email!,
                              products: cartProvider.cartItems.map((item) => CartItem(
                                productId: item.productId,
                                title: item.title,
                                price: item.price,
                                image: item.image,
                                quantity: item.quantity,
                              )).toList(),
                              totalAmount: couponProvider.appliedCoupon != null
                                  ? cartProvider.getDiscountedTotal(context)
                                  : cartProvider.totalAmount,
                              date: DateTime.now(),
                              couponCode: couponProvider.appliedCoupon?.code,
                            );

                            final demandId = await demandProvider.createDemand(demand);

                            // Clear cart after successful demand creation
                            await cartProvider.clearCart();
                            couponProvider.removeCoupon();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DemandConfirmationScreen(demandId: demandId),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        },
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),


    );
  }
}