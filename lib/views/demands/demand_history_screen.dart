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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Load demands when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      demandProvider.loadUserDemands(userEmail);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<DemandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (provider.demands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your orders will appear here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimatedList(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            initialItemCount: provider.demands.length,
            itemBuilder: (context, index, animation) {
              final demand = provider.demands[index];
              return _buildOrderCard(
                context,
                demand,
                animation,
                index == provider.demands.length - 1,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context,
      DemandModel demand,
      Animation<double> animation,
      bool isLastItem,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      )),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: EdgeInsets.fromLTRB(16, 8, 16, isLastItem ? 8 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              collapsedBackgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
              backgroundColor: colorScheme.surface,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(demand.status, colorScheme).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(demand.status),
                  color: _getStatusColor(demand.status, colorScheme),
                  size: 20,
                ),
              ),
              title: Text(
                'Order #${demand.id?.substring(0, 8)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _formatDate(demand.date),
                style: theme.textTheme.bodySmall,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${demand.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(demand.status, colorScheme).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      demand.status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(demand.status, colorScheme),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.3)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (demand.couponCode != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Coupon Applied: ${demand.couponCode}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        'ITEMS (${demand.products.length})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...demand.products.map((product) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${product.quantity}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(product.price * product.quantity).toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: colorScheme.outline.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '\$${demand.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return colorScheme.primary;
      case 'shipped':
        return Colors.blue;
      case 'REJECTED':
        return Colors.red;
      default:
        return colorScheme.onSurface;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.hourglass_top;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}