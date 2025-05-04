// lib/views/demand/demand_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/demand_model.dart';
import '../../providers/demand_provider.dart';

class DemandHistoryScreen extends StatelessWidget {
  final String userEmail;

  const DemandHistoryScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final demandProvider = Provider.of<DemandProvider>(context);

    // Load demands when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      demandProvider.loadUserDemands(userEmail);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Consumer<DemandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.demands.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            itemCount: provider.demands.length,
            itemBuilder: (context, index) {
              final demand = provider.demands[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Order #${demand.id}'),
                  subtitle: Text(
                    '${demand.date.day}/${demand.date.month}/${demand.date.year} - ${demand.status}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: \$${demand.totalAmount.toStringAsFixed(2)}'),
                          if (demand.couponCode != null)
                            Text('Coupon Applied: ${demand.couponCode}'),
                          const SizedBox(height: 10),
                          const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...demand.products.map((product) => ListTile(
                            leading: Image.network(product.image, width: 50, height: 50),
                            title: Text(product.title),
                            subtitle: Text('Qty: ${product.quantity}'),
                            trailing: Text('\$${(product.price * product.quantity).toStringAsFixed(2)}'),
                          )).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}