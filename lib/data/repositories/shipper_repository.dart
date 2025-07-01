import 'package:admin/models/shipper_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShipperRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ShipperModel>> getShippers() async {
    final snapshot = await _firestore.collection('shippers').get();
    return snapshot.docs
        .map((doc) => ShipperModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<ShipperModel> getShipperById(String id) async {
    final doc = await _firestore.collection('shippers').doc(id).get();
    return ShipperModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateShipper(String id, ShipperModel shipper) async {
    await _firestore.collection('shippers').doc(id).update(shipper.toMap());
  }

  Future<void> addShipper(ShipperModel shipper) async {
    await _firestore.collection('shippers').add(shipper.toMap());
  }

  Future<void> deleteShipper(String id) async {
    await _firestore.collection('shippers').doc(id).delete();
  }
}
