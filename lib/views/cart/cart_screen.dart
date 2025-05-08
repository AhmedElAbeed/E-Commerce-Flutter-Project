import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final Color _primaryColor = Colors.indigo.shade800;
  final Color _secondaryColor = Colors.blueAccent.shade400;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Your Cart',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white)),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              return provider.cartItems.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 28),
                onPressed: () => _showClearCartDialog(context, provider),
              ).animate().shakeX(delay: 300.ms)
                  : const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
                strokeWidth: 3,
              ).animate().scale(),
            );
          }

          if (provider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade400)
                      .animate()
                      .scale(duration: 600.ms)
                      .then(delay: 200.ms)
                      .shake(),
                  const SizedBox(height: 24),
                  Text('Your Cart is Empty',
                      style: TextStyle(
                          fontSize: 22,
                          color: _primaryColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Add some products to get started',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600)),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _primaryColor,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 16),
                      shadowColor: _secondaryColor.withOpacity(0.3),
                    ),
                    child: const Text('Continue Shopping',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
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
                        color: Colors.red.shade400,
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) async {
                        return await _showDeleteItemDialog(context, provider, item.productId as String);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _navigateToProductDetails(context, item as CartItem),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Product Image
                                Hero(
                                  tag: 'cart-image-${item.productId}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.image_rounded,
                                            color: Colors.grey.shade400),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Quantity Controls
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  size: 18,
                                                  color: item.quantity > 1
                                                      ? _primaryColor
                                                      : Colors.grey),
                                              onPressed: item.quantity > 1
                                                  ? () => provider.updateQuantity(
                                                item.productId,
                                                item.quantity - 1,
                                              )
                                                  : null,
                                            ),
                                            Text(item.quantity.toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.add_rounded,
                                                  size: 18),
                                              onPressed: () =>
                                                  provider.updateQuantity(
                                                    item.productId,
                                                    item.quantity + 1,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Total Price
                                Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms),
                    );
                  },
                ),
              ),
              // Coupon and Checkout Section
              _buildCheckoutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Coupon Section
          Consumer<CouponProvider>(
            builder: (context, couponProvider, child) {
              return Column(
                children: [
                  if (couponProvider.appliedCoupon != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.discount_rounded,
                              color: Colors.green.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coupon Applied: ${couponProvider.appliedCoupon!.code}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800),
                                ),
                                Text(
                                  '${couponProvider.appliedCoupon!.discountPercentage}% discount',
                                  style: TextStyle(color: Colors.green.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: Colors.green.shade600),
                            onPressed: () => couponProvider.removeCoupon(),
                          ),
                        ],
                      ),
                    ).animate().slideX(begin: 1),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Material(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        child: IconButton(
                          icon: const Icon(Icons.discount_rounded,
                              color: Colors.white),
                          onPressed: () {
                            final code = _couponController.text.trim();
                            if (code.isNotEmpty) {
                              couponProvider.applyCoupon(code).catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Total and Checkout Button
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final couponProvider = Provider.of<CouponProvider>(context);
              final hasDiscount = couponProvider.appliedCoupon != null;
              final discountedTotal = cartProvider.getDiscountedTotal(context);

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal (${cartProvider.totalItems} items):',
                          style: TextStyle(color: Colors.grey.shade600)),
                      Text('\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount:',
                            style: TextStyle(color: Colors.grey.shade600)),
                        Text(
                          '-\$${(cartProvider.totalAmount - discountedTotal).toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor)),
                      Text(
                        '\$${discountedTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: _primaryColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: _secondaryColor.withOpacity(0.3),
                      ),
                      onPressed: () => _proceedToCheckout(context),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ).animate().slideY(begin: 1, delay: 200.ms),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToCheckout(BuildContext context) async {
    final user = Provider.of<UserAuthProvider>(context, listen: false).user;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final demandProvider = Provider.of<DemandProvider>(context, listen: false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to proceed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<bool?> _showDeleteItemDialog(
      BuildContext context, CartProvider provider, String productId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await provider.removeFromCart(productId as int);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCartDialog(
      BuildContext context, CartProvider provider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear your cart?'),
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
  }

  void _navigateToProductDetails(BuildContext context, CartItem item) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
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
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }
}