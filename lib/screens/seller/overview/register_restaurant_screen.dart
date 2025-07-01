import 'dart:typed_data';

import 'package:admin/data/repositories/restaurant_repository.dart';
import 'package:admin/models/restaurant_model.dart';
import 'package:admin/routes/seller_router.dart';
import 'package:admin/screens/authentication/viewmodels/auth_viewmodel.dart';
import 'package:admin/ultils/local_storage/storage_utilly.dart';
import 'package:admin/viewmodels/restaurant_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RegisterRestaurantScreen extends StatefulWidget {
  const RegisterRestaurantScreen({super.key});

  @override
  State<RegisterRestaurantScreen> createState() =>
      _RegisterRestaurantScreenState();
}

class _RegisterRestaurantScreenState extends State<RegisterRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();

  Uint8List? _imageBytes;
  String? _selectedFileName;
  bool _isLoading = false;

  // Map related variables
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _openTimeController.text = '08:00'; // Default open time
    _closeTimeController.text = '22:00'; // Default close time
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
      });

      try {
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&countrycodes=vn&limit=5&addressdetails=1',
          ),
          headers: {'User-Agent': 'RestaurantApp/1.0'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _searchResults = data.map((item) {
              final address = item['address'] as Map<String, dynamic>;
              String displayName = '';

              if (address['road'] != null)
                displayName += '${address['road']}, ';
              if (address['suburb'] != null)
                displayName += '${address['suburb']}, ';
              if (address['city'] != null)
                displayName += '${address['city']}, ';
              if (address['state'] != null)
                displayName += '${address['state']}, ';
              if (address['country'] != null) displayName += address['country'];

              return {
                'name':
                    displayName.isNotEmpty ? displayName : item['display_name'],
                'lat': double.parse(item['lat']),
                'lon': double.parse(item['lon']),
                'address': address,
              };
            }).toList();
          });
        }
      } catch (e) {
        debugPrint('Error searching location: $e');
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    final lat = location['lat'];
    final lon = location['lon'];
    setState(() {
      _selectedLocation = LatLng(lat, lon);
      _searchResults = [];
      _searchController.clear();
      _addressController.text = location['name'];
    });
    _mapController.move(LatLng(lat, lon), 15.0);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _getAddressFromCoordinates(point);
  }

  Future<void> _getAddressFromCoordinates(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&addressdetails=1',
        ),
        headers: {'User-Agent': 'RestaurantApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>;
        String displayName = '';

        if (address['road'] != null) displayName += '${address['road']}, ';
        if (address['suburb'] != null) displayName += '${address['suburb']}, ';
        if (address['city'] != null) displayName += '${address['city']}, ';
        if (address['state'] != null) displayName += '${address['state']}, ';
        if (address['country'] != null) displayName += address['country'];

        setState(() {
          _addressController.text =
              displayName.isNotEmpty ? displayName : data['display_name'];
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  void _showMapDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Chọn địa chỉ nhà hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm địa điểm tại Việt Nam...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: _searchLocation,
                    ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final address =
                                result['address'] as Map<String, dynamic>?;
                            String detail = '';
                            if (address != null) {
                              if (address['road'] != null)
                                detail += '${address['road']}, ';
                              if (address['suburb'] != null)
                                detail += '${address['suburb']}, ';
                              if (address['city'] != null)
                                detail += '${address['city']}, ';
                              if (address['state'] != null)
                                detail += '${address['state']}, ';
                              if (address['country'] != null)
                                detail += address['country'];
                            }
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(
                                result['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: detail.isNotEmpty
                                  ? Text(detail,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey))
                                  : null,
                              onTap: () => _selectLocation(result),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Map
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(21.0278, 105.8342), // Hanoi
                        initialZoom: 13,
                        minZoom: 10,
                        maxZoom: 18,
                        onTap: _onMapTap,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.restaurant_app',
                        ),
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (_selectedLocation != null &&
                        _addressController.text.isNotEmpty)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 80,
                        child: Card(
                          color: Colors.white.withOpacity(0.95),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Địa điểm đã chọn:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(_addressController.text,
                                    style: const TextStyle(fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                    'Vĩ độ: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Kinh độ: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null
                            ? () {
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Xác nhận'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<String> _uploadImageToFirebase(
      Uint8List imageBytes, String restaurantId, String fileName) async {
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
          .child('restaurant_images')
          .child('$restaurantId$extension');

      final uploadTask = storageRef.putData(imageBytes, metadata);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> _createRestaurant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh cho nhà hàng')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // if (user == null) {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Lỗi: Người dùng chưa đăng nhập.')),
      //     );
      //     context.go(SellerRouter.dashboard); // Redirect to dashboard or login
      //     return;
      //   }
      // }
      //final userModel = context.read<AuthViewModel>().currentUser;
      final userModel = context.read<AuthViewModel>().currentUser;
      print('usser id  là ${userModel?.token ?? 'hai'}');
      String imageUrl = await _uploadImageToFirebase(
          _imageBytes!, userModel?.token ?? "", _selectedFileName!);
      final restaurant = RestaurantModel(
        token: userModel?.token ?? "",
        id: userModel?.token ?? "nhahang${DateTime.now()}",
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        location: const GeoPoint(0.0, 0.0), // Placeholder, can be updated later
        operatingHours: {
          'openTime': _openTimeController.text,
          'closeTime': _closeTimeController.text,
        },
        rating: 0.0,
        images: {'main': imageUrl, 'gallery': []},
        status: 'open', // Default to open when created
        minOrderAmount: 0.0,
        createdAt: DateTime.now(),
        categories: [], // Can be updated later
        metadata: {
          'isActive': true,
          'isVerified': false,
        },
      );
      await context.read<RestaurantViewModel>().addRestaurant(restaurant);

      // Set flag in local storage that restaurant info is completed
      await TLocalStorage.instance()
          .saveData('restaurant_info_completed_${userModel?.token}', true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tạo thông tin nhà hàng thành công!')));
        context.go(SellerRouter.dashboard);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi tạo nhà hàng: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký thông tin nhà hàng'),
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 600,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Thông tin nhà hàng',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên nhà hàng',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên nhà hàng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Địa chỉ',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập địa chỉ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _showMapDialog,
                            icon: const Icon(Icons.map),
                            label: const Text('Chọn trên bản đồ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedLocation != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Đã chọn: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _openTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Giờ mở cửa',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập giờ mở cửa';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _closeTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Giờ đóng cửa',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time_filled),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập giờ đóng cửa';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh chính'),
                          ),
                          const SizedBox(width: 12),
                          if (_imageBytes != null)
                            Image.memory(
                              _imageBytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          else if (_selectedFileName != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(_selectedFileName!),
                            )
                          else
                            const Text('Chưa chọn ảnh'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _createRestaurant,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Tạo nhà hàng',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
