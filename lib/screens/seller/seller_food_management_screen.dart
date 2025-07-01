import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/seller_router.dart';
import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/responsive.dart';
import 'package:admin/models/food_model.dart';
import 'package:admin/viewmodels/food_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:admin/viewmodels/category_viewmodel.dart';

class SellerFoodScreen extends StatefulWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? foodId;
  final String restaurantId;

  const SellerFoodScreen({
    Key? key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.foodId,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<SellerFoodScreen> createState() => _SellerFoodScreenState();
}

class _SellerFoodScreenState extends State<SellerFoodScreen> {
  String? _selectedFileName;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.showAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddFoodDialog();
      });
    } else if (widget.showUpdateDialog && widget.foodId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateFoodDialog(widget.foodId!);
      });
    }
    // Fetch foods when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodViewModel>().fetchFoodsByRestaurant(widget.restaurantId);
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        default:
          contentType = 'application/octet-stream';
      }

      final SettableMetadata metadata =
          SettableMetadata(contentType: contentType);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('food_images')
          .child('$foodId$extension');

      final uploadTask = storageRef.putData(imageBytes, metadata);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Responsive.isMobile(context) ? null : GlobalKey<ScaffoldState>(),
      drawer: Responsive.isMobile(context) ? const SellerSideMenu() : null,
      appBar: AppBar(
        title: const Text('Quản lý món ăn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SellerSideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm món ăn...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              // TODO: Implement search
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddFoodDialog();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm món'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<FoodViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (viewModel.error != null) {
                          return Center(child: Text(viewModel.error!));
                        }
                        final foods = viewModel.foods;
                        if (foods.isEmpty) {
                          return const Center(
                              child: Text('Không có món ăn nào'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: foods.length,
                          itemBuilder: (context, index) {
                            final food = foods[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: food.images.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            food.images[0],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.fastfood),
                                ),
                                title: Text(food.name),
                                subtitle: Text('Giá: ${food.price} VNĐ'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        print('foood id là l${food.id}');
                                        _showUpdateFoodDialog(food.id);
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
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Xóa'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await viewModel.deleteFood(food.id);
                                            await viewModel
                                                .fetchFoodsByRestaurant(
                                                    widget.restaurantId);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Đã xóa món ăn ${food.name}')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Lỗi khi xóa món ăn: ${e.toString()}')),
                                              );
                                            }
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog() {
    if (widget.restaurantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Lỗi: Không tìm thấy ID nhà hàng. Vui lòng thử lại.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final discountPriceController = TextEditingController();
    final ingredientsController = TextEditingController();
    final categoryController = TextEditingController();
    Uint8List? imageBytes;
    String? selectedFileName;
    bool isAvailable = true;
    String selectedCategory = '';

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
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.8,
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
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên món ăn *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá giảm giá (tùy chọn)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Nguyên liệu (phân tách bằng dấu phẩy)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<CategoryViewModel>(
                        builder: (context, categoryVM, _) {
                          return DropdownButtonFormField<String>(
                            value: categoryVM.categories.any((cat) =>
                                    cat.name == categoryController.text)
                                ? categoryController.text
                                : null,
                            items: categoryVM.categories
                                .map((cat) => DropdownMenuItem(
                                      value: cat.name,
                                      child: Text(cat.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                categoryController.text = value!;
                                selectedCategory = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Danh mục *',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
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

                              final double price =
                                  double.tryParse(priceController.text) ?? 0.0;
                              final double? discountPrice =
                                  double.tryParse(discountPriceController.text);

                              final List<String> ingredients =
                                  ingredientsController.text
                                      .split(', ')
                                      .map((e) => e.trim())
                                      .toList();

                              final newFoodId = FirebaseFirestore.instance
                                  .collection('foods')
                                  .doc()
                                  .id;
                              String imageUrl = '';
                              if (imageBytes != null &&
                                  selectedFileName != null) {
                                try {
                                  imageUrl = await _uploadImageToFirebase(
                                      imageBytes!,
                                      newFoodId,
                                      selectedFileName!);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Lỗi khi tải ảnh lên: ${e.toString()}')),
                                  );
                                  return;
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Vui lòng chọn ảnh cho món ăn')),
                                );
                                return;
                              }

                              final newFood = FoodModel(
                                id: newFoodId,
                                name: nameController.text,
                                description: descriptionController.text,
                                price: price,
                                discountPrice: discountPrice,
                                images: imageUrl.isNotEmpty ? [imageUrl] : [],
                                ingredients: ingredients,
                                category: CategoryFood.values.firstWhere(
                                  (e) =>
                                      e.name.toLowerCase() ==
                                      selectedCategory.toLowerCase(),
                                  orElse: () => CategoryFood.other,
                                ),
                                restaurantId: widget.restaurantId,
                                isAvailable: isAvailable,
                                rating: 0.0,
                                soldCount: 0,
                                createdAt: Timestamp.now(),
                              );

                              try {
                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await FirebaseFirestore.instance
                                    .collection('foods')
                                    .doc(newFoodId)
                                    .set(newFood.toMap());
                                await viewModel.fetchFoodsByRestaurant(
                                    widget.restaurantId);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm món ăn thành công')),
                                );
                              } catch (e) {
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

  void _showUpdateFoodDialog(String foodId) async {
    if (widget.restaurantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Lỗi: Không tìm thấy ID nhà hàng. Vui lòng thử lại.')),
      );
      return;
    }
    final viewModel = Provider.of<FoodViewModel>(context, listen: false);
    try {
      final food = await viewModel.getFoodById(foodId);
      if (food == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy món ăn')),
        );
        return;
      }

      final nameController = TextEditingController(text: food.name);
      final descriptionController =
          TextEditingController(text: food.description);
      final priceController =
          TextEditingController(text: food.price.toString());
      final discountPriceController =
          TextEditingController(text: food.discountPrice?.toString());
      final ingredientsController =
          TextEditingController(text: food.ingredients.join(', '));
      final categoryController =
          TextEditingController(text: food.category.name);
      Uint8List? imageBytes;
      String? imageUrl = food.images.isNotEmpty ? food.images[0] : null;
      String? selectedFileName;
      bool isAvailable = food.isAvailable;
      String selectedCategory = food.category.name;

      if (!context.mounted) return;

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
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.8,
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
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên món ăn *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: discountPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá giảm giá (tùy chọn)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                    imageUrl = null;
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
                        TextField(
                          controller: ingredientsController,
                          decoration: const InputDecoration(
                            labelText: 'Nguyên liệu (phân tách bằng dấu phẩy)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<CategoryViewModel>(
                          builder: (context, categoryVM, _) {
                            if (categoryController.text.isEmpty &&
                                categoryVM.categories.isNotEmpty) {
                              final matched = categoryVM.categories.firstWhere(
                                (cat) => cat.name == food.category.name,
                                orElse: () => categoryVM.categories.first,
                              );
                              categoryController.text = matched.name;
                              selectedCategory = matched.name;
                            }
                            return DropdownButtonFormField<String>(
                              value: categoryVM.categories.any((cat) =>
                                      cat.name == categoryController.text)
                                  ? categoryController.text
                                  : null,
                              items: categoryVM.categories
                                  .map((cat) => DropdownMenuItem(
                                        value: cat.name,
                                        child: Text(cat.name),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  categoryController.text = value!;
                                  selectedCategory = value;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Danh mục *',
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
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

                                final double price =
                                    double.tryParse(priceController.text) ??
                                        0.0;
                                final double? discountPrice = double.tryParse(
                                    discountPriceController.text);

                                final List<String> ingredients =
                                    ingredientsController.text
                                        .split(', ')
                                        .map((e) => e.trim())
                                        .toList();

                                String finalImageUrl = imageUrl ?? '';
                                if (imageBytes != null &&
                                    selectedFileName != null) {
                                  try {
                                    finalImageUrl =
                                        await _uploadImageToFirebase(
                                            imageBytes!,
                                            food.id,
                                            selectedFileName!);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Lỗi khi tải ảnh lên: ${e.toString()}')),
                                    );
                                    return;
                                  }
                                }

                                final updatedFood = food.copyWith(
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  price: price,
                                  discountPrice: discountPrice,
                                  images: finalImageUrl.isNotEmpty
                                      ? [finalImageUrl]
                                      : [],
                                  ingredients: ingredients,
                                  category: CategoryFood.values.firstWhere(
                                    (e) =>
                                        e.name.toLowerCase() ==
                                        selectedCategory.toLowerCase(),
                                    orElse: () => CategoryFood.other,
                                  ),
                                  isAvailable: isAvailable,
                                );

                                try {
                                  await viewModel.updateFood(
                                      updatedFood, food.id);
                                  await viewModel.fetchFoodsByRestaurant(
                                      widget.restaurantId);
                                  if (context.mounted) {
                                    Navigator.pop(context);
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
}
