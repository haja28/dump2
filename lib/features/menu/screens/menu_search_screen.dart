import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/menu_model.dart';
import '../providers/menu_provider.dart';
import '../../cart/providers/cart_provider.dart';

class MenuSearchScreen extends StatefulWidget {
  const MenuSearchScreen({super.key});

  @override
  State<MenuSearchScreen> createState() => _MenuSearchScreenState();
}

class _MenuSearchScreenState extends State<MenuSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filter state
  bool? _vegFilter;
  bool? _halalFilter;
  double? _minPrice;
  double? _maxPrice;
  int? _minSpicyLevel;
  int? _maxSpicyLevel;
  List<String> _selectedLabels = [];
  String _sortOption = 'rating_desc';

  bool _showFilters = false;
  bool _isLoadingMore = false; // Prevent multiple simultaneous load more calls
  bool _hasSearchText = false; // Track search text state separately
  bool _initialLoadComplete = false; // Track if initial load is done

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch(refresh: true);
      context.read<MenuProvider>().fetchLabels();
    });

    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (hasText != _hasSearchText) {
      setState(() {
        _hasSearchText = hasText;
      });
    }
  }

  void _onScroll() {
    // Don't trigger load more until initial load is complete
    if (!_initialLoadComplete) return;

    // Prevent multiple simultaneous calls
    if (_isLoadingMore) return;

    final menuProvider = context.read<MenuProvider>();

    // Don't load if already loading or no more items
    if (menuProvider.isLoading || !menuProvider.hasMore) return;

    // Don't trigger if list is empty (nothing to scroll)
    if (menuProvider.menuItems.isEmpty) return;

    // Check if we've scrolled near the end
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      _performSearch().then((_) {
        // Use mounted check and delay to prevent rapid re-triggering
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _isLoadingMore = false;
          }
        });
      });
    }
  }

  Future<void> _performSearch({bool refresh = false}) async {
    if (refresh) {
      _isLoadingMore = false;
      _initialLoadComplete = false;
    }
    await context.read<MenuProvider>().searchMenuItems(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      veg: _vegFilter,
      halal: _halalFilter,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minSpicyLevel: _minSpicyLevel,
      maxSpicyLevel: _maxSpicyLevel,
      labels: _selectedLabels.isEmpty ? null : _selectedLabels,
      sort: _sortOption,
      refresh: refresh,
    );

    // Mark initial load as complete after refresh
    if (refresh && mounted) {
      setState(() {
        _initialLoadComplete = true;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _vegFilter = null;
      _halalFilter = null;
      _minPrice = null;
      _maxPrice = null;
      _minSpicyLevel = null;
      _maxSpicyLevel = null;
      _selectedLabels = [];
      _sortOption = 'rating_desc';
    });
    _performSearch(refresh: true);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Menu'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(ThemeConfig.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for food...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _hasSearchText
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch(refresh: true);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(refresh: true),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: ThemeConfig.paddingS),
                Badge(
                  isLabelVisible: _hasActiveFilters,
                  backgroundColor: ThemeConfig.primaryColor,
                  child: IconButton(
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: _hasActiveFilters
                          ? ThemeConfig.primaryColor
                          : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Filters Panel
          if (_showFilters) _buildFiltersPanel(menuProvider),

          // Sort Options
          _buildSortBar(),

          // Results
          Expanded(
            child: _buildSearchResults(menuProvider),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _vegFilter != null ||
        _halalFilter != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _minSpicyLevel != null ||
        _maxSpicyLevel != null ||
        _selectedLabels.isNotEmpty;
  }

  Widget _buildFiltersPanel(MenuProvider menuProvider) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dietary filters
          Row(
            children: [
              const Text(
                'Dietary:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: ThemeConfig.paddingM),
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco,
                      size: 16,
                      color: _vegFilter == true
                          ? Colors.white
                          : ThemeConfig.vegColor,
                    ),
                    const SizedBox(width: 4),
                    const Text('Veg'),
                  ],
                ),
                selected: _vegFilter == true,
                selectedColor: ThemeConfig.vegColor,
                onSelected: (selected) {
                  setState(() {
                    _vegFilter = selected ? true : null;
                  });
                  _performSearch(refresh: true);
                },
              ),
              const SizedBox(width: ThemeConfig.paddingS),
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: _halalFilter == true
                          ? Colors.white
                          : ThemeConfig.halalColor,
                    ),
                    const SizedBox(width: 4),
                    const Text('Halal'),
                  ],
                ),
                selected: _halalFilter == true,
                selectedColor: ThemeConfig.halalColor,
                onSelected: (selected) {
                  setState(() {
                    _halalFilter = selected ? true : null;
                  });
                  _performSearch(refresh: true);
                },
              ),
            ],
          ),
          const SizedBox(height: ThemeConfig.paddingM),

          // Price Range
          Row(
            children: [
              const Text(
                'Price:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: ThemeConfig.paddingM),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Min',
                          prefixText: '\$',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: ThemeConfig.paddingS,
                            vertical: ThemeConfig.paddingS,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
                          ),
                        ),
                        onChanged: (value) {
                          _minPrice = double.tryParse(value);
                        },
                        onSubmitted: (_) => _performSearch(refresh: true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: ThemeConfig.paddingS),
                      child: Text('-'),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Max',
                          prefixText: '\$',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: ThemeConfig.paddingS,
                            vertical: ThemeConfig.paddingS,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
                          ),
                        ),
                        onChanged: (value) {
                          _maxPrice = double.tryParse(value);
                        },
                        onSubmitted: (_) => _performSearch(refresh: true),
                      ),
                    ),
                    const SizedBox(width: ThemeConfig.paddingS),
                    IconButton(
                      icon: const Icon(Icons.check, size: 20),
                      onPressed: () => _performSearch(refresh: true),
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConfig.paddingM),

          // Spicy Level
          Row(
            children: [
              const Text(
                'Spicy:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: ThemeConfig.paddingM),
              Expanded(
                child: Wrap(
                  spacing: ThemeConfig.paddingS,
                  children: List.generate(5, (index) {
                    final level = index + 1;
                    final isSelected = (_minSpicyLevel == null && _maxSpicyLevel == null)
                        ? false
                        : (level >= (_minSpicyLevel ?? 1) && level <= (_maxSpicyLevel ?? 5));
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          level,
                          (i) => Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : ThemeConfig.errorColor,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: ThemeConfig.errorColor,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _minSpicyLevel = level;
                            _maxSpicyLevel = level;
                          } else {
                            _minSpicyLevel = null;
                            _maxSpicyLevel = null;
                          }
                        });
                        _performSearch(refresh: true);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConfig.paddingM),

          // Labels
          if (menuProvider.labels.isNotEmpty) ...[
            const Text(
              'Labels:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: ThemeConfig.paddingS),
            Wrap(
              spacing: ThemeConfig.paddingS,
              runSpacing: ThemeConfig.paddingS,
              children: menuProvider.labels.map((label) {
                final isSelected = _selectedLabels.contains(label.name);
                return FilterChip(
                  label: Text(label.name),
                  selected: isSelected,
                  selectedColor: ThemeConfig.accentColor,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLabels.add(label.name);
                      } else {
                        _selectedLabels.remove(label.name);
                      }
                    });
                    _performSearch(refresh: true);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: ThemeConfig.paddingM),
          ],

          // Clear Filters
          if (_hasActiveFilters)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
                onPressed: _clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: ThemeConfig.errorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.paddingM,
        vertical: ThemeConfig.paddingS,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Sort by:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(width: ThemeConfig.paddingS),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Rating', 'rating_desc', Icons.star),
                  _buildSortChip('Price ↑', 'price_asc', Icons.arrow_upward),
                  _buildSortChip('Price ↓', 'price_desc', Icons.arrow_downward),
                  _buildSortChip('Newest', 'newest', Icons.new_releases),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sortOption == value;
    return Padding(
      padding: const EdgeInsets.only(right: ThemeConfig.paddingS),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : ThemeConfig.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        selectedColor: ThemeConfig.primaryColor,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _sortOption = value;
            });
            _performSearch(refresh: true);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(MenuProvider menuProvider) {
    if (menuProvider.isLoading && menuProvider.menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (menuProvider.error != null && menuProvider.menuItems.isEmpty) {
      return Center(
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
              menuProvider.error!,
              style: const TextStyle(color: ThemeConfig.textSecondaryColor),
            ),
            const SizedBox(height: ThemeConfig.paddingM),
            ElevatedButton(
              onPressed: () => _performSearch(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (menuProvider.menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: ThemeConfig.paddingM),
            const Text(
              'No menu items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ThemeConfig.paddingS),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: ThemeConfig.textSecondaryColor),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _performSearch(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(ThemeConfig.paddingM),
        // Only add extra item for loading indicator if we're loading more (not initial load)
        itemCount: menuProvider.menuItems.length + (_isLoadingMore && menuProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= menuProvider.menuItems.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(ThemeConfig.paddingM),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = menuProvider.menuItems[index];
          return _buildMenuItemCard(item);
        },
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final cartProvider = context.read<CartProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConfig.paddingM),
      child: InkWell(
        onTap: () => context.push('/menu-item/${item.id}'),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: ThemeConfig.primaryGradient,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.restaurant, color: Colors.white, size: 40),
                        ),
                      )
                    : const Icon(Icons.restaurant, color: Colors.white, size: 40),
              ),
              const SizedBox(width: ThemeConfig.paddingM),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Veg/Non-veg indicator
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: item.isVeg
                                  ? ThemeConfig.vegColor
                                  : ThemeConfig.nonVegColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.isVeg
                                    ? ThemeConfig.vegColor
                                    : ThemeConfig.nonVegColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ThemeConfig.paddingS),
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ThemeConfig.paddingXS),

                    if (item.description != null)
                      Text(
                        item.description!,
                        style: const TextStyle(
                          color: ThemeConfig.textSecondaryColor,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: ThemeConfig.paddingS),

                    // Tags row
                    Wrap(
                      spacing: ThemeConfig.paddingXS,
                      runSpacing: ThemeConfig.paddingXS,
                      children: [
                        if (item.isHalal)
                          _buildTag('Halal', ThemeConfig.halalColor),
                        if (item.spicyLevel != null && item.spicyLevel! > 0)
                          _buildSpicyTag(item.spicyLevel!),
                        if (item.labels != null)
                          ...item.labels!.take(2).map(
                            (label) => _buildTag(label.name, ThemeConfig.accentColor),
                          ),
                      ],
                    ),
                    const SizedBox(height: ThemeConfig.paddingS),

                    // Price and rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.cost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: ThemeConfig.primaryColor,
                          ),
                        ),
                        if (item.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: ThemeConfig.warningColor,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add to cart button
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: ThemeConfig.primaryColor,
                    iconSize: 32,
                    onPressed: () async {
                      final success = await cartProvider.addItem(
                        itemId: item.id,
                        quantity: 1,
                      );
                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.itemName} added to cart'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () => context.push('/cart'),
                            ),
                          ),
                        );
                      } else {
                        // Show dialog to clear cart and add new item
                        _showDifferentKitchenDialog(item, cartProvider);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifferentKitchenDialog(MenuItem item, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Different Kitchen'),
        content: const Text(
          'Your cart contains items from a different kitchen. Would you like to clear your cart and add this item instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await cartProvider.clearCart();
              await cartProvider.addItem(
                itemId: item.id,
                quantity: 1,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.itemName} added to cart'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear & Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSpicyTag(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: ThemeConfig.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          level.clamp(1, 5),
          (index) => const Icon(
            Icons.local_fire_department,
            size: 12,
            color: ThemeConfig.errorColor,
          ),
        ),
      ),
    );
  }
}
