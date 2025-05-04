// lib/views/demand/admin_demands_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/demand_model.dart';
import '../../providers/demand_provider.dart';

class AdminDemandsScreen extends StatefulWidget {
  const AdminDemandsScreen({Key? key}) : super(key: key);

  @override
  State<AdminDemandsScreen> createState() => _AdminDemandsScreenState();
}

class _AdminDemandsScreenState extends State<AdminDemandsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandProvider>(context, listen: false).loadAllDemands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DemandProvider>(context, listen: false).loadAllDemands();
            },
          ),
        ],
      ),
      body: Consumer<DemandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.demands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.list_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No orders found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllDemands(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadAllDemands();
            },
            child: ListView.builder(
              itemCount: provider.demands.length,
              itemBuilder: (context, index) {
                final demand = provider.demands[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text('Order #${demand.id ?? 'N/A'}'),
                    subtitle: Text('${demand.userEmail} - ${demand.status}'),
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
                              leading: product.image.isNotEmpty
                                  ? Image.network(
                                product.image,
                                width: 50,
                                height: 50,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image),
                              )
                                  : const Icon(Icons.image),
                              title: Text(product.title),
                              subtitle: Text('Qty: ${product.quantity}'),
                              trailing: Text('\$${(product.price * product.quantity).toStringAsFixed(2)}'),
                            )).toList(),
                            const SizedBox(height: 10),
                            if (demand.status == 'pending')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      provider.updateStatus(demand.id!, 'approved');
                                    },
                                    child: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      provider.updateStatus(demand.id!, 'rejected');
                                    },
                                    child: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}