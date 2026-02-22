import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kitchen_provider.dart';

class KitchenAnalyticsScreen extends StatelessWidget {
  const KitchenAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<KitchenProvider>(
        builder: (context, kitchenProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kitchen Analytics', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                _buildStatCard('Total Orders', '156', Icons.receipt_long, Colors.blue),
                _buildStatCard('Revenue', '\$2,450.00', Icons.attach_money, Colors.green),
                _buildStatCard('Avg Rating', '4.5', Icons.star, Colors.amber),
                _buildStatCard('Menu Items', '24', Icons.restaurant_menu, Colors.purple),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ),
    );
  }
}

