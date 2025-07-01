import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../models/user_model.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        context.read<UserViewModel>().getUserById(currentUser.uid);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<UserViewModel, UserModel?>(
      selector: (_, viewModel) => viewModel.currentUser,
      builder: (context, user, child) {
        if (user?.role.name == "sellers") {
          return const SellerSideMenu();
        }

        // Nếu là admin, hiển thị menu admin
        return Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      // height: 50,
                    ),
                    // Text(
                    //   user?.role.name == 'admin' ? "admin" : "sellers",
                    //   style: const TextStyle(
                    //     color: Colors.white70,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ],
                ),
              ),
              DrawerListTile(
                title: "Dashboard",
                svgSrc: "assets/icons/menu_dashboard.svg",
                press: () {
                  context.go(NameRouter.dashboard);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              DrawerListTile(
                title: "Category",
                svgSrc: "assets/icons/category.svg",
                press: () {
                  context.go(NameRouter.categories);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              DrawerListTile(
                title: "Restaurant",
                svgSrc: "assets/icons/restaurant.svg",
                press: () {
                  context.go(NameRouter.restaurants);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              // DrawerListTile(
              //   title: "Shipper",
              //   svgSrc: "assets/icons/shipper.svg",
              //   press: () {
              //     context.go(NameRouter.shippers);
              //     if (Scaffold.of(context).isDrawerOpen) {
              //       Navigator.pop(context);
              //     }
              //   },
              // ),
              DrawerListTile(
                title: "User",
                svgSrc: "assets/icons/user.svg",
                press: () {
                  context.go(NameRouter.users);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              // DrawerListTile(
              //   title: "Notifications",
              //   svgSrc: "assets/icons/notification.svg",
              //   press: () {
              //     context.go(NameRouter.notifications);
              //     if (Scaffold.of(context).isDrawerOpen) {
              //       Navigator.pop(context);
              //     }
              //   },
              // ),
              DrawerListTile(
                title: "Banner",
                svgSrc: "assets/icons/ads.svg",
                press: () {
                  context.go(NameRouter.banner);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              // DrawerListTile(
              //   title: "Settings",
              //   svgSrc: "assets/icons/menu_setting.svg",
              //   press: () {
              //     context.go(NameRouter.settings);
              //     if (Scaffold.of(context).isDrawerOpen) {
              //       Navigator.pop(context);
              //     }
              //   },
              // ),
              const Divider(),
              DrawerListTile(
                title: "Logout",
                svgSrc: "assets/icons/logout.svg",
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
      },
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        height: svgSrc.contains("assets/icons/shipper.svg") ? 24 : 16,
      ),
      title: Text(title, style: const TextStyle(color: Colors.white54)),
    );
  }
}
