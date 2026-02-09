import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/coupon_model.dart';
import '../providers/cart_provider.dart';
import '../providers/coupon_provider.dart';

class CouponBottomSheet extends StatefulWidget {
  const CouponBottomSheet({super.key});

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  final _couponController = TextEditingController();
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Load available coupons when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = context.read<CartProvider>();
      final kitchenId = cartProvider.cart?.kitchenId;
      context.read<CouponProvider>().fetchAvailableCoupons(kitchenId: kitchenId);
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Apply Coupon',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Coupon input
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          prefixIcon: const Icon(Icons.local_offer_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isApplying ? null : _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor: ThemeConfig.primaryColor,
                      ),
                      child: _isApplying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Apply'),
                    ),
                  ],
                ),
              ),

              // Applied coupon indicator
              Consumer<CartProvider>(
                builder: (context, provider, _) {
                  if (provider.cart?.couponCode != null) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.cart!.couponCode!,
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (provider.cart!.couponDescription != null)
                                  Text(
                                    provider.cart!.couponDescription!,
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '-RM${provider.cart!.discountAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 16),

              // Available coupons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Available Coupons',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Coupons list with provider
              Expanded(
                child: Consumer<CouponProvider>(
                  builder: (context, couponProvider, _) {
                    if (couponProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (couponProvider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load coupons',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                couponProvider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final cartProvider = context.read<CartProvider>();
                                  final kitchenId = cartProvider.cart?.kitchenId;
                                  couponProvider.refresh(kitchenId: kitchenId);
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (!couponProvider.hasCoupons) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No coupons available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check back later for exciting offers',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final cartProvider = context.read<CartProvider>();
                        final kitchenId = cartProvider.cart?.kitchenId;
                        await couponProvider.refresh(kitchenId: kitchenId);
                      },
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: couponProvider.coupons.length,
                        itemBuilder: (context, index) {
                          final coupon = couponProvider.coupons[index];
                          return _buildCouponCard(context, coupon);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, CouponModel coupon) {
    final isApplied = context.watch<CartProvider>().cart?.couponCode == coupon.code;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isApplied ? Colors.green[50] : Colors.white,
        border: Border.all(
          color: isApplied ? Colors.green : Colors.grey[300]!,
          width: isApplied ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isApplied)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Coupon icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: ThemeConfig.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Coupon code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            coupon.code,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          if (coupon.remainingUses != null && coupon.remainingUses! <= 10) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${coupon.remainingUses} left',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.discountDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Apply button
                if (!isApplied)
                  OutlinedButton(
                    onPressed: () => _applySpecificCoupon(coupon.code),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConfig.primaryColor,
                      side: BorderSide(color: ThemeConfig.primaryColor),
                    ),
                    child: const Text('Apply'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Applied',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              coupon.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 8),

            // Details
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildCouponDetail(
                  Icons.shopping_bag_outlined,
                  coupon.minOrderDisplay,
                ),
                if (coupon.maxDiscountDisplay.isNotEmpty)
                  _buildCouponDetail(
                    Icons.money_off_outlined,
                    coupon.maxDiscountDisplay,
                  ),
                _buildCouponDetail(
                  Icons.calendar_today_outlined,
                  coupon.validityDisplay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }


  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError('Please enter a coupon code');
      return;
    }

    await _applySpecificCoupon(code);
  }

  Future<void> _applySpecificCoupon(String code) async {
    setState(() => _isApplying = true);

    final provider = context.read<CartProvider>();
    final success = await provider.applyCoupon(code);

    setState(() => _isApplying = false);

    if (!mounted) return;

    if (success) {
      _couponController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon $code applied successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError(provider.error ?? 'Failed to apply coupon');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

