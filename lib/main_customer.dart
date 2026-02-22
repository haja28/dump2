import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_type.dart';
import 'core/config/theme_config.dart';
import 'core/routes/customer_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/kitchen/providers/kitchen_provider.dart';
import 'features/menu/providers/menu_provider.dart';
import 'features/order/providers/order_provider.dart';
import 'features/payment/providers/payment_provider.dart';
import 'features/delivery/providers/delivery_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/cart/providers/coupon_provider.dart';
import 'features/chat/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set app type to Customer
  AppTypeConfig.setAppType(AppType.customer);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize services
  await StorageService.init();
  await ApiService.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp.router(
        title: AppTypeConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: CustomerRouter.router,
      ),
    );
  }
}

