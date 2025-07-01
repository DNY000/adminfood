// import 'package:admin/models/cart_item_model.dart';
// import 'package:flutter/foundation.dart';

// class CartViewModel extends ChangeNotifier {
//   List<CartItemModel> _items = [];
//   String? _error;

//   List<CartItemModel> get items => _items;
//   String? get error => _error;
//   bool get isEmpty => _items.isEmpty;

//   double get totalAmount {
//     return _items.fold(0, (sum, item) => sum + item.price * item.quantity);
//   }

//   void addToCart(CartItemModel item) {
//     try {
//       // Kiểm tra xem món ăn đã có trong giỏ hàng chưa
//       final existingIndex = _items.indexWhere((i) => i.foodId == item.foodId);

//       if (existingIndex >= 0) {
//         // Nếu có rồi thì cập nhật số lượng
//         final existingItem = _items[existingIndex];
//         _items[existingIndex] = existingItem.copyWith(
//           quantity: existingItem.quantity + item.quantity,
//         );
//       } else {
//         // Nếu chưa có thì thêm mới
//         _items.add(item);
//       }

//       _error = null;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }

//   void removeFromCart(String foodId) {
//     try {
//       _items.removeWhere((item) => item.foodId == foodId);
//       _error = null;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }

//   void updateQuantity(String foodId, int quantity) {
//     try {
//       final index = _items.indexWhere((item) => item.foodId == foodId);
//       if (index >= 0) {
//         if (quantity > 0) {
//           _items[index] = _items[index].copyWith(quantity: quantity);
//         } else {
//           _items.removeAt(index);
//         }
//         _error = null;
//         notifyListeners();
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }

//   void clearCart() {
//     _items = [];
//     _error = null;
//     notifyListeners();
//   }

//   // Get cart item by food ID
//   CartItemModel? getCartItemByFoodId(String foodId) {
//     try {
//       final index = _items.indexWhere((item) => item.foodId == foodId);
//       if (index >= 0) {
//         return _items[index];
//       }
//       return null;
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return null;
//     }
//   }

//   // Update cart item
//   void updateCartItem(CartItemModel item) {
//     try {
//       final index = _items.indexWhere((i) => i.foodId == item.foodId);
//       if (index >= 0) {
//         _items[index] = item;
//         _error = null;
//         notifyListeners();
//       } else {
//         // If item doesn't exist, add it
//         addToCart(item);
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }

//   // Lấy danh sách các món trong giỏ hàng theo restaurantId
//   List<CartItemModel> getCartItemsByRestaurant(String restaurantId) {
//     return _items.where((item) => item.restaurantId == restaurantId).toList();
//   }

//   // Tính tổng tiền các món trong giỏ hàng theo restaurantId
//   double getTotalAmountByRestaurant(String restaurantId) {
//     return _items
//         .where((item) => item.restaurantId == restaurantId)
//         .fold(0, (sum, item) => sum + item.price * item.quantity);
//   }

//   void updateCartItemQuantity(String foodId, int quantity) {
//     try {
//       final index = _items.indexWhere((item) => item.foodId == foodId);
//       if (index >= 0) {
//         _items[index] = _items[index].copyWith(quantity: quantity);
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }

//   void removeItemsByRestaurant(String restaurantId) async {
//     // 1. Lấy danh sách các món ăn thuộc nhà hàng này
//     final itemsToRemove =
//         _items.where((item) => item.restaurantId == restaurantId).toList();

//     // 2. Lưu vào storage
//     if (itemsToRemove.isNotEmpty) {
//       final storage = TLocalStorage.instance();

//       // Chuyển đổi sang dạng JSON để lưu
//       final List<Map<String, dynamic>> jsonList =
//           itemsToRemove.map((item) => item.toJson()).toList();

//       // Lưu vào storage
//       await storage.saveData('cart_backup_${restaurantId}', jsonList);

//       // Lưu danh sách ID để phục hồi sau
//       List<String> ids =
//           storage.readData<List<dynamic>>('cart_backup_ids')?.cast<String>() ??
//           [];
//       if (!ids.contains(restaurantId)) {
//         ids.add(restaurantId);
//         await storage.saveData('cart_backup_ids', ids);
//       }

//       // In ra danh sách món ăn đã xử lý
//       print('Đã lưu đơn nháp cho nhà hàng $restaurantId:');
//       for (var item in itemsToRemove) {
//         print('  - ${item.foodName} x${item.quantity}');
//       }

//       // ✅ Đọc lại từ storage và in ra để kiểm tra
//       final savedData = await storage.readData<List<dynamic>>(
//         'cart_backup_${restaurantId}',
//       );
//       print(' ');
//       print('Dữ liệu trong storage (raw data):');
//       if (savedData != null) {
//         for (var itemJson in savedData) {
//           print('  $itemJson');
//         }
//       } else {
//         print('  ❌ Không tìm thấy dữ liệu trong storage.');
//       }
//       print(' ');

//       // 3. Xóa khỏi giỏ hàng
//       _items.removeWhere((item) => item.restaurantId == restaurantId);

//       notifyListeners();
//     }
//   }
// }
