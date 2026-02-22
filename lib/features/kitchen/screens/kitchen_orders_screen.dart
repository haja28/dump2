import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme_config.dart';
import '../../order/providers/order_provider.dart';

class KitchenOrdersScreen extends StatefulWidget {
  const KitchenOrdersScreen({super.key});

  @override
  State<KitchenOrdersScreen> createState() => _KitchenOrdersScreenState();
}

class _KitchenOrdersScreenState extends State<KitchenOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'New',
    'Preparing',
    'Ready',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await context.read<OrderProvider>().fetchKitchenOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          indicatorColor: ThemeConfig.primaryColor,
          labelColor: ThemeConfig.primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderProvider.newOrders, 'new'),
              _buildOrderList(orderProvider.preparingOrders, 'preparing'),
              _buildOrderList(orderProvider.readyOrders, 'ready'),
              _buildOrderList(orderProvider.completedOrders, 'completed'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No $status orders',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatTime(order.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Order items
            ...order.items.map<Widget>((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          color: ThemeConfig.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const Divider(height: 24),

            // Order total and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: _buildActionButtons(order),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(dynamic order) {
    final orderProvider = context.read<OrderProvider>();

    switch (order.status.toUpperCase()) {
      case 'PENDING':
        return [
          OutlinedButton(
            onPressed: () => orderProvider.rejectOrder(order.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Reject'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => orderProvider.acceptOrder(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryColor,
            ),
            child: const Text('Accept'),
          ),
        ];
      case 'CONFIRMED':
        return [
          ElevatedButton(
            onPressed: () => orderProvider.startPreparing(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Start Preparing'),
          ),
        ];
      case 'PREPARING':
        return [
          ElevatedButton(
            onPressed: () => orderProvider.markReady(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: const Text('Mark Ready'),
          ),
        ];
      case 'READY':
        return [
          ElevatedButton(
            onPressed: () => orderProvider.completeOrder(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Complete'),
          ),
        ];
      default:
        return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.orange;
      case 'PREPARING':
        return Colors.purple;
      case 'READY':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

