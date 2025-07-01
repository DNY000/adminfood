import 'package:admin/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection("categories").get();
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return CategoryModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách danh mục: $e');
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final snapshot = await _firestore.collection("categories").doc(id).get();
      return CategoryModel.fromMap(snapshot.data() ?? {}, snapshot.id);
    } catch (e) {
      throw Exception('Không thể lấy danh mục theo id: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection("categories").doc(id).delete();
    } catch (e) {
      throw Exception('Không thể xóa danh mục: $e');
    }
  }

  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      await _firestore
          .collection("categories")
          .doc(id)
          .update(category.toMap());
    } catch (e) {
      throw Exception('Không thể cập nhật danh mục: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection("categories").add(category.toMap());
    } catch (e) {
      throw Exception('Không thể thêm danh mục: $e');
    }
  }
}
