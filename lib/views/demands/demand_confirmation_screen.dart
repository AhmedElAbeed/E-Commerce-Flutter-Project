// lib/views/demand/demand_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'demand_history_screen.dart';

class DemandConfirmationScreen extends StatelessWidget {
  final String demandId;

  const DemandConfirmationScreen({Key? key, required this.demandId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserAuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Your order has been placed successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Order ID: $demandId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DemandHistoryScreen(userEmail: user?.email ?? ''),
                  ),
                );
              },
              child: const Text('View Order History'),
            ),
          ],
        ),
      ),
    );
  }
}