import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/shipper_viewmodel.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';
import 'package:collection/collection.dart'; // Import collection for firstWhereOrNull
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ShipperScreen extends StatelessWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? shipperId;
  final String? searchQuery;

  const ShipperScreen({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.shipperId,
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
              title: Text('Quản lý Shipper',
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
                child: ShipperContent(
                  showAddDialog: showAddDialog,
                  showUpdateDialog: showUpdateDialog,
                  shipperId: shipperId,
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

class ShipperContent extends StatefulWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? shipperId;
  final String? searchQuery;

  const ShipperContent({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.shipperId,
    this.searchQuery,
  });

  @override
  State<ShipperContent> createState() => _ShipperContentState();
}

class _ShipperContentState extends State<ShipperContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isActive = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<ShipperViewModel>();
      await viewModel.loadShippers();

      // Logic for showing add dialog remains in initState
      if (widget.showAddDialog) {
        _showShipperDialog(context);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ShipperContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Logic for showing update dialog moves to didUpdateWidget
    if (widget.showUpdateDialog &&
        widget.shipperId != null &&
        widget.shipperId != oldWidget.shipperId) {
      final viewModel = context.read<ShipperViewModel>();
      final shipperToUpdate = viewModel.shippers.firstWhereOrNull(
        (shipper) => shipper.id == widget.shipperId,
      );
      if (shipperToUpdate != null) {
        // Ensure the state is ready before showing dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showShipperDialog(context, shipperToUpdate);
        });
      } else {
        print('Error: Shipper with ID ${widget.shipperId} not found.');
        // Optionally navigate back if shipper not found
        if (mounted) {
          context.go(NameRouter.shippers);
        }
      }
    } else if (oldWidget.showUpdateDialog && !widget.showUpdateDialog) {
      // If navigating away from update route (e.g. dialog is closed)
      // Ensure we are back on the base shippers route
      final currentUri = GoRouterState.of(context).uri;
      if (currentUri.pathSegments.isNotEmpty &&
          currentUri.pathSegments.last != 'shippers') {
        if (mounted) {
          context.go(NameRouter.shippers);
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    _birthDateController.dispose();
    _vehicleTypeController.dispose();
    _addressController.dispose();
    super.dispose();
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
                'Quản lý Shipper',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add shipper route
                context.go('${NameRouter.shippers}/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Shipper'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search and filter section
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm shipper...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Đang hoạt động'),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Không hoạt động'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Shipper list
        Expanded(
          child: Consumer<ShipperViewModel>(
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
                        onPressed: () => viewModel.loadShippers(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredShippers = viewModel.shippers;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredShippers = viewModel.searchShippers(
                  _searchController.text,
                );
                // TODO: Optionally navigate to search results route here
                // context.go('${NameRouter.searchShippers}/${_searchController.text}');
              }

              // Apply status filter
              if (_selectedStatus != 'all') {
                filteredShippers = filteredShippers
                    .where((shipper) => shipper.status == _selectedStatus)
                    .toList();
              }

              if (filteredShippers.isEmpty) {
                return const Center(child: Text('Không tìm thấy shipper nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredShippers, viewModel)
                  : _buildMobileView(filteredShippers, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<ShipperModel> shippers,
    ShipperViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Avatar')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Số điện thoại')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Xác thực')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: shippers.map((shipper) {
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                // Navigate to update shipper route when selected
                context.go('${NameRouter.shippers}/${shipper.id}');
              }
            },
            cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: shipper.avatarUrl.isNotEmpty
                      ? NetworkImage(shipper.avatarUrl)
                      : null,
                  child: shipper.avatarUrl.isEmpty
                      ? Text(
                          shipper.name.isNotEmpty
                              ? shipper.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
              ),
              DataCell(Text(shipper.name)),
              DataCell(Text(shipper.phoneNumber)),
              DataCell(Text(shipper.email)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        shipper.status == 'active' ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shipper.status == 'active'
                        ? 'Đang hoạt động'
                        : 'Không hoạt động',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              DataCell(
                shipper.isAuthenticated == true
                    ? const Text('Đã xác thực',
                        style: TextStyle(color: Colors.green))
                    : const Text('Chưa xác thực',
                        style: TextStyle(color: Colors.red)),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to update shipper route on edit button press
                        context.go('${NameRouter.shippers}/${shipper.id}');
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
                              'Bạn có chắc muốn xóa shipper ${shipper.name}?',
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
                          await viewModel.deleteShipper(shipper.id);
                          await viewModel.loadShippers();
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
    List<ShipperModel> shippers,
    ShipperViewModel viewModel,
  ) {
    return ListView.builder(
      itemCount: shippers.length,
      itemBuilder: (context, index) {
        final shipper = shippers[index];
        return GestureDetector(
            onTap: () {
              // Navigate to update shipper route on tap
              context.go('${NameRouter.shippers}/${shipper.id}');
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: shipper.avatarUrl.isNotEmpty
                              ? NetworkImage(shipper.avatarUrl)
                              : null,
                          child: shipper.avatarUrl.isEmpty
                              ? Text(
                                  shipper.name.isNotEmpty
                                      ? shipper.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shipper.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('SĐT: ${shipper.phoneNumber}'),
                              Text('Email: ${shipper.email}'),
                              const SizedBox(height: 4),
                              shipper.isAuthenticated == true
                                  ? const Text('Đã xác thực',
                                      style: TextStyle(color: Colors.green))
                                  : const Text('Chưa xác thực',
                                      style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: shipper.status == 'active'
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            shipper.status == 'active'
                                ? 'Đang hoạt động'
                                : 'Không hoạt động',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Navigate to update shipper route on edit button press
                                context
                                    .go('${NameRouter.shippers}/${shipper.id}');
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
                                      'Bạn có chắc muốn xóa shipper ${shipper.name}?',
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
                                  await viewModel.deleteShipper(shipper.id);
                                  await viewModel.loadShippers();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  void _showShipperDialog(BuildContext context, [ShipperModel? shipper]) {
    final viewModel = Provider.of<ShipperViewModel>(context, listen: false);
    _nameController.text = shipper?.name ?? '';
    _phoneController.text = shipper?.phoneNumber ?? '';
    _emailController.text = shipper?.email ?? '';
    _avatarUrlController.text = shipper?.avatarUrl ?? '';
    _birthDateController.text =
        shipper?.birthDate.toIso8601String().split('T').first ?? '';
    _vehicleTypeController.text = shipper?.vehicleType ?? '';
    _addressController.text = shipper?.address ?? '';
    _isActive = shipper?.status == 'active';
    _isAuthenticated = shipper?.isAuthenticated ?? false;

    String? errorText;
    Uint8List? imageBytes;
    String? selectedFileName;
    String? imageUrl = shipper?.avatarUrl;
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
            .child('shipper_avatars')
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
              title: Text(shipper == null ? 'Thêm Shipper' : 'Sửa Shipper'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Shipper *',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại *',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh (YYYY-MM-DD)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _vehicleTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Loại xe',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ',
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
                                          _avatarUrlController.text = url;
                                        });
                                      } catch (e) {
                                        setState(() {
                                          errorText =
                                              'Lỗi khi tải ảnh lên: \n${e.toString()}';
                                        });
                                      } finally {
                                        setState(() {
                                          isUploading = false;
                                        });
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh avatar'),
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
                        controller: _avatarUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Avatar',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Trạng thái hoạt động:'),
                          const SizedBox(width: 8),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Đã xác thực:'),
                          const SizedBox(width: 8),
                          Switch(
                            value: _isAuthenticated,
                            onChanged: (value) {
                              setState(() {
                                _isAuthenticated = value;
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

                          if (_nameController.text.isEmpty ||
                              _phoneController.text.isEmpty ||
                              _emailController.text.isEmpty) {
                            setState(() {
                              errorText =
                                  'Vui lòng điền đầy đủ thông tin bắt buộc';
                            });
                            return;
                          }

                          DateTime? birthDate;
                          try {
                            if (_birthDateController.text.isNotEmpty) {
                              birthDate =
                                  DateTime.parse(_birthDateController.text);
                            } else {
                              birthDate = DateTime.now();
                            }
                          } catch (e) {
                            setState(() {
                              errorText =
                                  'Ngày sinh không hợp lệ. Sử dụng định dạng YYYY-MM-DD';
                            });
                            return;
                          }

                          final shipperData = ShipperModel(
                            id: shipper?.id ?? '',
                            name: _nameController.text,
                            phoneNumber: _phoneController.text,
                            email: _emailController.text,
                            avatarUrl: _avatarUrlController.text,
                            status: _isActive ? 'active' : 'inactive',
                            birthDate: birthDate!,
                            vehicleType: _vehicleTypeController.text,
                            address: _addressController.text,
                            createdAt: shipper?.createdAt ?? DateTime.now(),
                            isAuthenticated: _isAuthenticated,
                          );

                          try {
                            if (shipper == null) {
                              await viewModel.addShipper(shipperData);
                            } else {
                              await viewModel.updateShipper(
                                  shipperData.id, shipperData);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                              context.go(NameRouter.shippers);
                            }
                          } catch (e) {
                            setState(() {
                              errorText = 'Lỗi: \\n${e.toString()}';
                            });
                          }
                        },
                  child: viewModel.isLoading || isUploading
                      ? const CircularProgressIndicator()
                      : Text(shipper == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
