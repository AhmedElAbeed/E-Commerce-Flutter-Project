import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coupon_model.dart';
import '../../providers/coupon_provider.dart';
import 'coupon_form_screen.dart';
import 'package:intl/intl.dart'; // Add this import at the top


class CouponListScreen extends StatelessWidget {
  const CouponListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Coupons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<CouponProvider>(context, listen: false).loadCoupons();
            },
          ),
        ],
      ),
      body: Consumer<CouponProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No coupons available"),
                  TextButton(
                    onPressed: () => provider.loadCoupons(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.coupons.length,
            itemBuilder: (context, index) {
              final coupon = provider.coupons[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                elevation: 2,
                color: coupon.isValid ? null : Colors.grey[200],
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: coupon.isValid
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    child: Icon(
                      coupon.isValid ? Icons.discount : Icons.discount_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    coupon.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: coupon.isValid
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${coupon.discountPercentage}% discount',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Expires: ${DateFormat('MMM dd, yyyy').format(coupon.expiryDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: coupon.expiryDate.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: coupon.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              coupon.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: coupon.isActive
                                    ? Colors.green[800]
                                    : Colors.red[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: coupon.isValid
                                  ? Colors.blue[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              coupon.isValid ? 'Valid' : 'Expired',
                              style: TextStyle(
                                fontSize: 12,
                                color: coupon.isValid
                                    ? Colors.blue[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CouponFormScreen(coupon: coupon),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _showDeleteDialog(context, provider, coupon);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CouponFormScreen(coupon: coupon),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CouponFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, CouponProvider provider, CouponModel coupon) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete ${coupon.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.deactivateCoupon(coupon.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${coupon.code} deactivated'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to deactivate: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Deactivate'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.deleteCoupon(coupon.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${coupon.code} deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}