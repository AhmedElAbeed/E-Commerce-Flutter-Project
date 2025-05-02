import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';  // Add this import
import '../../views/products/product_details_screen.dart';
import '../../views/products/product_list_screen.dart';
import '../../views/cart/cart_screen.dart';  // Add this import
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.loadProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No products found."),
                  TextButton(
                    onPressed: () => provider.loadProducts(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return Card(
                child: ListTile(
                  leading: Hero(
                    tag: 'product-image-${product.id}',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(product.image),
                    ),
                  ),
                  title: Text(product.title),
                  subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Button
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
            ),

            // Wishlist Button
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Add wishlist functionality here
              },
            ),

            // Cart Button with Badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return cartProvider.totalItems > 0
                          ? Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartProvider.totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            ),

            // Profile Button
            IconButton(
              icon: const CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/1.jpg'),
              ),
              onPressed: () {
                // Add profile functionality here
              },
            ),
          ],
        ),
      ),
    );
  }
}