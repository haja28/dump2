import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/cart_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/coupon_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, _) {
              if (provider.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.cart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.isEmpty) {
            return _buildEmptyCart(context);
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshCart(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cart expiration warning
                        if (provider.cart!.isExpiringSoon)
                          _buildExpirationWarning(provider.cart!),

                        // Price change warnings
                        if (provider.cart!.hasPriceChanges)
                          _buildPriceChangeWarnings(provider.cart!),

                        // Stock warnings
                        if (provider.cart!.hasStockIssues)
                          _buildStockWarnings(provider.cart!),

                        // General warnings
                        if (provider.hasWarnings &&
                            !provider.cart!.isExpiringSoon &&
                            !provider.cart!.hasPriceChanges &&
                            !provider.cart!.hasStockIssues)
                          ...provider.warnings.map((w) => _buildWarningCard(w, Colors.amber)),

                        const SizedBox(height: 16),

                        // Kitchen info
                        if (provider.cart!.kitchenName != null)
                          _buildKitchenInfo(provider.cart!),

                        const SizedBox(height: 16),

                        // Cart items
                        ...provider.cart!.items.map((item) => _buildCartItem(context, item, provider)),

                        const SizedBox(height: 16),

                        // Coupon section
                        _buildCouponSection(context, provider),

                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),

                // Bottom price summary and checkout button
                _buildBottomSection(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add items to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Browse Menu'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationWarning(CartModel cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '⚠️ Cart expires in ${cart.minutesUntilExpiry} minutes. Complete your order soon!',
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChangeWarnings(CartModel cart) {
    final priceChangedItems = cart.items.where((item) => item.priceChanged).toList();

    return Column(
      children: priceChangedItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            border: Border.all(color: Colors.yellow[700]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.yellow[900], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.yellow[900], fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${item.itemName}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'RM${item.originalPrice?.toStringAsFixed(2)} ',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      TextSpan(
                        text: 'RM${item.currentMenuPrice?.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' (${item.priceDifference >= 0 ? '+' : ''}RM${item.priceDifference.toStringAsFixed(2)})',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockWarnings(CartModel cart) {
    final lowStockItems = cart.items.where((item) => item.isLowStock).toList();

    return Column(
      children: lowStockItems.map((item) {
        return _buildWarningCard(
          'Only ${item.availableStock} left of ${item.itemName}',
          item.availableStock! <= 2 ? Colors.red : Colors.orange,
        );
      }).toList(),
    );
  }

  Widget _buildWarningCard(String message, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenInfo(CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ordering from',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  cart.kitchenName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item, CartProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.itemDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.itemDescription!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.specialRequests != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Special: ${item.specialRequests}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeConfig.primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                Row(
                  children: [
                    // Price
                    Text(
                      'RM${item.unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.primaryColor,
                      ),
                    ),
                    const Spacer(),

                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (item.quantity > 1) {
                                provider.updateCartItem(
                                  cartItemId: item.cartItemId,
                                  quantity: item.quantity - 1,
                                  specialRequests: item.specialRequests,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (item.availableStock == null ||
                                  item.quantity < item.availableStock!) {
                                provider.updateCartItem(
                                  cartItemId: item.cartItemId,
                                  quantity: item.quantity + 1,
                                  specialRequests: item.specialRequests,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Maximum stock reached'),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal: RM${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showRemoveItemDialog(context, item, provider),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context, CartProvider provider) {
    final hasCoupon = provider.cart?.couponCode != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: hasCoupon
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, color: Colors.green[700], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        provider.cart!.couponCode!,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-RM${provider.cart!.discountAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () => provider.removeCoupon(),
                ),
              ],
            )
          : InkWell(
              onTap: () => _showCouponBottomSheet(context),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: ThemeConfig.primaryColor),
                  const SizedBox(width: 12),
                  const Text(
                    'Apply Coupon',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CartProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price breakdown
              _buildPriceRow('Subtotal', provider.subtotal),
              const SizedBox(height: 8),
              _buildPriceRow('Delivery Fee', provider.deliveryFee),
              if (provider.discount > 0) ...[
                const SizedBox(height: 8),
                _buildPriceRow(
                  'Discount',
                  -provider.discount,
                  color: Colors.green,
                ),
              ],
              const Divider(height: 24),
              _buildPriceRow(
                'Total',
                provider.total,
                isBold: true,
                fontSize: 20,
              ),
              const SizedBox(height: 16),

              // Checkout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isValid
                      ? () => _proceedToCheckout(context, provider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: ThemeConfig.primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    provider.isValid
                        ? 'Proceed to Checkout'
                        : 'Cart has issues - Review items',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 16,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          'RM${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showCouponBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CouponBottomSheet(),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    CartItemModel item,
    CartProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.itemName} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeItem(item.cartItemId);
              Navigator.pop(context);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, CartProvider provider) async {
    // Validate cart before proceeding
    final isValid = await provider.validateCart();

    if (!isValid) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Please review cart issues'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      context.push('/checkout');
    }
  }
}
