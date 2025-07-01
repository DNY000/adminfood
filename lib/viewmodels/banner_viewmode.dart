import 'package:admin/data/repositories/banner_repository.dart';
import 'package:admin/models/banner_model.dart';
import 'package:flutter/material.dart';

class BannerViewmode extends ChangeNotifier {
  List<BannerModel> _listBanner = [];
  BannerModel? _currentBanner;
  bool _isLoading = false;
  final _bannerRepository = BannerRepository.instance;
  // get
  List<BannerModel> get listBanner => _listBanner;
  bool get isLoading => _isLoading;
  //
  Future<void> getListBanner() async {
    try {
      _isLoading = true;
      notifyListeners();
      _listBanner = await _bannerRepository.getListBanner();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      throw "Fail $e";
    } finally {
      _isLoading = false;
    }
  }

  Future<void> getBannerById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentBanner = await _bannerRepository.getBannerById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      throw "Fail $e";
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addBanner(BannerModel banner) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _bannerRepository.addBanner(banner);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      throw "Fail $e";
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateBanner(BannerModel banner, String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _bannerRepository.updateBanner(banner, id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      throw "Fail $e";
    } finally {
      _isLoading = false;
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _bannerRepository.deleteBanner(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      throw "Fail $e";
    } finally {
      _isLoading = false;
    }
  }
}
