import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/restaurant_model.dart';
import 'package:intl/intl.dart';
import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class SellerOverviewScreen extends StatefulWidget {
  const SellerOverviewScreen({Key? key}) : super(key: key);

  @override
  State<SellerOverviewScreen> createState() => _OverviewSellerScreenState();
}

class _OverviewSellerScreenState extends State<SellerOverviewScreen> {
  RestaurantModel? restaurant;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('token', isEqualTo: user.uid)
          .get();

      if (restaurantDoc.docs.isNotEmpty) {
        setState(() {
          restaurant = RestaurantModel.fromMap(
              restaurantDoc.docs.first.data(), restaurantDoc.docs.first.id);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurant == null) {
      return const Center(
        child: Text('Không tìm thấy thông tin nhà hàng'),
      );
    }

    final categoryViewModel = Provider.of<CategoryViewModel>(context);
    final allCategories = categoryViewModel.categories;
    final List<String> selectedCategories =
        List<String>.from(restaurant!.categories);

    // Controllers for edit dialog
    final nameController = TextEditingController(text: restaurant!.name);
    final descriptionController =
        TextEditingController(text: restaurant!.description);
    final addressController = TextEditingController(text: restaurant!.address);
    final openTimeController =
        TextEditingController(text: restaurant!.openTime);
    final closeTimeController =
        TextEditingController(text: restaurant!.closeTime);
    final mainImageController =
        TextEditingController(text: restaurant!.mainImage);
    Uint8List? imageBytes;
    String? selectedFileName;
    String? imageUrl = restaurant!.mainImage;
    bool isUploading = false;

    Future<String> _uploadImageToFirebase(
        Uint8List imageBytes, String fileName) async {
      try {
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
            .child('restaurant_main_images')
            .child('${DateTime.now().millisecondsSinceEpoch}$extension');
        final uploadTask = storageRef.putData(imageBytes, metadata);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print('Error uploading image: $e');
        rethrow;
      }
    }

    void _showEditRestaurantDialog() {
      // Đảm bảo đã load categories
      if (allCategories.isEmpty) {
        categoryViewModel.loadCategories();
      }
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chỉnh sửa thông tin nhà hàng',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: nameController,
                          decoration:
                              const InputDecoration(labelText: 'Tên nhà hàng'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'Mô tả'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: addressController,
                          decoration:
                              const InputDecoration(labelText: 'Địa chỉ'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: openTimeController,
                                decoration: const InputDecoration(
                                    labelText: 'Giờ mở cửa (HH:mm)'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: closeTimeController,
                                decoration: const InputDecoration(
                                    labelText: 'Giờ đóng cửa (HH:mm)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Danh mục',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: allCategories.map((cat) {
                            final isSelected =
                                selectedCategories.contains(cat.name);
                            return FilterChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedCategories.add(cat.name);
                                  } else {
                                    selectedCategories.remove(cat.name);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text('Ảnh đại diện',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: isUploading
                                  ? null
                                  : () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.image,
                                        withData: true,
                                      );
                                      if (result != null &&
                                          result.files.single.bytes != null) {
                                        imageBytes = result.files.single.bytes;
                                        selectedFileName =
                                            result.files.single.name;
                                        imageUrl = null;
                                        (context as Element).markNeedsBuild();
                                        isUploading = true;
                                        try {
                                          final url =
                                              await _uploadImageToFirebase(
                                                  imageBytes!,
                                                  selectedFileName!);
                                          imageUrl = url;
                                          mainImageController.text = url;
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Lỗi khi tải ảnh lên: \n${e.toString()}')),
                                          );
                                        } finally {
                                          isUploading = false;
                                          (context as Element).markNeedsBuild();
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.image),
                              label: const Text('Thay đổi ảnh'),
                            ),
                            const SizedBox(width: 12),
                            if (isUploading)
                              const SizedBox(
                                width: 32,
                                height: 32,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            else if (imageBytes != null)
                              Image.memory(
                                imageBytes!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            else if ((mainImageController.text.isNotEmpty ||
                                imageUrl?.isNotEmpty == true))
                              Image.network(
                                imageUrl?.isNotEmpty == true
                                    ? imageUrl!
                                    : mainImageController.text,
                                width: 80,
                                height: 80,
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
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                // Validate
                                if (nameController.text.isEmpty ||
                                    addressController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Vui lòng nhập tên và địa chỉ.')));
                                  return;
                                }
                                // Update Firestore
                                final docRef = FirebaseFirestore.instance
                                    .collection('restaurants')
                                    .doc(restaurant!.id);
                                await docRef.update({
                                  'name': nameController.text,
                                  'description': descriptionController.text,
                                  'address': addressController.text,
                                  'operatingHours': {
                                    'openTime': openTimeController.text,
                                    'closeTime': closeTimeController.text,
                                  },
                                  'categories': selectedCategories,
                                  'images.main':
                                      imageUrl ?? mainImageController.text,
                                });
                                if (mounted) {
                                  Navigator.pop(context);
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _loadRestaurantData();
                                }
                              },
                              child: const Text('Lưu'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      key: Responsive.isMobile(context) ? null : GlobalKey<ScaffoldState>(),
      drawer: Responsive.isMobile(context) ? const SellerSideMenu() : null,
      appBar: AppBar(
        title: const Text('Tổng quan nhà hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditRestaurantDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SellerSideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Basic Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      restaurant!.mainImage.isNotEmpty
                                          ? NetworkImage(restaurant!.mainImage)
                                          : null,
                                  child: restaurant!.mainImage.isEmpty
                                      ? const Icon(Icons.restaurant, size: 40)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant!.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (restaurant!
                                          .description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          restaurant!.description,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            restaurant!.rating
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: restaurant!.isOpen
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          restaurant!.isOpen
                                              ? 'Đang mở cửa'
                                              : 'Đã đóng cửa',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.access_time,
                              'Giờ mở cửa',
                              '${restaurant!.openTime} - ${restaurant!.closeTime}',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.location_on,
                              'Địa chỉ',
                              restaurant!.address,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.category,
                              'Danh mục',
                              restaurant!.categories.join(', '),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Activity Section
                    const Text(
                      'Hoạt động gần đây',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 0, // TODO: Add recent activities
                        itemBuilder: (context, index) {
                          return const ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.notifications),
                            ),
                            title: Text('No recent activities'),
                            subtitle: Text('Activities will appear here'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
