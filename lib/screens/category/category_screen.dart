import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/category_viewmodel.dart';
import 'package:admin/models/category_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class CategoryScreen extends StatelessWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? categoryId;
  final String? searchQuery;

  const CategoryScreen({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.categoryId,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              title: Text('Quản lý Danh mục',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            )
          : null,
      drawer: Responsive.isMobile(context) ? const SideMenu() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(flex: 1, child: SideMenu()),
          Expanded(
            flex: 5,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CategoryContent(
                  showAddDialog: showAddDialog,
                  showUpdateDialog: showUpdateDialog,
                  categoryId: categoryId,
                  searchQuery: searchQuery,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryContent extends StatefulWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? categoryId;
  final String? searchQuery;

  const CategoryContent({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.categoryId,
    this.searchQuery,
  });

  @override
  State<CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends State<CategoryContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<CategoryViewModel>();
      await viewModel.loadCategories();

      if (widget.showAddDialog) {
        _showCategoryDialog(context);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CategoryContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showUpdateDialog &&
        widget.categoryId != null &&
        widget.categoryId != oldWidget.categoryId) {
      final viewModel = context.read<CategoryViewModel>();
      final categoryToUpdate = viewModel.categories.firstWhereOrNull(
        (category) => category.id == widget.categoryId,
      );
      if (categoryToUpdate != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCategoryDialog(context, categoryToUpdate);
        });
      } else {
        print('Error: Category with ID ${widget.categoryId} not found.');
        if (mounted) {
          context.go(NameRouter.categories);
        }
      }
    } else if (oldWidget.showUpdateDialog && !widget.showUpdateDialog) {
      final currentUri = GoRouterState.of(context).uri;
      if (currentUri.pathSegments.isNotEmpty &&
          currentUri.pathSegments.last != 'categories') {
        if (mounted) {
          context.go(NameRouter.categories);
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!Responsive.isMobile(context))
              Text(
                'Quản lý Danh mục',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            if (!Responsive.isMobile(context)) const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go(NameRouter.categories + '/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Danh mục'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm danh mục...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Consumer<CategoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.error!),
                      ElevatedButton(
                        onPressed: () => viewModel.loadCategories(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredCategories = viewModel.categories;

              if (_searchController.text.isNotEmpty) {
                filteredCategories = filteredCategories
                    .where(
                      (category) => category.name.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ),
                    )
                    .toList();
              }

              if (filteredCategories.isEmpty) {
                return const Center(child: Text('Không tìm thấy danh mục nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredCategories, viewModel)
                  : _buildMobileView(filteredCategories, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<CategoryModel> categories,
    CategoryViewModel viewModel,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width -
            (Responsive.isDesktop(context) ? 240 : 0) -
            (16 * 2),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Hình ảnh')),
            DataColumn(label: Text('Tên')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Thao tác')),
          ],
          rows: categories.map((category) {
            return DataRow(
              cells: [
                DataCell(
                  category.image.isNotEmpty
                      ? Image.network(
                          category.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder_category.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported,
                                    size: 30);
                              },
                            );
                          },
                        )
                      : const Icon(Icons.image_not_supported, size: 30),
                ),
                DataCell(Text(category.name)),
                DataCell(
                  category.isActive
                      ? const Text('Hoạt động',
                          style: TextStyle(color: Colors.green))
                      : const Text('Ẩn', style: TextStyle(color: Colors.red)),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.go('${NameRouter.categories}/${category.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text(
                                'Bạn có chắc muốn xóa danh mục ${category.name}?',
                              ),
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

                          if (confirmed == true) {
                            await viewModel.deleteCategory(category.id);
                            await viewModel.loadCategories();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileView(
    List<CategoryModel> categories,
    CategoryViewModel viewModel,
  ) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    category.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              category.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/placeholder_category.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  context.go(
                                      '${NameRouter.categories}/${category.id}');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: Text(
                                        'Bạn có chắc muốn xóa danh mục ${category.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await viewModel.deleteCategory(category.id);
                                    await viewModel.loadCategories();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, [CategoryModel? category]) {
    final viewModel = Provider.of<CategoryViewModel>(context, listen: false);
    final TextEditingController nameController =
        TextEditingController(text: category?.name ?? '');
    final TextEditingController imageController =
        TextEditingController(text: category?.image ?? '');
    bool isActive = category?.isActive ?? true;
    String? errorText;
    Uint8List? imageBytes;
    String? selectedFileName;
    String? imageUrl = category?.image;
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
            .child('category_images')
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'Thêm Danh mục' : 'Sửa Danh mục'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Danh mục',
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                      setState(() {
                                        imageBytes = result.files.single.bytes;
                                        selectedFileName =
                                            result.files.single.name;
                                        imageUrl = null;
                                      });
                                      setState(() {
                                        isUploading = true;
                                      });
                                      try {
                                        final url =
                                            await _uploadImageToFirebase(
                                                imageBytes!, selectedFileName!);
                                        setState(() {
                                          imageUrl = url;
                                          imageController.text = url;
                                        });
                                      } catch (e) {
                                        setState(() {
                                          errorText =
                                              'Lỗi khi tải ảnh lên: \\n${e.toString()}';
                                        });
                                      } finally {
                                        setState(() {
                                          isUploading = false;
                                        });
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh'),
                          ),
                          const SizedBox(width: 12),
                          if (isUploading)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (imageBytes != null)
                            Image.memory(
                              imageBytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          else if (imageUrl?.isNotEmpty == true)
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
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL Hình ảnh',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Trạng thái hoạt động:'),
                          const SizedBox(width: 8),
                          Switch(
                            value: isActive,
                            onChanged: (value) {
                              setState(() {
                                isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isLoading || isUploading
                      ? null
                      : () async {
                          setState(() {
                            errorText = null;
                          });

                          if (nameController.text.isEmpty) {
                            setState(() {
                              errorText = 'Tên danh mục không được để trống';
                            });
                            return;
                          }
                          if (imageController.text.isEmpty) {
                            setState(() {
                              errorText = 'Vui lòng chọn ảnh cho danh mục';
                            });
                            return;
                          }

                          final newCategory = CategoryModel(
                            id: category?.id ?? '',
                            name: nameController.text,
                            image: imageController.text,
                            isActive: isActive,
                          );

                          try {
                            if (category == null) {
                              await viewModel.addCategory(newCategory);
                            } else {
                              await viewModel.updateCategory(
                                  newCategory.id, newCategory);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                              context.go(NameRouter.categories);
                            }
                          } catch (e) {
                            setState(() {
                              errorText = 'Lỗi: \\n${e.toString()}';
                            });
                          }
                        },
                  child: Text(viewModel.isLoading || isUploading
                      ? 'Đang xử lý...'
                      : (category == null ? 'Thêm' : 'Lưu')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
