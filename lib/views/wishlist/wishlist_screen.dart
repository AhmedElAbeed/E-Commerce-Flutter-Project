import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/cart_model.dart';
import '../../models/product_model.dart';
import '../../models/wishlist_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../products/product_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.indigo.shade800;
    final Color secondaryColor = Colors.blue.shade400;
    final Color backgroundColor = Colors.indigo.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Wishlist',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            color: Colors.white,
            onPressed: () {
              // Add search functionality
            },
          ).animate().shakeX(delay: 300.ms, duration: 600.ms),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          if (wishlistProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ).animate().scale(),
            );
          }

          if (wishlistProvider.wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 100, color: secondaryColor)
                      .animate()
                      .scale(duration: 600.ms)
                      .then(delay: 200.ms)
                      .shake(),
                  const SizedBox(height: 24),
                  Text('Your Wishlist is Empty',
                      style: TextStyle(
                          fontSize: 22,
                          color: primaryColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Save your favorite items here',
                      style: TextStyle(
                          fontSize: 16,
                          color: primaryColor.withOpacity(0.7))),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 16),
                      shadowColor: secondaryColor.withOpacity(0.5),
                    ),
                    child: const Text('Discover Products',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Text(
                      '${wishlistProvider.wishlistItems.length} ${wishlistProvider.wishlistItems.length == 1 ? 'Item' : 'Items'}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: wishlistProvider.wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = wishlistProvider.wishlistItems[index];
                    final productProvider =
                    Provider.of<ProductProvider>(context, listen: false);
                    final product = productProvider.products.firstWhere(
                          (p) => p.id == item.productId,
                      orElse: () => ProductModel(
                        id: item.productId,
                        title: item.title,
                        description: '',
                        price: item.price,
                        image: item.image,
                        stock: 0,
                        isFavorite: true,
                      ),
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        shadowColor: primaryColor.withOpacity(0.2),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    child: Stack(
                                      children: [
                                        Hero(
                                          tag: 'wishlist-image-${product.id}',
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Center(
                                              child: Icon(Icons.image,
                                                  size: 40,
                                                  color: secondaryColor),
                                            ),
                                          ),
                                        ),
                                        if (product.stock <= 0)
                                          Container(
                                            color: Colors.black.withOpacity(0.4),
                                            child: Center(
                                              child: Text(
                                                'SOLD OUT',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black,
                                                      blurRadius: 10,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: secondaryColor.withOpacity(0.1),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (product.stock > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: secondaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text('In Stock',
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold)),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text('Out of Stock',
                                                  style: TextStyle(
                                                      color: Colors.red.shade600,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.favorite,
                                      color: primaryColor),
                                  onPressed: () async {
                                    await productProvider.toggleFavorite(
                                        product.id!);
                                    await wishlistProvider.toggleWishlist(
                                      WishlistModel(
                                        productId: product.id!,
                                        title: product.title,
                                        price: product.price,
                                        image: product.image,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Consumer<CartProvider>(
                                builder: (context, cartProvider, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.2),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.add_shopping_cart,
                                          size: 20,
                                          color: primaryColor),
                                      onPressed: product.stock > 0
                                          ? () async {
                                        await cartProvider.addToCart(
                                          CartModel(
                                            productId: product.id!,
                                            title: product.title,
                                            price: product.price,
                                            image: product.image,
                                            quantity: 1,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${product.title} added to cart'),
                                            behavior:
                                            SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            backgroundColor: primaryColor,
                                            duration: const Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'VIEW',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                // Navigate to cart
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ).animate().slideX(begin: 1, duration: 500.ms, curve: Curves.decelerate),
    );
  }
}