import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/data/repositories/food_repository.dart';
import 'package:admin/data/repositories/order_repository.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/screens/authentication/viewmodels/auth_viewmodel.dart';
import 'package:admin/viewmodels/banner_viewmode.dart';
import 'package:admin/viewmodels/category_viewmodel.dart';
import 'package:admin/viewmodels/food_viewmodel.dart';
import 'package:admin/viewmodels/order_viewmodel.dart';
import 'package:admin/viewmodels/user_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/shipper_viewmodel.dart';
import 'package:admin/data/repositories/shipper_repository.dart';
import 'package:admin/viewmodels/restaurant_viewmodel.dart';
import 'package:admin/data/repositories/restaurant_repository.dart';
import 'package:admin/routes/page_router.dart'; // hoặc name_router.dart
import 'package:admin/ultils/local_storage/storage_utilly.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   // Xử lý message ở đây nếu muốn
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await TLocalStorage.init('admin_storage'); // Initialize TLocalStorage here
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        Provider<ShipperRepository>(
          create: (_) => ShipperRepository(),
        ),
        Provider<RestaurantRepository>(
          create: (_) => RestaurantRepository(),
        ),
        Provider<FoodRepository>(
          create: (_) => FoodRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ShipperViewModel(context.read<ShipperRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantViewModel(context.read<RestaurantRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FoodViewModel(context.read<FoodRepository>()),
        ),
        Provider<OrderRepository>(create: (_) => OrderRepository()),
        ChangeNotifierProvider(
          create: (context) => OrderViewModel(context.read<OrderRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => BannerViewmode()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        // textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
        //     .apply(bodyColor: Colors.white),
        // canvasColor: secondaryColor,
      ),
      // <-- Sử dụng GoRouter ở đây
    );
  }
}
