import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/menu_model.dart';
import '../../../core/services/api_service.dart';
import '../../menu/providers/menu_provider.dart';
import '../providers/kitchen_provider.dart';

class KitchenMenuScreen extends StatefulWidget {
  const KitchenMenuScreen({super.key});

  @override
  State<KitchenMenuScreen> createState() => _KitchenMenuScreenState();
}

class _KitchenMenuScreenState extends State<KitchenMenuScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMenu();
    });
  }

  Future<void> _loadMenu() async {
    if (!mounted) return;

    final kitchenProvider = context.read<KitchenProvider>();
    final menuProvider = context.read<MenuProvider>();

    // If myKitchen is null, try to fetch it first
    if (kitchenProvider.myKitchen == null) {
      await kitchenProvider.fetchMyKitchen();
    }

    // Now try to load menu items
    if (kitchenProvider.myKitchen != null) {
      await menuProvider.fetchKitchenMenuItems(kitchenProvider.myKitchen!.id);
    } else {
      debugPrint('KitchenMenuScreen: myKitchen is still null after fetch attempt');
    }

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
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
      body: Consumer2<KitchenProvider, MenuProvider>(
        builder: (context, kitchenProvider, menuProvider, _) {
          // Show loading while initial load is happening
          if (_isInitialLoading || menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if kitchen is not available
          if (kitchenProvider.myKitchen == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load kitchen',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadMenu,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
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
                  // Image - prioritize primary image from images list
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: _buildMenuItemImage(item),
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

  /// Build the menu item image widget, prioritizing primary image from images list
  Widget _buildMenuItemImage(MenuItem item) {
    // First, try to find the primary image from the images list
    String? imageUrl;

    if (item.images != null && item.images!.isNotEmpty) {
      // Find primary image or use first image
      final primaryImage = item.images!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => item.images!.first,
      );

      // Get the thumbnail URL for the primary image
      final baseUrl = ApiService.getImageBaseUrl();
      imageUrl = primaryImage.getThumbnailUrl(baseUrl);
    }

    // Fallback to imagePath if no images in the list
    imageUrl ??= item.imagePath;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ThemeConfig.primaryColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.restaurant, size: 32),
      );
    }

    return const Icon(Icons.restaurant, size: 32);
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

