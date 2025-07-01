import 'package:flutter/foundation.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/data/repositories/shipper_repository.dart';

class ShipperViewModel extends ChangeNotifier {
  final ShipperRepository _repository;
  List<ShipperModel> _shippers = [];
  ShipperModel? _selectedShipper;
  bool _isLoading = false;
  String? _error;

  ShipperViewModel(this._repository);

  // Getters
  List<ShipperModel> get shippers => _shippers;
  ShipperModel? get selectedShipper => _selectedShipper;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load tất cả shipper
  Future<void> loadShippers() async {
    _setLoading(true);
    try {
      _shippers = await _repository.getShippers();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách shipper: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load shipper theo ID
  Future<void> loadShipperById(String id) async {
    _setLoading(true);
    try {
      _selectedShipper = await _repository.getShipperById(id);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải thông tin shipper: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Thêm shipper mới
  Future<void> addShipper(ShipperModel shipper) async {
    _setLoading(true);
    try {
      await _repository.addShipper(shipper);
      await loadShippers(); // Refresh list after adding
      _error = null;
    } catch (e) {
      _error = 'Không thể thêm shipper: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật thông tin shipper
  Future<void> updateShipper(String id, ShipperModel shipper) async {
    _setLoading(true);
    try {
      await _repository.updateShipper(id, shipper);
      // Refresh danh sách sau khi cập nhật
      await loadShippers();
      _error = null;
    } catch (e) {
      _error = 'Không thể cập nhật thông tin shipper: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Xóa shipper
  Future<void> deleteShipper(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteShipper(id);
      // Refresh danh sách sau khi xóa
      await loadShippers();
      _error = null;
    } catch (e) {
      _error = 'Không thể xóa shipper: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Lọc shipper theo trạng thái
  List<ShipperModel> getShippersByStatus(String status) {
    return _shippers.where((shipper) => shipper.status == status).toList();
  }

  // Tìm kiếm shipper
  List<ShipperModel> searchShippers(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _shippers.where((shipper) {
      return shipper.name.toLowerCase().contains(lowercaseQuery) ||
          shipper.phoneNumber.contains(lowercaseQuery) ||
          shipper.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Helper method để set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
