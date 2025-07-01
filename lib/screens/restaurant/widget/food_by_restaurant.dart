import 'dart:typed_data';

import 'package:admin/models/food_model.dart';
import 'package:admin/viewmodels/food_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FoodByRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  const FoodByRestaurantScreen({super.key, required this.restaurantId});

  @override
  State<FoodByRestaurantScreen> createState() => _FoodByRestaurantScreenState();
}

class _FoodByRestaurantScreenState extends State<FoodByRestaurantScreen> {
  String? _selectedFileName;
  late String tokenR;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Lấy restaurant theo id, rồi lấy token
      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();
      if (restaurantDoc.exists) {
        final data = restaurantDoc.data();
        final token = data?['token'];
        tokenR = token;
        if (token != null) {
          context.read<FoodViewModel>().fetchFoodsByRestaurant(token);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddFoodDialog(context, widget.restaurantId);
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm món ăn'),
      ),
      body: Consumer<FoodViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          final foods = viewModel.foods;
          if (foods.isEmpty) {
            return const Center(child: Text('Không có món ăn nào'));
          }
          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: food.images.isNotEmpty
                      ? Image.network(
                          food.images[0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.fastfood),
                        )
                      : const Icon(Icons.fastfood),
                  title: Text(food.name),
                  subtitle: Text('Giá: ${food.price} VNĐ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditFoodDialog(
                              context, food, widget.restaurantId);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text(
                                  'Bạn có chắc muốn xóa món ${food.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            // Gọi hàm xóa món ăn trong viewModel
                            try {
                              if (food.id.isNotEmpty) {
                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await viewModel.deleteFood(food.id);
                                // Cập nhật danh sách món ăn sau khi xóa thành công
                                await viewModel.fetchFoodsByRestaurant(
                                    widget.restaurantId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Đã xóa món ăn ${food.name}')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Lỗi: ID món ăn không hợp lệ.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Lỗi khi xóa món ăn: ${e.toString()}')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to upload image to Firebase Storage
  Future<String> _uploadImageToFirebase(
      Uint8List imageBytes, String foodId, String fileName) async {
    try {
      // Determine content type from file extension
      final String extension = path.extension(fileName).toLowerCase();
      String contentType;
      switch (extension) {
        case '.jpg':
        case '.jpeg':
          contentType = 'image/jpeg';
          break;
        case '.png':
          contentType = 'image/png';
          break;
        case '.gif':
          contentType = 'image/gif';
          break;
        // Add more cases for other image types if needed
        default:
          contentType =
              'application/octet-stream'; // Default to binary if type is unknown
      }

      // Create metadata with content type
      final SettableMetadata metadata =
          SettableMetadata(contentType: contentType);

      // Create a reference to the location you want to upload to in Firebase Storage
      // Use the foodId and the original file extension for the storage path
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('food_images')
          .child('$foodId$extension');

      // Upload the file with metadata
      final uploadTask = storageRef.putData(imageBytes, metadata);

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  void _showAddFoodDialog(BuildContext context, String restaurantId) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final discountPriceController = TextEditingController();
    final ingredientsController = TextEditingController();
    final categoryController =
        TextEditingController(); // Assuming category is a String for now
    Uint8List? imageBytes;
    String? selectedFileName;
    bool isAvailable = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust width as needed
                height: MediaQuery.of(context).size.height *
                    0.8, // Adjust height as needed
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thêm Món Ăn Mới',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tên món ăn
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên món ăn *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mô tả
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá giảm giá (tùy chọn)
                      TextField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá giảm giá (tùy chọn)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hình ảnh
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                withData: true,
                              );
                              if (result != null &&
                                  result.files.single.bytes != null) {
                                setState(() {
                                  imageBytes = result.files.single.bytes;
                                  selectedFileName = result.files.single.name;
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh chính'),
                          ),
                          const SizedBox(width: 12),
                          imageBytes != null
                              ? Image.memory(
                                  imageBytes!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Text('Chưa chọn ảnh'),
                          if (selectedFileName != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(selectedFileName!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Nguyên liệu (tạm thời là chuỗi)
                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Nguyên liệu (phân tách bằng dấu phẩy)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Danh mục
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Trạng thái khả dụng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Khả dụng'),
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // Validate required fields
                              if (nameController.text.isEmpty ||
                                  priceController.text.isEmpty ||
                                  categoryController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Vui lòng điền đầy đủ thông tin bắt buộc')),
                                );
                                return;
                              }

                              showLoading(context);
                              try {
                                // Parse price and discountPrice
                                final double price =
                                    double.tryParse(priceController.text) ??
                                        0.0;
                                final double? discountPrice = double.tryParse(
                                    discountPriceController.text);

                                // Parse ingredients (simple split by comma)
                                final List<String> ingredients =
                                    ingredientsController.text
                                        .split(', ')
                                        .map((e) => e.trim())
                                        .toList();

                                String imageUrl = '';
                                // Upload image if selected
                                if (imageBytes != null &&
                                    selectedFileName != null) {
                                  try {
                                    final foodId = FirebaseFirestore.instance
                                        .collection('foods')
                                        .doc()
                                        .id;
                                    imageUrl = await _uploadImageToFirebase(
                                        imageBytes!, foodId, selectedFileName!);
                                  } catch (e) {
                                    hideLoading(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Lỗi khi tải ảnh lên: ${e.toString()}')),
                                    );
                                    return; // Stop if image upload fails
                                  }
                                } else {
                                  hideLoading(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Vui lòng chọn ảnh cho món ăn')),
                                  );
                                  return; // Require an image for now
                                }

                                final newFood = FoodModel(
                                  id: FirebaseFirestore.instance
                                      .collection('foods')
                                      .doc()
                                      .id, // Generate new ID for the food document
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  price: price,
                                  discountPrice: discountPrice,
                                  images: imageUrl.isNotEmpty ? [imageUrl] : [],
                                  ingredients: ingredients,
                                  category: CategoryFood.values.firstWhere(
                                    (e) =>
                                        e.name.toLowerCase() ==
                                        categoryController.text
                                            .trim()
                                            .toLowerCase(),
                                    orElse: () => CategoryFood.other,
                                  ),
                                  restaurantId: tokenR,
                                  isAvailable: isAvailable,
                                  rating: 0.0, // Default rating
                                  soldCount: 0, // Default sold count
                                  createdAt: Timestamp.now(),
                                );

                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await viewModel.addFood(newFood);
                                await viewModel.fetchFoodsByRestaurant(
                                    tokenR); // Refresh list
                                if (context.mounted) {
                                  Navigator.pop(
                                      context); // Close dialog on success
                                }
                                hideLoading(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm món ăn thành công')),
                                );
                              } catch (e) {
                                hideLoading(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lỗi khi thêm món ăn: ${e.toString()}')),
                                );
                              }
                            },
                            child: const Text('Thêm món ăn'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditFoodDialog(
      BuildContext context, FoodModel food, String restaurantId) {
    final nameController = TextEditingController(text: food.name);
    final descriptionController = TextEditingController(text: food.description);
    final priceController = TextEditingController(text: food.price.toString());
    final discountPriceController =
        TextEditingController(text: food.discountPrice?.toString());
    final ingredientsController =
        TextEditingController(text: food.ingredients.join(', '));
    final categoryController = TextEditingController(
        text: food.category.name); // Assuming category is String
    Uint8List? imageBytes; // To hold new image bytes
    String? imageUrl = food.images.isNotEmpty
        ? food.images[0]
        : null; // To hold existing image URL
    String? selectedFileName;
    bool isAvailable = food.isAvailable;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust width as needed
                height: MediaQuery.of(context).size.height *
                    0.8, // Adjust height as needed
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sửa Món Ăn',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tên món ăn
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên món ăn *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mô tả
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá giảm giá (tùy chọn)
                      TextField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá giảm giá (tùy chọn)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hình ảnh
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Implement image picking
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                withData: true,
                              );
                              if (result != null &&
                                  result.files.single.bytes != null) {
                                setState(() {
                                  imageBytes = result.files.single.bytes;
                                  imageUrl =
                                      null; // Clear existing URL if new image is picked
                                  selectedFileName = result.files.single.name;
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh chính'),
                          ),
                          const SizedBox(width: 12),
                          if (imageBytes != null)
                            Image.memory(
                              imageBytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          else if (imageUrl != null)
                            Image.network(
                              imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          else
                            const Text('Chưa chọn ảnh'),
                          if (selectedFileName != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(selectedFileName!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Nguyên liệu (tạm thời là chuỗi)
                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Nguyên liệu (phân tách bằng dấu phẩy)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Danh mục
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Trạng thái khả dụng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Khả dụng'),
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // Make onPressed async
                              // TODO: Implement update food logic properly
                              // Validate required fields
                              if (nameController.text.isEmpty ||
                                  priceController.text.isEmpty ||
                                  categoryController.text.isEmpty) {
                                // Show an error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Vui lòng điền đầy đủ thông tin bắt buộc')),
                                );
                                return;
                              }

                              // Parse price and discountPrice
                              final double price =
                                  double.tryParse(priceController.text) ?? 0.0;
                              final double? discountPrice =
                                  double.tryParse(discountPriceController.text);

                              // Parse ingredients (simple split by comma)
                              final List<String> ingredients =
                                  ingredientsController.text
                                      .split(', ')
                                      .map((e) => e.trim())
                                      .toList();

                              // Upload new image if selected
                              String finalImageUrl =
                                  imageUrl ?? ''; // Use existing URL by default
                              if (imageBytes != null &&
                                  selectedFileName != null) {
                                try {
                                  finalImageUrl = await _uploadImageToFirebase(
                                      imageBytes!, food.id, selectedFileName!);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Lỗi khi tải ảnh lên: ${e.toString()}')),
                                  );
                                  return; // Stop if image upload fails
                                }
                              }

                              final updatedFood = food.copyWith(
                                name: nameController.text,
                                description: descriptionController.text,
                                price: price,
                                discountPrice: discountPrice,
                                images: finalImageUrl.isNotEmpty
                                    ? [finalImageUrl]
                                    : [], // Use the potentially new image URL
                                ingredients: ingredients,
                                category: CategoryFood.values.firstWhere(
                                  // Convert String to CategoryFood enum
                                  (e) =>
                                      e.name.toLowerCase() ==
                                      categoryController.text
                                          .trim()
                                          .toLowerCase(),
                                  orElse: () => CategoryFood.other,
                                ),
                                isAvailable: isAvailable,
                                // Keep other fields as is
                              );

                              try {
                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await viewModel.updateFood(updatedFood,
                                    food.id); // Pass food ID for update
                                await viewModel.fetchFoodsByRestaurant(
                                    widget.restaurantId); // Refresh list
                                if (context.mounted) {
                                  Navigator.pop(
                                      context); // Close dialog on success
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Cập nhật món ăn thành công')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lỗi khi cập nhật món ăn: ${e.toString()}')),
                                );
                              }
                            },
                            child: const Text('Cập nhật'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void showLoading(BuildContext context, {String message = 'Đang xử lý...'}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Không cho tắt bằng cách bấm ra ngoài
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false, // Chặn nút back
        child: const Center(
          child: CircularProgressIndicator(), // Loading đơn giản
        ),
      );
    },
  );
}

void hideLoading(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
