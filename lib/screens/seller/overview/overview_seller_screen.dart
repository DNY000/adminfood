import 'package:admin/screens/authentication/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../models/restaurant_model.dart';

class OverviewSellerScreen extends StatefulWidget {
  const OverviewSellerScreen({Key? key}) : super(key: key);

  @override
  State<OverviewSellerScreen> createState() => _OverviewSellerScreenState();
}

class _OverviewSellerScreenState extends State<OverviewSellerScreen> {
  RestaurantModel? restaurant;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final user = context.read<AuthViewModel>().currentUser;
      if (user == null) return;

      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('id', isEqualTo: user.token)
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan nhà hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          backgroundImage: restaurant!.mainImage.isNotEmpty
                              ? NetworkImage(restaurant!.mainImage)
                              : null,
                          child: restaurant!.mainImage.isEmpty
                              ? const Icon(Icons.restaurant, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant!.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant!.rating.toStringAsFixed(1),
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
                                  borderRadius: BorderRadius.circular(12),
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

            // Statistics Section
            const Text(
              'Thống kê',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Tổng đơn hàng',
                  '0',
                  Icons.shopping_cart,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Đơn hàng hôm nay',
                  '0',
                  Icons.today,
                  Colors.green,
                ),
                _buildStatCard(
                  'Doanh thu hôm nay',
                  '0đ',
                  Icons.attach_money,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Đánh giá trung bình',
                  restaurant!.rating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ],
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
