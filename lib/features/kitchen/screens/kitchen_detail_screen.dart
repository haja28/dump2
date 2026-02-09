import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/kitchen_model.dart';
import '../../../core/models/menu_model.dart';
import '../providers/kitchen_provider.dart';
import '../../menu/providers/menu_provider.dart';
import '../../cart/providers/cart_provider.dart';

class KitchenDetailScreen extends StatefulWidget {
  final int kitchenId;
  
  const KitchenDetailScreen({super.key, required this.kitchenId});

  @override
  State<KitchenDetailScreen> createState() => _KitchenDetailScreenState();
}

class _KitchenDetailScreenState extends State<KitchenDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenProvider>().fetchKitchenById(widget.kitchenId);
      context.read<MenuProvider>().fetchKitchenMenu(widget.kitchenId, refresh: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kitchenProvider = context.watch<KitchenProvider>();
    final menuProvider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();
    final kitchen = kitchenProvider.selectedKitchen;

    return Scaffold(
      body: kitchenProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : kitchen == null
              ? _buildErrorState()
              : Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        _buildSliverAppBar(kitchen, context),
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKitchenInfo(kitchen, context),
                                _buildCuisineTypes(kitchen),
                                _buildStatsRow(kitchen),
                                _buildContactSection(kitchen),
                                _buildMenuSection(menuProvider, cartProvider),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (cartProvider.itemCount > 0) _buildFloatingCart(cartProvider, context),
                  ],
                ),
    );
  }

  Widget _buildSliverAppBar(Kitchen kitchen, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: ThemeConfig.primaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: ThemeConfig.primaryColor),
        ),
        onPressed: () => context.pop(),
      ),
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          kitchen.kitchenName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: ThemeConfig.primaryColor),
          ),
          onPressed: () {
            // Share functionality
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background (placeholder for image)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeConfig.primaryColor,
                    ThemeConfig.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Pattern overlay
            Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/pattern.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Kitchen icon/logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKitchenInfo(Kitchen kitchen, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kitchen.kitchenName,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (kitchen.isApproved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.paddingM,
                    vertical: ThemeConfig.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConfig.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusCircular),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.verified,
                        color: ThemeConfig.successColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: ThemeConfig.successColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: ThemeConfig.paddingS),
          if (kitchen.description != null)
            Text(
              kitchen.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ThemeConfig.textSecondaryColor,
                    height: 1.5,
                  ),
            ),
          const SizedBox(height: ThemeConfig.paddingM),
          Row(
            children: [
              _buildInfoChip(
                Icons.star,
                '${kitchen.rating?.toStringAsFixed(1) ?? "4.5"}',
                ThemeConfig.warningColor,
              ),
              const SizedBox(width: ThemeConfig.paddingM),
              _buildInfoChip(
                Icons.shopping_bag_outlined,
                '${kitchen.totalOrders ?? 0}+ orders',
                ThemeConfig.infoColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.paddingM,
        vertical: ThemeConfig.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineTypes(Kitchen kitchen) {
    if (kitchen.cuisineTypes == null || kitchen.cuisineList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuisines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeConfig.paddingM),
          Wrap(
            spacing: ThemeConfig.paddingS,
            runSpacing: ThemeConfig.paddingS,
            children: kitchen.cuisineList.map((cuisine) {
              return Chip(
                label: Text(cuisine),
                backgroundColor: ThemeConfig.accentColor.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: ThemeConfig.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: ThemeConfig.paddingL),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Kitchen kitchen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConfig.paddingL),
      padding: const EdgeInsets.all(ThemeConfig.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.primaryColor.withOpacity(0.05),
            ThemeConfig.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.access_time,
            'Open',
            kitchen.isApproved ? 'Now' : 'Closed',
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            Icons.delivery_dining,
            'Delivery',
            kitchen.city,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            Icons.schedule,
            'Time',
            '30-45 min',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: ThemeConfig.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ThemeConfig.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(Kitchen kitchen) {
    return Container(
      margin: const EdgeInsets.all(ThemeConfig.paddingL),
      padding: const EdgeInsets.all(ThemeConfig.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeConfig.paddingM),
          _buildContactItem(
            Icons.location_on,
            '${kitchen.address}, ${kitchen.city}',
            ThemeConfig.primaryColor,
          ),
          const SizedBox(height: ThemeConfig.paddingM),
          _buildContactItem(
            Icons.phone,
            kitchen.ownerContact,
            ThemeConfig.accentColor,
          ),
          const SizedBox(height: ThemeConfig.paddingM),
          _buildContactItem(
            Icons.email,
            kitchen.ownerEmail,
            ThemeConfig.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: ThemeConfig.paddingM),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(MenuProvider menuProvider, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Filter functionality
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: ThemeConfig.paddingM),
          if (menuProvider.isLoading)
            _buildMenuLoadingState()
          else if (menuProvider.menuItems.isEmpty)
            _buildEmptyMenuState()
          else
            _buildMenuGrid(menuProvider.menuItems, cartProvider),
        ],
      ),
    );
  }

  Widget _buildMenuLoadingState() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: ThemeConfig.paddingM,
        crossAxisSpacing: ThemeConfig.paddingM,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyMenuState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.paddingXL),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: ThemeConfig.paddingM),
            Text(
              'No menu items available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(List<MenuItem> items, CartProvider cartProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: ThemeConfig.paddingM,
        crossAxisSpacing: ThemeConfig.paddingM,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMenuItem(item, cartProvider);
      },
    );
  }

  Widget _buildMenuItem(MenuItem item, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () {
        context.push('/menu-item/${item.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ThemeConfig.accentColor,
                        ThemeConfig.secondaryColor,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(ThemeConfig.radiusL),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      item.isVeg ? Icons.eco : Icons.restaurant,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.isVeg
                          ? ThemeConfig.vegColor
                          : ThemeConfig.nonVegColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isVeg ? Icons.circle : Icons.stop,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!item.isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(ThemeConfig.radiusL),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Not Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Item Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConfig.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        if (item.rating != null) ...[
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: ThemeConfig.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.cost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: ThemeConfig.primaryColor,
                          ),
                        ),
                        if (item.isAvailable)
                          GestureDetector(
                            onTap: () async {
                              final success = await cartProvider.addItem(
                                itemId: item.id,
                                quantity: 1,
                              );
                              if (!context.mounted) return;

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.itemName} added to cart'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to add item to cart'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: ThemeConfig.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCart(CartProvider cartProvider, BuildContext context) {
    return Positioned(
      bottom: ThemeConfig.paddingL,
      left: ThemeConfig.paddingL,
      right: ThemeConfig.paddingL,
      child: GestureDetector(
        onTap: () => context.push('/cart'),
        child: Container(
          padding: const EdgeInsets.all(ThemeConfig.paddingL),
          decoration: BoxDecoration(
            gradient: ThemeConfig.primaryGradient,
            borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.primaryColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeConfig.paddingM),
                  const Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '\$${cartProvider.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: ThemeConfig.paddingM),
            Text(
              'Failed to load kitchen details',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: ThemeConfig.paddingL),
            ElevatedButton(
              onPressed: () {
                context.read<KitchenProvider>().fetchKitchenById(widget.kitchenId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
