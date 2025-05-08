import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'auth/profile_screen.dart';
import 'products/product_details_screen.dart';
import 'products/product_list_screen.dart';
import 'cart/cart_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade800;
    final secondaryColor = Colors.blueAccent.shade400;
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    return Scaffold(
      appBar: AppBar(
          title: const Text("Trending Products").animate().fadeIn(delay: 200.ms),
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
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          actions: [
            if (userEmail == "ahmedelrollins398@gmail.com")
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  );
                },
              ).animate().shakeX(delay: 300.ms),
    ],
    ),
    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
    Colors.indigo.shade50,
    Colors.blue.shade50,
    ],
    ),
    ),
    child: Consumer<ProductProvider>(
    builder: (context, provider, _) {
    if (provider.isLoading) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
    strokeWidth: 3,
    ).animate().scale(),
    const SizedBox(height: 16),
    Text(
    "Loading Products...",
    style: TextStyle(
    color: primaryColor,
    fontSize: 16,
    ),
    ).animate().fadeIn(delay: 200.ms),
    ],
    ),
    );
    }

    if (provider.products.isEmpty) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.inventory_2, size: 80, color: secondaryColor)
        .animate()
        .scale(duration: 600.ms)
        .then(delay: 200.ms)
        .shake(),
    const SizedBox(height: 24),
    Text(
    "No products available",
    style: TextStyle(
    fontSize: 18,
    color: primaryColor,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 12),
    Text(
    "Check back later for new arrivals",
    style: TextStyle(
    fontSize: 14,
    color: primaryColor.withOpacity(0.7),
    ),
    ),
    const SizedBox(height: 36),
    ElevatedButton(
    onPressed: () => provider.loadProducts(),
    style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(
    horizontal: 36, vertical: 16),
    elevation: 5,
    shadowColor: secondaryColor.withOpacity(0.3),
    ),
    child: const Text('Refresh',
    style: TextStyle(fontWeight: FontWeight.bold)),
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
    "${provider.products.length} ${provider.products.length == 1 ? 'Product' : 'Products'}",
    style: TextStyle(
    color: primaryColor,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ).animate().fadeIn(delay: 100.ms),
    ),
    Expanded(
    child: GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate:
    const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.8,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    ),
    itemCount: provider.products.length,
    itemBuilder: (context, index) {
    final product = provider.products[index];
    return ProductCard(product: product)
        .animate()
        .fadeIn(delay: (100 * index).ms);
    },
    ),
    ),
    ],
    );
    },
    ),
    ),
    bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final primaryColor = Colors.indigo.shade800;

    return Container(
        decoration: BoxDecoration(
            boxShadow: [
        BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 12,
        offset: const Offset(0, -2),
        ),
        ],
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: BottomAppBar(
    height: 80,
    color: Colors.white,
    padding: EdgeInsets.zero,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    _buildNavButton(
    context,
    icon: Icons.home_rounded,
    label: 'Home',
    isActive: true,
    onPressed: () {},
    ).animate().fadeIn(delay: 100.ms),
    _buildNavButton(
    context,
    icon: Icons.favorite_rounded,
    label: 'Wishlist',
    badgeCount:
    Provider.of<WishlistProvider>(context).wishlistItems.length,
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
    },
    ).animate().fadeIn(delay: 200.ms),
    _buildNavButton(
    context,
    icon: Icons.shopping_cart_rounded,
    label: 'Cart',
    badgeCount: Provider.of<CartProvider>(context).totalItems,
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CartScreen()),
    );
    },
    ).animate().fadeIn(delay: 300.ms),
    _buildNavButton(
    context,
    icon: Icons.person_rounded,
    label: 'Profile',
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    },
    ).animate().fadeIn(delay: 400.ms),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildNavButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        bool isActive = false,
        int badgeCount = 0,
        required VoidCallback onPressed,
      }) {
    final primaryColor = Colors.indigo.shade800;

    return InkWell(
      onTap: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isActive ? primaryColor : Colors.grey.shade600,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? primaryColor : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade800;
    final secondaryColor = Colors.blueAccent.shade400;

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
        elevation: 4,
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
                          tag: 'product-image-${product.id}',
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primaryColor,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
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
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
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
                      icon: Icon(
                        product.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: product.isFavorite
                            ? Colors.red.shade500
                            : Colors.grey.shade600,
                      ),
                      onPressed: () async {
                        await provider.toggleFavorite(product.id!);
                        final wishlistProvider =
                        Provider.of<WishlistProvider>(context, listen: false);
                        if (product.isFavorite) {
                          await wishlistProvider.toggleWishlist(
                            WishlistModel(
                              productId: product.id!,
                              title: product.title,
                              price: product.price,
                              image: product.image,
                            ),
                          );
                        } else {
                          await wishlistProvider.removeFromWishlist(product.id!);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
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
                      icon: Icon(Icons.add_shopping_cart_rounded,
                          size: 20, color: primaryColor),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: primaryColor,
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CartScreen()),
                                );
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
      ),
    );
  }
}