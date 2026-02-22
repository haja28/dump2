import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_type.dart';
import 'core/config/theme_config.dart';
import 'core/routes/kitchen_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/kitchen/providers/kitchen_provider.dart';
import 'features/menu/providers/menu_provider.dart';
import 'features/order/providers/order_provider.dart';
import 'features/chat/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set app type to Kitchen
  AppTypeConfig.setAppType(AppType.kitchen);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize services
  await StorageService.init();
  await ApiService.init();

  // Set system UI overlay style - Kitchen app uses darker theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Optimize frame scheduling to prevent buffer queue issues
  SchedulerBinding.instance.scheduleForcedFrame();

  runApp(const KitchenApp());
}

class KitchenApp extends StatelessWidget {
  const KitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp.router(
        title: AppTypeConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.kitchenLightTheme,
        darkTheme: ThemeConfig.kitchenDarkTheme,
        themeMode: ThemeMode.light,
        routerConfig: KitchenRouter.router,
      ),
    );
  }
}

