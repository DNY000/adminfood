import 'package:flutter/material.dart';
import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/responsive.dart';

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Responsive.isMobile(context) ? null : GlobalKey<ScaffoldState>(),
      drawer: Responsive.isMobile(context) ? const SellerSideMenu() : null,
      appBar: AppBar(
        title: const Text('Cài đặt nhà hàng'),
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
              child: Center(
                child: Text('Seller Settings Screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
