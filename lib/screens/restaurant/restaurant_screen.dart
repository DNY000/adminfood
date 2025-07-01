import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/restaurant_viewmodel.dart';
import 'package:admin/models/restaurant_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:admin/routes/name_router.dart'; // Import NameRouter
import 'package:collection/collection.dart'; // Add this import for firstWhereOrNull

class RestaurantScreen extends StatelessWidget {
  final bool showAddDialog; // Added
  final bool showUpdateDialog; // Added
  final String? restaurantId; // Added

  const RestaurantScreen({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar for mobile view with menu icon
      appBar: Responsive.isMobile(context)
          ? AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu), // Menu icon
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Open the drawer
                  },
                ),
              ),
              title: Text('Quản lý Nhà hàng',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)), // Title
              backgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor, // Match background color
              elevation: 0, // Remove shadow
            )
          : null, // No AppBar on desktop
      // Use SideMenu as a drawer on mobile
      drawer: Responsive.isMobile(context) ? const SideMenu() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SideMenu is only shown directly in the Row on desktop
          if (Responsive.isDesktop(context))
            const Expanded(flex: 1, child: SideMenu()),
          Expanded(
            flex: 5,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: RestaurantContent(
                  showAddDialog: showAddDialog, // Pass parameter
                  showUpdateDialog: showUpdateDialog, // Pass parameter
                  restaurantId: restaurantId, // Pass parameter
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantContent extends StatefulWidget {
  final bool showAddDialog; // Added
  final bool showUpdateDialog; // Added
  final String? restaurantId; // Added

  const RestaurantContent({
    super.key,
    this.showAddDialog = false,
    this.showUpdateDialog = false,
    this.restaurantId,
  });

  @override
  State<RestaurantContent> createState() => _RestaurantContentState();
}

class _RestaurantContentState extends State<RestaurantContent> {
  final TextEditingController _searchController = TextEditingController();
  Uint8List? imageBytes;

  // Controllers for dialog fields
  final TextEditingController _dialogNameController = TextEditingController();
  final TextEditingController _dialogAddressController =
      TextEditingController();
  final TextEditingController _dialogDescriptionController =
      TextEditingController();
  TimeOfDay _dialogOpenTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _dialogCloseTime = const TimeOfDay(hour: 0, minute: 0);
  bool _dialogIsActive = true; // Assuming default active
  // You might need more controllers for other fields in RestaurantModel

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final viewModel = context.read<RestaurantViewModel>();
        await viewModel.loadRestaurants();
        _checkAndShowDialogs(); // Check and show dialogs on initial load
      },
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if dialog related parameters changed
    if (widget.showAddDialog != oldWidget.showAddDialog ||
        widget.showUpdateDialog != oldWidget.showUpdateDialog ||
        widget.restaurantId != oldWidget.restaurantId) {
      _checkAndShowDialogs(); // Check and show dialogs if parameters change
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dialogNameController.dispose();
    _dialogAddressController.dispose();
    _dialogDescriptionController.dispose();
    // Dispose other dialog controllers if added
    super.dispose();
  }

  // Method to check parameters and show appropriate dialog
  void _checkAndShowDialogs() {
    // Ensure context is valid before showing dialog
    if (!mounted) return;

    final viewModel = context.read<RestaurantViewModel>();

    if (widget.showAddDialog) {
      _showAddRestaurantDialog(context);
    } else if (widget.showUpdateDialog && widget.restaurantId != null) {
      final restaurantToUpdate = viewModel.restaurants.firstWhereOrNull(
        (r) => r.id == widget.restaurantId,
      );
      if (restaurantToUpdate != null) {
        _showEditRestaurantDialog(context, restaurantToUpdate);
      } else {
        print(
            'Error: Restaurant with ID ${widget.restaurantId} not found for update.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section - Adjusted for mobile
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hide the title on mobile because it's in the AppBar
            if (!Responsive.isMobile(context))
              Text(
                'Quản lý Nhà hàng',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium, // Changed style for consistency
              ),
            // Keep spacing between title/add button, adjust based on mobile/desktop
            SizedBox(
                width: Responsive.isMobile(context)
                    ? 0
                    : 16), // Reduced spacing on mobile
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add restaurant route to trigger dialog
                context.go('${NameRouter.restaurants}/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Nhà hàng'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24), // Spacing after header row

        // Search section
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nhà hàng...',
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
            // Có thể thêm filter theo danh mục ở đây nếu muốn
          ],
        ),
        const SizedBox(height: 24),

        // Restaurant list
        Expanded(
          child: Consumer<RestaurantViewModel>(
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
                        onPressed: () => viewModel.loadRestaurants(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredRestaurants = viewModel.restaurants;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredRestaurants = viewModel.searchRestaurants(
                  _searchController.text,
                );
              }

              if (filteredRestaurants.isEmpty) {
                return const Center(child: Text('Không tìm thấy nhà hàng nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredRestaurants, viewModel)
                  : _buildMobileView(filteredRestaurants, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<RestaurantModel> restaurants,
    RestaurantViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Ảnh')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Địa chỉ')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: restaurants.map((restaurant) {
          return DataRow(
            cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: restaurant.mainImage.isNotEmpty
                      ? NetworkImage(restaurant.mainImage)
                      : null,
                  child: restaurant.mainImage.isEmpty
                      ? const Icon(Icons.restaurant)
                      : null,
                ),
              ),
              DataCell(Text(restaurant.name)),
              DataCell(Text(restaurant.address)),
              DataCell(
                FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          restaurant.isActive
                              ? 'Đang hoạt động'
                              : 'Ngừng hoạt động',
                          style: TextStyle(
                            color:
                                restaurant.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to update restaurant route to trigger dialog
                        context
                            .go('${NameRouter.restaurants}/${restaurant.id}');
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
                              'Bạn có chắc muốn xóa nhà hàng ${restaurant.name}?',
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
                          await viewModel.deleteRestaurant(restaurant.id);
                          await viewModel.loadRestaurants();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            onSelectChanged: (selected) {
              if (selected == true) {
                // Navigate to restaurant detail route
                context.go('${NameRouter.detailRestaurants}/${restaurant.id}');
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileView(
    List<RestaurantModel> restaurants,
    RestaurantViewModel viewModel,
  ) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return GestureDetector(
          onTap: () {
            // Navigate to restaurant detail route on tap
            context.go('${NameRouter.detailRestaurants}/${restaurant.id}');
          },
          child: Card(
            margin: const EdgeInsets.only(
                bottom: 16), // Keep bottom margin for spacing between cards
            child: Padding(
              padding: const EdgeInsets.all(12), // Adjusted padding inside card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: restaurant.mainImage.isNotEmpty
                            ? NetworkImage(restaurant.mainImage)
                            : null,
                        child: restaurant.mainImage.isEmpty
                            ? const Icon(Icons.restaurant)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 17, // Adjusted font size slightly
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(restaurant.address,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 12), // Adjusted spacing after image/name row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // Adjusted horizontal padding
                          vertical: 5, // Adjusted vertical padding
                        ),
                        decoration: BoxDecoration(
                          color:
                              restaurant.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isActive
                              ? 'Đang hoạt động'
                              : 'Ngừng hoạt động',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11, // Adjusted font size
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Navigate to update restaurant route on edit button press
                              context.go(
                                  '${NameRouter.restaurants}/${restaurant.id}');
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
                                    'Bạn có chắc muốn xóa nhà hàng ${restaurant.name}?',
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
                                await viewModel.deleteRestaurant(restaurant.id);
                                await viewModel.loadRestaurants();
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
          ),
        );
      },
    );
  }

  void _showAddRestaurantDialog(BuildContext context) {
    // Clear controllers for adding
    _dialogNameController.clear();
    _dialogAddressController.clear();
    _dialogDescriptionController.clear();
    _dialogOpenTime = const TimeOfDay(hour: 8, minute: 0);
    _dialogCloseTime = const TimeOfDay(hour: 22, minute: 0);
    _dialogIsActive = true;

    final isDesktop = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isDesktop) {
              // Custom Dialog lớn cho desktop
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  width: 520,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thêm Nhà hàng',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _dialogNameController,
                          decoration:
                              const InputDecoration(labelText: 'Tên nhà hàng'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _dialogAddressController,
                          decoration:
                              const InputDecoration(labelText: 'Địa chỉ'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _dialogDescriptionController,
                          decoration: const InputDecoration(labelText: 'Mô tả'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Giờ mở cửa'),
                                  TimePickerSpinner(
                                    time: DateTime(
                                        0,
                                        0,
                                        0,
                                        _dialogOpenTime.hour,
                                        _dialogOpenTime.minute),
                                    onTimeChange: (time) {
                                      setState(() {
                                        _dialogOpenTime = TimeOfDay(
                                            hour: time.hour,
                                            minute: time.minute);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Giờ đóng cửa'),
                                  TimePickerSpinner(
                                    time: DateTime(
                                        0,
                                        0,
                                        0,
                                        _dialogCloseTime.hour,
                                        _dialogCloseTime.minute),
                                    onTimeChange: (time) {
                                      setState(() {
                                        _dialogCloseTime = TimeOfDay(
                                            hour: time.hour,
                                            minute: time.minute);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Trạng thái hoạt động'),
                          value: _dialogIsActive,
                          onChanged: (value) {
                            setState(() {
                              _dialogIsActive = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text('Hủy'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.go(NameRouter.restaurants);
                              },
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              child: const Text('Thêm'),
                              onPressed: () async {
                                if (_dialogNameController.text.isEmpty ||
                                    _dialogAddressController.text.isEmpty ||
                                    _dialogDescriptionController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Vui lòng điền đầy đủ thông tin'),
                                    ),
                                  );
                                  return;
                                }
                                final viewModel =
                                    context.read<RestaurantViewModel>();
                                final newRestaurant = RestaurantModel(
                                  token: '',
                                  id: '',
                                  name: _dialogNameController.text,
                                  description:
                                      _dialogDescriptionController.text,
                                  address: _dialogAddressController.text,
                                  location: GeoPoint(0, 0),
                                  operatingHours: {
                                    'openTime':
                                        '${_dialogOpenTime.hour}:${_dialogOpenTime.minute}',
                                    'closeTime':
                                        '${_dialogCloseTime.hour}:${_dialogCloseTime.minute}',
                                  },
                                  rating: 0.0,
                                  images: {'main': '', 'gallery': []},
                                  status: 'closed',
                                  minOrderAmount: 0.0,
                                  createdAt: DateTime.now(),
                                  categories: [],
                                  metadata: {
                                    'isActive': _dialogIsActive,
                                    'isVerified': false,
                                    'lastUpdated': DateTime.now(),
                                  },
                                );
                                await viewModel.addRestaurant(newRestaurant);
                                Navigator.of(context).pop();
                                context.go(NameRouter.restaurants);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // Mobile: giữ AlertDialog nhỏ gọn
              return AlertDialog(
                title: const Text('Thêm Nhà hàng'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _dialogNameController,
                        decoration:
                            const InputDecoration(labelText: 'Tên nhà hàng'),
                      ),
                      TextField(
                        controller: _dialogAddressController,
                        decoration: const InputDecoration(labelText: 'Địa chỉ'),
                      ),
                      TextField(
                        controller: _dialogDescriptionController,
                        decoration: const InputDecoration(labelText: 'Mô tả'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Giờ mở cửa'),
                                TimePickerSpinner(
                                  time: DateTime(0, 0, 0, _dialogOpenTime.hour,
                                      _dialogOpenTime.minute),
                                  onTimeChange: (time) {
                                    setState(() {
                                      _dialogOpenTime = TimeOfDay(
                                          hour: time.hour, minute: time.minute);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Giờ đóng cửa'),
                                TimePickerSpinner(
                                  time: DateTime(0, 0, 0, _dialogCloseTime.hour,
                                      _dialogCloseTime.minute),
                                  onTimeChange: (time) {
                                    setState(() {
                                      _dialogCloseTime = TimeOfDay(
                                          hour: time.hour, minute: time.minute);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Trạng thái hoạt động'),
                        value: _dialogIsActive,
                        onChanged: (value) {
                          setState(() {
                            _dialogIsActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Hủy'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(NameRouter.restaurants);
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Thêm'),
                    onPressed: () async {
                      if (_dialogNameController.text.isEmpty ||
                          _dialogAddressController.text.isEmpty ||
                          _dialogDescriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng điền đầy đủ thông tin'),
                          ),
                        );
                        return;
                      }
                      final viewModel = context.read<RestaurantViewModel>();
                      final newRestaurant = RestaurantModel(
                        token: '',
                        id: '',
                        name: _dialogNameController.text,
                        description: _dialogDescriptionController.text,
                        address: _dialogAddressController.text,
                        location: GeoPoint(0, 0),
                        operatingHours: {
                          'openTime':
                              '${_dialogOpenTime.hour}:${_dialogOpenTime.minute}',
                          'closeTime':
                              '${_dialogCloseTime.hour}:${_dialogCloseTime.minute}',
                        },
                        rating: 0.0,
                        images: {'main': '', 'gallery': []},
                        status: 'closed',
                        minOrderAmount: 0.0,
                        createdAt: DateTime.now(),
                        categories: [],
                        metadata: {
                          'isActive': _dialogIsActive,
                          'isVerified': false,
                          'lastUpdated': DateTime.now(),
                        },
                      );
                      await viewModel.addRestaurant(newRestaurant);
                      Navigator.of(context).pop();
                      context.go(NameRouter.restaurants);
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  void _showEditRestaurantDialog(
      BuildContext context, RestaurantModel restaurant) {
    // Initialize controllers with restaurant data
    _dialogNameController.text = restaurant.name;
    _dialogAddressController.text = restaurant.address;
    _dialogDescriptionController.text = restaurant.description;

    // Parse time from operating hours
    final openTimeParts =
        restaurant.operatingHours['openTime']?.split(':') ?? ['00', '00'];
    final closeTimeParts =
        restaurant.operatingHours['closeTime']?.split(':') ?? ['00', '00'];
    _dialogOpenTime = TimeOfDay(
      hour: int.parse(openTimeParts[0]),
      minute: int.parse(openTimeParts[1]),
    );
    _dialogCloseTime = TimeOfDay(
      hour: int.parse(closeTimeParts[0]),
      minute: int.parse(closeTimeParts[1]),
    );
    _dialogIsActive = restaurant.metadata['isActive'] == true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa Nhà hàng'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _dialogNameController,
                      decoration:
                          const InputDecoration(labelText: 'Tên nhà hàng'),
                    ),
                    TextField(
                      controller: _dialogAddressController,
                      decoration: const InputDecoration(labelText: 'Địa chỉ'),
                    ),
                    TextField(
                      controller: _dialogDescriptionController,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Giờ mở cửa'),
                              TimePickerSpinner(
                                time: DateTime(0, 0, 0, _dialogOpenTime.hour,
                                    _dialogOpenTime.minute),
                                onTimeChange: (time) {
                                  setState(() {
                                    _dialogOpenTime = TimeOfDay(
                                        hour: time.hour, minute: time.minute);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Giờ đóng cửa'),
                              TimePickerSpinner(
                                time: DateTime(0, 0, 0, _dialogCloseTime.hour,
                                    _dialogCloseTime.minute),
                                onTimeChange: (time) {
                                  setState(() {
                                    _dialogCloseTime = TimeOfDay(
                                        hour: time.hour, minute: time.minute);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Trạng thái hoạt động'),
                      value: _dialogIsActive,
                      onChanged: (value) {
                        setState(() {
                          _dialogIsActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(NameRouter.restaurants);
                  },
                ),
                ElevatedButton(
                  child: const Text('Lưu'),
                  onPressed: () async {
                    if (_dialogNameController.text.isEmpty ||
                        _dialogAddressController.text.isEmpty ||
                        _dialogDescriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    final viewModel = context.read<RestaurantViewModel>();
                    final updatedRestaurant = restaurant.copyWith(
                      name: _dialogNameController.text,
                      description: _dialogDescriptionController.text,
                      address: _dialogAddressController.text,
                      operatingHours: {
                        'openTime':
                            '${_dialogOpenTime.hour}:${_dialogOpenTime.minute}',
                        'closeTime':
                            '${_dialogCloseTime.hour}:${_dialogCloseTime.minute}',
                      },
                      metadata: {
                        ...restaurant.metadata,
                        'isActive': _dialogIsActive,
                        'lastUpdated': DateTime.now(),
                      },
                    );

                    await viewModel.updateRestaurant(updatedRestaurant);
                    Navigator.of(context).pop();
                    context.go(NameRouter.restaurants);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
