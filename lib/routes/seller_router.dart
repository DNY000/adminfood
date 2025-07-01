class SellerRouter {
  // Seller dashboard and main routes
  static const String dashboard = '/seller/dashboard';
  static const String overview = '/seller/overview';
  static const String registerRestaurant = '/seller/register-restaurant';

  // Food management routes
  static const String foods = '/seller/foods';
  static const String foodDetail = '/seller/foods/:id';
  static const String addFood = '/seller/foods/add';
  static const String editFood = '/seller/foods/:id/edit';
  static const String searchFoods = '/seller/foods/search';

  // Order management routes
  static const String orders = '/seller/orders';
  static const String orderDetail = '/seller/orders/:id';
  static const String searchOrders = '/seller/orders/search';

  // Restaurant profile routes
  static const String profile = '/seller/profile';
  static const String editProfile = '/seller/profile/edit';
  static const String settings = '/seller/settings';
}
