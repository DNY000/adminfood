import 'package:flutter/foundation.dart';
import 'package:admin/models/restaurant_model.dart';
import 'package:admin/data/repositories/restaurant_repository.dart';

class RestaurantViewModel extends ChangeNotifier {
  final RestaurantRepository _repository;
  List<RestaurantModel> _restaurants = [];
  RestaurantModel? _selectedRestaurant;
  bool _isLoading = false;
  String? _error;

  RestaurantViewModel(this._repository);

  // Getters
  List<RestaurantModel> get restaurants => _restaurants;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load tất cả nhà hàng
  Future<void> loadRestaurants() async {
    _setLoading(true);
    try {
      _restaurants = await _repository.getRestaurants();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách nhà hàng: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load nhà hàng theo ID
  Future<String> loadRestaurantById(String id) async {
    _setLoading(true);
    try {
      _selectedRestaurant = await _repository.getRestaurantById(id);
      _error = null;

      return _selectedRestaurant?.name ?? '';
    } catch (e) {
      _error = 'Không thể tải thông tin nhà hàng: $e';

      return '';
    } finally {
      _setLoading(false);
    }
  }

  // Lọc nhà hàng theo danh mục
  Future<void> loadRestaurantsByCategory(String category) async {
    _setLoading(true);
    try {
      _restaurants = await _repository.getRestaurantsByCategory(category);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải nhà hàng theo danh mục: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Tìm kiếm nhà hàng
  List<RestaurantModel> searchRestaurants(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _restaurants.where((restaurant) {
      return restaurant.name.toLowerCase().contains(lowercaseQuery) ||
          restaurant.address.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Helper method để set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> addRestaurant(RestaurantModel restaurant) async {
    _setLoading(true);
    try {
      await _repository.addRestaurant(restaurant);
      _error = null;
    } catch (e) {
      _error = 'Không thể thêm nhà hàng: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    _setLoading(true);
    try {
      await _repository.updateRestaurant(restaurant);
      _error = null;
    } catch (e) {
      _error = 'Không thể cập nhật nhà hàng: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteRestaurant(String restaurantId) async {
    _setLoading(true);
    try {
      await _repository.deleteRestaurant(restaurantId);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Không thể xóa nhà hàng: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
