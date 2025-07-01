import 'package:admin/models/banner_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final BannerRepository instance = BannerRepository._internal();
  BannerRepository._internal();
  Future<List<BannerModel>> getListBanner() async {
    try {
      final snapshot = await _firestore.collection('banner').get();
      return snapshot.docs.map((e) {
        final data = e.data();
        return BannerModel.fromMap(data, e.id);
      }).toList();
    } catch (e) {
      throw "Faile $e";
    }
  }

  Future<BannerModel> getBannerById(String id) async {
    try {
      final snapshot = await _firestore.collection('banner').doc(id).get();
      return BannerModel.fromMap(snapshot.data() ?? {}, snapshot.id);
    } catch (e) {
      throw "Fai; $e";
    }
  }

  Future<void> addBanner(BannerModel banner) async {
    try {
      await _firestore.collection('banner').add(banner.toMap());
    } catch (e) {
      throw "Fail $e";
    }
  }

  Future<void> updateBanner(BannerModel banner, String id) async {
    try {
      await _firestore.collection("banner").doc(id).update(banner.toMap());
    } catch (e) {
      throw "Fail $e";
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection("banner").doc(bannerId).delete();
    } catch (e) {
      throw "Fail $e";
    }
  }
}
