import 'package:admin/screens/authentication/srceen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin/main.dart';
import 'package:admin/routes/name_router.dart';
import 'package:admin/routes/seller_router.dart';
import 'package:admin/screens/authentication/srceen/login_screen.dart';
import 'package:admin/screens/category/category_screen.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/notifications/notification_screen.dart';
import 'package:admin/screens/restaurant/restaurant_detail_screen.dart';
import 'package:admin/screens/restaurant/restaurant_screen.dart';
import 'package:admin/screens/shipper/shipper_screen.dart';
import 'package:admin/screens/users/users_screen.dart';
import 'package:admin/screens/banner/banner_screen.dart';
import 'package:admin/screens/setting/setting_screen.dart';
import 'package:admin/screens/seller/seller_dashboard_screen.dart';
import 'package:admin/screens/seller/seller_food_management_screen.dart';
import 'package:admin/screens/seller/seller_order_management_screen.dart';
import 'package:admin/screens/seller/seller_overview_screen.dart';
import 'package:admin/screens/seller/overview/register_restaurant_screen.dart';
// Import PlaceholderScreen nếu cần, hoặc định nghĩa nó ở cuối file
// import 'package:admin/screens/placeholder_screen.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: NameRouter.login,
  // redirect: (context, state) {
  //   // Lấy trạng thái đăng nhập từ AuthViewModel hoặc FirebaseAuth
  //   final isLoggedIn = FirebaseAuth.instance.currentUser != null;
  //   final isLoginPage = state.uri.toString() == NameRouter.login;

  //   if (isLoggedIn && isLoginPage) {
  //     // Nếu đã đăng nhập mà vào trang login thì chuyển sang dashboard
  //     return NameRouter.dashboard;
  //   }
  //   if (!isLoggedIn && !isLoginPage) {
  //     // Nếu chưa đăng nhập và không ở trang login thì chuyển về login
  //     return NameRouter.login;
  //   }

  //   // Không cần chuyển hướng nếu các điều kiện trên không đúng (đã đăng nhập và không ở login, hoặc chưa đăng nhập và đang ở login)
  //   return null;
  // },
  routes: [
    // Màn hình onboarding
    GoRoute(
      path: NameRouter.dashboard,
      builder: (context, state) => const MainScreen(),
    ),

    // Màn hình login
    GoRoute(
      path: NameRouter.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: NameRouter.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // Seller Routes
    GoRoute(
      path: SellerRouter.dashboard,
      builder: (context, state) => const SellerDashboardScreen(),
    ),
    GoRoute(
      path: SellerRouter.overview,
      builder: (context, state) => const SellerOverviewScreen(),
    ),
    GoRoute(
      path: SellerRouter.foods,
      builder: (context, state) {
        final restaurantId = state.uri.queryParameters['restaurantId'] ?? '';
        return SellerFoodScreen(restaurantId: restaurantId);
      },
    ),
    GoRoute(
      path: SellerRouter.orders,
      builder: (context, state) => const SellerOrderManagementScreen(),
    ),
    GoRoute(
      path: SellerRouter.registerRestaurant,
      builder: (context, state) => const RegisterRestaurantScreen(),
    ),
    // GoRoute(
    //   path: SellerRouter.settings,
    //   builder: (context, state) => const SellerSettingsScreen(),
    // ),
    GoRoute(
      path: SellerRouter.addFood,
      builder: (context, state) {
        final restaurantId = state.uri.queryParameters['restaurantId'] ?? '';
        return SellerFoodScreen(
            showAddDialog: true, restaurantId: restaurantId);
      },
    ),
    GoRoute(
      path: SellerRouter.editFood,
      builder: (context, state) {
        final foodId = state.pathParameters['id'] ?? '';
        final restaurantId = state.uri.queryParameters['restaurantId'] ?? '';
        return SellerFoodScreen(
          showUpdateDialog: true,
          foodId: foodId,
          restaurantId: restaurantId,
        );
      },
    ),
    GoRoute(
      path: SellerRouter.foodDetail,
      builder: (context, state) {
        final foodId = state.pathParameters['id'] ?? '';
        final restaurantId = state.uri.queryParameters['restaurantId'] ?? '';
        return SellerFoodScreen(
          foodId: foodId,
          restaurantId: restaurantId,
        );
      },
    ),

    // Home
    GoRoute(
      path: NameRouter.categories,
      builder: (context, state) => const CategoryScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) =>
              const CategoryScreen(showAddDialog: true),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final categoryId = state.pathParameters['id'] ?? '';
            return CategoryScreen(
                showUpdateDialog: true, categoryId: categoryId);
          },
        ),
      ],
    ),
    GoRoute(
      path: NameRouter.searchCategories,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'] ?? '';
        return PlaceholderScreen(title: 'Search Categories: $searchQuery');
      },
    ),

    // Restaurants List and Add route (if using dialog on list screen)
    GoRoute(
      path: NameRouter.restaurants,
      builder: (context, state) =>
          const RestaurantScreen(), // Main Restaurant list screen
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const RestaurantScreen(
              showAddDialog: true), // Route for showing add dialog
        ),
        // Removed the :id nested route under /restaurants as it conflicts with /detail_restaurants/:id
        // GoRoute(
        //   path: ':id',
        //   builder: (context, state) { ... },
        // ),
      ],
    ),
    GoRoute(
      path: NameRouter.searchRestaurants,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'] ?? '';
        return PlaceholderScreen(title: 'Search Restaurants: $searchQuery');
      },
    ),

    // Restaurant Detail with ID parameter
    GoRoute(
      path:
          '${NameRouter.detailRestaurants}/:id', // Correct path with :id parameter
      builder: (context, state) {
        final restaurantId = state.pathParameters['id'] ?? '';
        // Extract initialTab, and food dialog parameters from query parameters
        final initialTab =
            int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        final showAddFoodDialog =
            state.uri.queryParameters['showAddFoodDialog'] == 'true';
        final showUpdateFoodDialog =
            state.uri.queryParameters['showUpdateFoodDialog'] == 'true';
        final foodId = state.uri.queryParameters['foodId'];

        return RestaurantDetailScreen(
          restaurantId: restaurantId,
          initialTab: initialTab,
          showAddFoodDialog: showAddFoodDialog,
          showUpdateFoodDialog: showUpdateFoodDialog,
          foodId: foodId,
        );
      },
      routes: [
        // Optional: Define nested routes if needed, but handling via query params is often simpler for dialogs/tabs
        // GoRoute(path: 'foods/add', ...),
        // GoRoute(path: 'foods/:foodId', ...),
      ],
    ),

    // Shippers
    GoRoute(
      path: NameRouter.shippers,
      builder: (context, state) => const ShipperScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const ShipperScreen(showAddDialog: true),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final shipperId = state.pathParameters['id'] ?? '';
            return ShipperScreen(showUpdateDialog: true, shipperId: shipperId);
          },
        ),
      ],
    ),
    GoRoute(
      path: NameRouter.searchShippers,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'] ?? '';
        return PlaceholderScreen(title: 'Search Shippers: $searchQuery');
      },
    ),

    // Users
    GoRoute(
      path: NameRouter.users,
      builder: (context, state) => const UsersScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const UsersScreen(showAddDialog: true),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final userId = state.pathParameters['id'] ?? '';
            return UsersScreen(showUpdateDialog: true, userId: userId);
          },
        ),
      ],
    ),
    GoRoute(
      path: NameRouter.searchUsers,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'] ?? '';
        return PlaceholderScreen(title: 'Search Users: $searchQuery');
      },
    ),

    // Banners
    GoRoute(
      path: NameRouter.banner,
      builder: (context, state) => const BannerScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const BannerScreen(showAddDialog: true),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final bannerId = state.pathParameters['id'] ?? '';
            return BannerScreen(showUpdateDialog: true, bannerId: bannerId);
          },
        ),
      ],
    ),
    GoRoute(
      path: NameRouter.searchBanners,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'] ?? '';
        return PlaceholderScreen(title: 'Search Banners: $searchQuery');
      },
    ),

    // Add/Update/Delete for other top-level entities (Categories, Banners, Shippers, Users)
    // Add these routes if you want separate screens or dialogs for CRUD on the list views

    GoRoute(
      path: NameRouter.settings,
      builder: (context, state) => const SettingScreen(),
    ),

    GoRoute(
      path: NameRouter.notifications,
      builder: (context, state) => const NotificationScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final notificationId = state.pathParameters['id'] ?? '';
            // TODO: Replace with actual NotificationDetailScreen
            return PlaceholderScreen(
                title: 'Notification Detail: $notificationId');
          },
        ),
      ],
    ),
    // Add routes for Shippers, Users, Banner, Orders, Promotions, Feedbacks if they have dedicated screens
  ],
);

// Define a simple PlaceholderScreen for now
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('This is a placeholder for: $title'),
      ),
    );
  }
}
