class NameRouter {
  // User-app related routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';
  static const String signleFood = '/signle_food';
  static const String notificationDetail = '/notification_detail';

  // Admin panel base routes (list views)
  static const String dashboard = '/dashboard';
  static const String categories = '/categories';
  static const String restaurants = '/restaurants';
  static const String shippers = '/shippers';
  static const String users = '/users';
  static const String banner = '/banner';
  static const String orders = '/orders';
  static const String promotions = '/promotions';
  static const String feedbacks = '/feedbacks';
  static const String notifications = '/notifications';

  // Admin CRUD and Search Routes
  // Restaurants
  static const String detailRestaurants = '/detail_restaurants';
  static const String restaurantDetail = '/restaurants/:id';
  static const String searchRestaurants = '/restaurants/search';

  // Restaurant Detail Tabs Routes
  static const String restaurantFoods = '/detail_restaurants/:id/foods';
  static const String restaurantStats = '/detail_restaurants/:id/stats';
  static const String restaurantOrders = '/detail_restaurants/:id/orders';

  // Restaurant Foods CRUD Routes
  static const String restaurantFoodDetail =
      '/detail_restaurants/:id/foods/:foodId';

  // Category
  static const String categoryDetail = '/categories/:id';
  static const String searchCategories = '/categories/search';

  // Banners
  static const String bannerDetail = '/banner/:id';
  static const String searchBanners = '/banner/search';

  // Shippers
  static const String shipperDetail = '/shippers/:id';
  static const String searchShippers = '/shippers/search';

  // Users
  static const String userDetail = '/users/:id';
  static const String searchUsers = '/users/search';
}
