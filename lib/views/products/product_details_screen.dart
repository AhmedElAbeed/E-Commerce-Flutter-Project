import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/cart_model.dart';
import '../../models/wishlist_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../cart/cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ),
              const SizedBox(width: 8),
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: product.isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        await productProvider.toggleFavorite(product.id!);
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
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ClipPath(
                  clipper: _CurvedTopClipper(),
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.stock > 0
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2,
                                    color: product.stock > 0 ? Colors.green : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.stock > 0 ? 'In Stock (${product.stock})' : 'Out of Stock',
                                    style: TextStyle(
                                      color: product.stock > 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(context, cartProvider),
    );
  }

  Widget _buildBottomAppBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'VIEW CART',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Add to Cart',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom clipper for the curved top effect
class _CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 30);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
