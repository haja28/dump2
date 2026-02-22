import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/menu_model.dart';
import '../../menu/providers/menu_provider.dart';
import '../providers/kitchen_provider.dart';

class KitchenMenuScreen extends StatefulWidget {
  const KitchenMenuScreen({super.key});

  @override
  State<KitchenMenuScreen> createState() => _KitchenMenuScreenState();
}

class _KitchenMenuScreenState extends State<KitchenMenuScreen> {
  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final kitchenProvider = context.read<KitchenProvider>();
    final menuProvider = context.read<MenuProvider>();
    if (kitchenProvider.myKitchen != null) {
      await menuProvider.fetchKitchenMenuItems(kitchenProvider.myKitchen!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/kitchen/menu/add'),
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, _) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final menuItems = menuProvider.kitchenMenuItems;
          if (menuItems.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: _loadMenu,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) => _buildMenuItemCard(menuItems[index], menuProvider),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/kitchen/menu/add'),
        backgroundColor: ThemeConfig.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No menu items yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/kitchen/menu/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Menu Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item, MenuProvider menuProvider) {
    final bool isAvailable = item.isAvailable;
    final int quantity = item.quantityAvailable ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/kitchen/menu/edit/${item.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: item.imagePath != null
                          ? Image.network(
                              item.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 32),
                            )
                          : const Icon(Icons.restaurant, size: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAvailable ? 'Available' : 'Unavailable',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeConfig.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Labels
                        if (item.labels != null && item.labels!.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: item.labels!.take(3).map((label) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label.name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              // Quick actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity info
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Qty: $quantity',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  // Quick action buttons
                  Row(
                    children: [
                      // Update quantity button
                      TextButton.icon(
                        onPressed: () => _showQuantityDialog(item, menuProvider),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Stock'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      // Toggle availability
                      TextButton.icon(
                        onPressed: () async {
                          if (isAvailable) {
                            await menuProvider.markOutOfStock(item.id);
                          } else {
                            await _showQuantityDialog(item, menuProvider);
                          }
                          // Refresh the list
                          _loadMenu();
                        },
                        icon: Icon(
                          isAvailable ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          size: 16,
                        ),
                        label: Text(isAvailable ? 'Out of Stock' : 'Restock'),
                        style: TextButton.styleFrom(
                          foregroundColor: isAvailable ? Colors.orange : Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuantityDialog(MenuItem item, MenuProvider menuProvider) async {
    final controller = TextEditingController(text: (item.quantityAvailable ?? 0).toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current quantity: ${item.quantityAvailable ?? 0}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New Quantity',
                hintText: 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(controller.text);
              if (quantity != null && quantity >= 0) {
                Navigator.pop(context, quantity);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      final success = await menuProvider.updateQuantityAvailability(item.id, result);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quantity updated'), backgroundColor: Colors.green),
          );
          _loadMenu();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update quantity'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

