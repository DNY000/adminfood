import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/seller_router.dart';
import '../../../routes/name_router.dart';
import '../../../viewmodels/user_viewmodel.dart';

class SellerSideMenu extends StatelessWidget {
  const SellerSideMenu({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.go(NameRouter.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi đăng xuất')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 50,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Seller Dashboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          DrawerListTile(
            title: "Tổng quan",
            icon: Icons.dashboard,
            press: () {
              context.go(SellerRouter.dashboard);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Món ăn",
            icon: Icons.restaurant_menu,
            press: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              final restaurantId = currentUser?.uid ?? '';

              if (restaurantId.isNotEmpty) {
                context.go('${SellerRouter.foods}?restaurantId=$restaurantId');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lỗi: Không tìm thấy ID người dùng.')),
                );
              }
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Đơn hàng",
            icon: Icons.shopping_cart,
            press: () {
              context.go(SellerRouter.orders);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Thông tin nhà hàng",
            icon: Icons.restaurant,
            press: () {
              context.go(SellerRouter.overview);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          // DrawerListTile(
          //   title: "Cài đặt",
          //   icon: Icons.settings,
          //   press: () {
          //     context.go(SellerRouter.settings);
          //     if (Scaffold.of(context).isDrawerOpen) {
          //       Navigator.pop(context);
          //     }
          //   },
          // ),
          const Divider(),
          DrawerListTile(
            title: "Đăng xuất",
            icon: Icons.logout,
            press: () {
              _handleLogout(context);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: const TextStyle(color: Colors.white54)),
    );
  }
}
