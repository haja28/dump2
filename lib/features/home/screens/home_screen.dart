import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../kitchen/providers/kitchen_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenProvider>().fetchKitchens(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final kitchenProvider = context.watch<KitchenProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authProvider.currentUser?.firstName ?? "User"}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'What would you like to eat today?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: ThemeConfig.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  context.push('/cart');
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: ThemeConfig.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<KitchenProvider>().fetchKitchens(refresh: true);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConfig.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              GestureDetector(
                onTap: () {
                  context.push('/search');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.paddingM,
                    vertical: ThemeConfig.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: ThemeConfig.textSecondaryColor,
                      ),
                      const SizedBox(width: ThemeConfig.paddingM),
                      Text(
                        'Search for food, kitchens...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ThemeConfig.paddingL),
              // Categories
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: ThemeConfig.paddingM),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryCard(
                      'All',
                      Icons.restaurant,
                      ThemeConfig.primaryColor,
                    ),
                    _buildCategoryCard(
                      'Veg',
                      Icons.eco,
                      ThemeConfig.vegColor,
                    ),
                    _buildCategoryCard(
                      'Non-Veg',
                      Icons.food_bank,
                      ThemeConfig.nonVegColor,
                    ),
                    _buildCategoryCard(
                      'Halal',
                      Icons.verified,
                      ThemeConfig.halalColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ThemeConfig.paddingL),
              // Featured Kitchens
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Kitchens',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/kitchens');
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConfig.paddingM),
              if (kitchenProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (kitchenProvider.kitchens.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(ThemeConfig.paddingXL),
                    child: Text('No kitchens available'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kitchenProvider.kitchens.take(5).length,
                  itemBuilder: (context, index) {
                    final kitchen = kitchenProvider.kitchens[index];
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: ThemeConfig.paddingM,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(ThemeConfig.paddingM),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: ThemeConfig.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              ThemeConfig.radiusM,
                            ),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          kitchen.kitchenName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(kitchen.cuisineTypes ?? 'Multiple Cuisines'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: ThemeConfig.warningColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${kitchen.rating?.toStringAsFixed(1) ?? "4.5"}',
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.location_on,
                                  color: ThemeConfig.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    kitchen.city,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push('/kitchen/${kitchen.id}');
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: ThemeConfig.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
