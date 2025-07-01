import 'package:admin/ultils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/user_viewmodel.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';
import 'package:collection/collection.dart'; // Import collection for firstWhereOrNull
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class UsersScreen extends StatelessWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? userId;
  final String? searchQuery;

  const UsersScreen({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.userId,
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
              title: Text('Quản lý Người dùng',
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
                child: UsersContent(
                  showAddDialog: showAddDialog,
                  showUpdateDialog: showUpdateDialog,
                  userId: userId,
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

class UsersContent extends StatefulWidget {
  final bool showAddDialog;
  final bool showUpdateDialog;
  final String? userId;
  final String? searchQuery;

  const UsersContent({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.userId,
    this.searchQuery,
  });

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';
  // Add controllers for user add/edit form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Assuming password for add (for Firebase Auth)
  final TextEditingController _avatarUrlController = TextEditingController();
  Role _selectedAddRole = Role.user; // Default role for add

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<UserViewModel>();
      await viewModel.getAllUsers();

      if (widget.showAddDialog) {
        _showUserDialog(context);
      }
    });
  }

  @override
  void didUpdateWidget(covariant UsersContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Logic for showing update dialog
    if (widget.showUpdateDialog &&
        widget.userId != null &&
        widget.userId != oldWidget.userId) {
      final viewModel = context.read<UserViewModel>();
      final userToUpdate = viewModel.users.firstWhereOrNull(
        (user) => user.id == widget.userId,
      );
      if (userToUpdate != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUserDialog(context, userToUpdate);
        });
      } else {
        if (mounted) {
          context.go(NameRouter.users);
        }
      }
    } else if (oldWidget.showUpdateDialog && !widget.showUpdateDialog) {
      // If navigating away from update route (e.g. dialog is closed)
      // Ensure we are back on the base users route
      final currentUri = GoRouterState.of(context).uri;
      if (currentUri.pathSegments.isNotEmpty &&
          currentUri.pathSegments.last != 'users') {
        if (mounted) {
          context.go(NameRouter.users);
        }
      }
    }

    // Logic for showing add dialog when navigating from another route to /users/add
    if (widget.showAddDialog && !oldWidget.showAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUserDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  // Method to show add/edit user dialog
  void _showUserDialog(BuildContext context, [UserModel? user]) {
    final isEditing = user != null;
    // Initialize controllers with user data if editing
    if (isEditing) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? ''; // Handle null email
      _phoneController.text = user.phoneNumber;
      _avatarUrlController.text = user.avatarUrl; // avatarUrl is String
      _selectedAddRole = user.role;
      _passwordController.clear(); // Don't pre-fill password for security
    } else {
      // Clear controllers for adding
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _avatarUrlController.clear();
      _selectedAddRole = Role.user; // Reset to default
    }

    Uint8List? imageBytes;
    String? selectedFileName;
    String? imageUrl = isEditing ? user?.avatarUrl : null;
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
            .child('user_avatars')
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
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Chỉnh sửa Người dùng' : 'Thêm Người dùng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Tên người dùng'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Số điện thoại'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  if (!isEditing)
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Mật khẩu'),
                      obscureText: true,
                    ),
                  if (!isEditing) const SizedBox(height: 16),
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
                                    _avatarUrlController.text = url;
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
                        label: const Text('Chọn ảnh đại diện'),
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
                    decoration:
                        const InputDecoration(labelText: 'URL Ảnh đại diện'),
                    keyboardType: TextInputType.url,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Role>(
                    value: _selectedAddRole,
                    decoration: const InputDecoration(labelText: 'Vai trò'),
                    items: Role.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAddRole = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go(NameRouter.users);
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        child: Text(isEditing ? 'Lưu' : 'Thêm'),
                        onPressed: isUploading
                            ? null
                            : () async {
                                final viewModel = context.read<UserViewModel>();
                                if (isEditing) {
                                  final updatedUser = user!.copyWith(
                                    name: _nameController.text,
                                    email: _emailController.text.isEmpty
                                        ? null
                                        : _emailController
                                            .text, // Allow null email
                                    phoneNumber: _phoneController.text,
                                    avatarUrl: _avatarUrlController
                                        .text, // avatarUrl is String
                                    role: _selectedAddRole,
                                    lastUpdated: DateTime.now(),
                                  );
                                  await viewModel.updateUser(updatedUser);
                                } else {
                                  if (_nameController.text.isEmpty ||
                                      _phoneController.text.isEmpty ||
                                      _passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Vui lòng điền đầy đủ thông tin (Tên, Số điện thoại, Mật khẩu)')),
                                    );
                                    return;
                                  }
                                  final newUser = UserModel(
                                    id: '',
                                    name: _nameController.text,
                                    email: _emailController.text.isEmpty
                                        ? null
                                        : _emailController.text,
                                    phoneNumber: _phoneController.text,
                                    avatarUrl: _avatarUrlController.text,
                                    addresses: [],
                                    role: _selectedAddRole,
                                    createdAt: DateTime.now(),
                                    dateOfBirth: DateTime.now(),
                                    lastUpdated: DateTime.now(),
                                  );
                                  await viewModel.addUser(newUser);
                                }
                                Navigator.of(context).pop();
                                context.go(NameRouter.users);
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
                'Quản lý Người dùng',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add user route which will trigger dialog
                context.go('${NameRouter.users}/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Người dùng'),
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
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm người dùng...',
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
                    value: _selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('Người dùng'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRole = value!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Users list
        Expanded(
          child: Consumer<UserViewModel>(
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
                        onPressed: () => viewModel.getAllUsers(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredUsers = viewModel.users;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredUsers = filteredUsers.where((user) {
                  final searchLower = _searchController.text.toLowerCase();
                  return user.name.toLowerCase().contains(searchLower) ||
                      user.email?.toLowerCase().contains(searchLower) == true ||
                      user.phoneNumber.toLowerCase().contains(searchLower);
                }).toList();
                // context.go('${NameRouter.searchUsers}/${_searchController.text}');
              }

              // Apply role filter
              if (_selectedRole != 'all') {
                filteredUsers = filteredUsers
                    .where((user) => user.role.name == _selectedRole)
                    .toList();
              }

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text('Không tìm thấy người dùng nào'),
                );
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredUsers, viewModel)
                  : _buildMobileView(filteredUsers, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(List<UserModel> users, UserViewModel viewModel) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Avatar')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Số điện thoại')),
          DataColumn(label: Text('Vai trò')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: users.map((user) {
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                // Navigate to update user route which will trigger dialog
                context.go('${NameRouter.users}/${user.id}');
              }
            },
            cells: [
              DataCell(CircleAvatar(
                backgroundImage: user.avatarUrl.toAvatarImage(),
                child: user.avatarUrl.toAvatarImage() == null
                    ? const Icon(Icons.person)
                    : null,
              )),
              DataCell(Text(user.name)),
              DataCell(Text(user.email ?? 'N/A')),
              DataCell(Text(user.phoneNumber)),
              DataCell(Text(user.role.name)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to update user route
                        context.go('${NameRouter.users}/${user.id}');
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
                                'Bạn có chắc muốn xóa người dùng ${user.name}?'),
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
                          await viewModel.deleteUser(user.id);
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

  Widget _buildMobileView(List<UserModel> users, UserViewModel viewModel) {
    // Implement mobile view similar to desktop view but perhaps using ListTile or Card
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            title: Text(user.name),
            subtitle: Text('${user.email ?? 'N/A'} - ${user.phoneNumber}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to update user route
                    context.go('${NameRouter.users}/${user.id}');
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
                            'Bạn có chắc muốn xóa người dùng ${user.name}?'),
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
                      await viewModel.deleteUser(user.id);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
