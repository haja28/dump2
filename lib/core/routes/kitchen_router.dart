import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/kitchen/screens/kitchen_login_screen.dart';
import '../../features/kitchen/screens/kitchen_register_screen.dart';
import '../../features/kitchen/screens/kitchen_dashboard_screen.dart';
import '../../features/kitchen/screens/kitchen_orders_screen.dart';
import '../../features/kitchen/screens/kitchen_menu_screen.dart';
import '../../features/kitchen/screens/kitchen_analytics_screen.dart';
import '../../features/kitchen/screens/kitchen_settings_screen.dart';
import '../../features/kitchen/screens/menu_item_form_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../services/storage_service.dart';

/// Router specifically for Kitchen App
class KitchenRouter {
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
        builder: (context, state) => const KitchenLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const KitchenRegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const KitchenDashboardScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const KitchenOrdersScreen(),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (context, state) => const KitchenMenuScreen(),
      ),
      GoRoute(
        path: '/kitchen/menu/add',
        name: 'addMenuItem',
        builder: (context, state) => const MenuItemFormScreen(),
      ),
      GoRoute(
        path: '/kitchen/menu/edit/:id',
        name: 'editMenuItem',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MenuItemFormScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const KitchenAnalyticsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const KitchenSettingsScreen(),
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

