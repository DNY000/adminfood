import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/banner_viewmode.dart';
import 'package:admin/models/banner_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';
import 'package:collection/collection.dart'; // Import collection for firstWhereOrNull
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class BannerScreen extends StatelessWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? bannerId;
  final String? searchQuery;

  const BannerScreen({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.bannerId,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar for mobile view
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
              title: Text('Quản lý Banner',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            )
          : null,
      // Use SideMenu as drawer on mobile
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
                padding: EdgeInsets.all(16.0),
                child: BannerContent(
                  showAddDialog: showAddDialog,
                  showUpdateDialog: showUpdateDialog,
                  bannerId: bannerId,
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

class BannerContent extends StatefulWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? bannerId;
  final String? searchQuery;

  const BannerContent({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.bannerId,
    this.searchQuery,
  });

  @override
  State<BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<BannerContent> {
  final TextEditingController _searchController = TextEditingController();
  // Add controllers for banner add/edit form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subTitleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<BannerViewmode>();
      await viewModel.getListBanner();

      // Check for showAddDialog in initState for initial route load
      if (widget.showAddDialog) {
        _showBannerDialog(context);
      }
    });
  }

  @override
  void didUpdateWidget(covariant BannerContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Logic for showing update dialog
    if (widget.showUpdateDialog &&
        widget.bannerId != null &&
        widget.bannerId != oldWidget.bannerId) {
      final viewModel = context.read<BannerViewmode>();
      final bannerToUpdate = viewModel.listBanner.firstWhereOrNull(
        (banner) => banner.id == widget.bannerId,
      );
      if (bannerToUpdate != null) {
        // Ensure the state is ready before showing dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBannerDialog(context, bannerToUpdate);
        });
      } else {
        print('Error: Banner with ID ${widget.bannerId} not found.');
        // Optionally navigate back if banner not found
        if (mounted) {
          context.go(NameRouter.banner);
        }
      }
    } else if (oldWidget.showUpdateDialog && !widget.showUpdateDialog) {
      // If navigating away from update route (e.g. dialog is closed)
      // Ensure we are back on the base banner route
      final currentUri = GoRouterState.of(context).uri;
      if (currentUri.pathSegments.isNotEmpty &&
          currentUri.pathSegments.last != 'banner') {
        if (mounted) {
          context.go(NameRouter.banner);
        }
      }
    }

    // Logic for showing add dialog when navigating from another route to /banner/add
    if (widget.showAddDialog && !oldWidget.showAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBannerDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _subTitleController.dispose();
    _linkController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // Method to show add/edit banner dialog
  void _showBannerDialog(BuildContext context, [BannerModel? banner]) {
    final isEditing = banner != null;
    // Initialize controllers with banner data if editing
    if (isEditing) {
      _titleController.text = banner.title;
      _subTitleController.text = banner.subTitle;
      _linkController.text = banner.link;
      _imageController.text = banner.image;
    } else {
      // Clear controllers for adding
      _titleController.clear();
      _subTitleController.clear();
      _linkController.clear();
      _imageController.clear();
    }

    Uint8List? imageBytes;
    String? selectedFileName;
    String? imageUrl = isEditing ? banner?.image : null;
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
            .child('banner_images')
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Chỉnh sửa Banner' : 'Thêm Banner',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subTitleController,
                    decoration: const InputDecoration(labelText: 'Phụ đề'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(labelText: 'Link'),
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
                                  imageBytes = result.files.single.bytes;
                                  selectedFileName = result.files.single.name;
                                  imageUrl = null;
                                  (context as Element).markNeedsBuild();
                                  isUploading = true;
                                  try {
                                    final url = await _uploadImageToFirebase(
                                        imageBytes!, selectedFileName!);
                                    imageUrl = url;
                                    _imageController.text = url;
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                        label: const Text('Chọn ảnh banner'),
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
                          width: 100,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      else if (imageUrl?.isNotEmpty == true)
                        Image.network(
                          imageUrl!,
                          width: 100,
                          height: 50,
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
                    controller: _imageController,
                    decoration:
                        const InputDecoration(labelText: 'URL Hình ảnh'),
                    keyboardType: TextInputType.url,
                    readOnly: true,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go(NameRouter.banner);
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        child: Text(isEditing ? 'Lưu' : 'Thêm'),
                        onPressed: isUploading
                            ? null
                            : () async {
                                final viewModel =
                                    context.read<BannerViewmode>();
                                if (isEditing) {
                                  final updatedBanner = banner!.copyWith(
                                    title: _titleController.text,
                                    subTitle: _subTitleController.text,
                                    link: _linkController.text,
                                    image: _imageController.text,
                                  );
                                  await viewModel.updateBanner(
                                      updatedBanner, banner.id);
                                } else {
                                  if (_titleController.text.isEmpty ||
                                      _subTitleController.text.isEmpty ||
                                      _imageController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Vui lòng điền đầy đủ thông tin (Tiêu đề, Phụ đề, URL Hình ảnh)')),
                                    );
                                    return;
                                  }
                                  final newBanner = BannerModel(
                                    id: '',
                                    title: _titleController.text,
                                    subTitle: _subTitleController.text,
                                    link: _linkController.text,
                                    image: _imageController.text,
                                  );
                                  await viewModel.addBanner(newBanner);
                                }
                                Navigator.of(context).pop();
                                context.go(NameRouter.banner);
                              },
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hide title on mobile as it's in AppBar
            if (!Responsive.isMobile(context))
              Text(
                'Quản lý Banner',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add banner route which will trigger dialog
                context.go('${NameRouter.banner}/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Banner'),
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

        // Search section
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm banner...',
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

        // Banner list
        Expanded(
          child: Consumer<BannerViewmode>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              var filteredBanners = viewModel.listBanner;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredBanners = filteredBanners
                    .where(
                      (banner) =>
                          banner.title.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ) ||
                          banner.subTitle.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ),
                    )
                    .toList();
              }

              if (filteredBanners.isEmpty) {
                return const Center(child: Text('Không tìm thấy banner nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredBanners, viewModel)
                  : _buildMobileView(filteredBanners, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<BannerModel> banners,
    BannerViewmode viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Hình ảnh')),
          DataColumn(label: Text('Tiêu đề')),
          DataColumn(label: Text('Phụ đề')),
          DataColumn(label: Text('Link')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: banners.map((banner) {
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                // Navigate to update banner route which will trigger dialog
                context.go('${NameRouter.banner}/${banner.id}');
              }
            },
            cells: [
              DataCell(
                banner.image.isNotEmpty
                    ? Image.network(
                        banner.image,
                        width: 100,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/default_banner.png', // Replace with your default asset image
                          width: 100,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              DataCell(Text(banner.title)),
              DataCell(Text(banner.subTitle)),
              DataCell(Text(banner.link)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to update banner route
                        context.go('${NameRouter.banner}/${banner.id}');
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
                              'Bạn có chắc muốn xóa banner ${banner.title}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
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
                          await viewModel.deleteBanner(banner.id);
                          await viewModel.getListBanner();
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
    );
  }

  Widget _buildMobileView(
    List<BannerModel> banners,
    BannerViewmode viewModel,
  ) {
    return ListView.builder(
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return GestureDetector(
          onTap: () {
            context.go('${NameRouter.banner}/${banner.id}');
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banner.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        banner.image,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/default_banner.png', // Replace with your default asset image
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            // Use Container as fallback for asset image
                            width: double.infinity,
                            height: 150,
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
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 150,
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
                  const SizedBox(height: 16),
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(banner.subTitle),
                  const SizedBox(height: 8),
                  Text('Link: ${banner.link}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.go('${NameRouter.banner}/${banner.id}');
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
                                'Bạn có chắc muốn xóa banner ${banner.title}?',
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
                            await viewModel.deleteBanner(banner.id);
                            await viewModel.getListBanner();
                          }
                        },
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
  }
}
