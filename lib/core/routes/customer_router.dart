import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/kitchen/screens/kitchen_list_screen.dart';
import '../../features/kitchen/screens/kitchen_detail_screen.dart';
import '../../features/menu/screens/menu_search_screen.dart';
import '../../features/menu/screens/menu_item_detail_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/order/screens/checkout_screen.dart';
import '../../features/order/screens/order_list_screen.dart';
import '../../features/order/screens/order_detail_screen.dart';
import '../../features/delivery/screens/delivery_tracking_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../services/storage_service.dart';

/// Router specifically for Customer App
class CustomerRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/kitchens',
        name: 'kitchens',
        builder: (context, state) => const KitchenListScreen(),
      ),
      GoRoute(
        path: '/kitchen/:id',
        name: 'kitchenDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return KitchenDetailScreen(kitchenId: id);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const MenuSearchScreen(),
      ),
      GoRoute(
        path: '/menu-item/:id',
        name: 'menuItemDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MenuItemDetailScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        name: 'orderDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/delivery/:id',
        name: 'deliveryTracking',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DeliveryTrackingScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final title = state.uri.queryParameters['title'] ?? 'Chat';
          return ChatScreen(conversationId: id, title: title);
        },
      ),
    ],
    redirect: (context, state) async {
      final token = await StorageService.getAccessToken();
      final isAuthenticated = token != null;

      final isGoingToAuth = state.matchedLocation == '/login' ||
                            state.matchedLocation == '/register' ||
                            state.matchedLocation == '/splash';

      if (!isAuthenticated && !isGoingToAuth) {
        return '/login';
      }

      if (isAuthenticated && isGoingToAuth && state.matchedLocation != '/splash') {
        return '/';
      }

      return null;
    },
  );
}

