import 'package:flutter/material.dart';
import 'package:admin/reponsive.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.black87)),
        actions: [
          Container(
            width: 300,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/32.jpg',
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            itemBuilder: (_) => [
              const PopupMenuItem(child: Text('Profile')),
              const PopupMenuItem(child: Text('Settings')),
              const PopupMenuItem(child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side Navigation
              if (!Responsive.isMobile(context))
                Container(
                  width: 250,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Shop',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildNavItem(
                                Icons.dashboard,
                                'Dashboard',
                                _selectedIndex == 0,
                              ),
                              _buildNavItem(
                                Icons.swap_horiz_outlined,
                                'Transaction',
                                _selectedIndex == 1,
                              ),
                              _buildNavItem(
                                Icons.task_alt_outlined,
                                'Task',
                                _selectedIndex == 2,
                              ),
                              _buildNavItem(
                                Icons.folder_outlined,
                                'Documents',
                                _selectedIndex == 3,
                              ),
                              _buildNavItem(
                                Icons.store_outlined,
                                'Store',
                                _selectedIndex == 4,
                              ),
                              _buildNavItem(
                                Icons.notifications_outlined,
                                'Notification',
                                _selectedIndex == 5,
                              ),
                              _buildNavItem(
                                Icons.settings_outlined,
                                'Settings',
                                _selectedIndex == 6,
                              ),
                              _buildNavItem(
                                Icons.settings_applications,
                                'Settings',
                                _selectedIndex == 7,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Main Content
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // My Files Section
                              _buildSectionHeader('My Files', true),
                              const SizedBox(height: 16),
                              // Files Grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: Responsive.isDesktop(context)
                                      ? 4
                                      : Responsive.isTablet(context)
                                          ? 2
                                          : 1,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.3,
                                ),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  List<Map<String, dynamic>> fileCards = [
                                    {
                                      'title': 'Documents',
                                      'icon': Icons.description,
                                      'color': Colors.blue,
                                      'count': '1328 Files',
                                      'size': '1.9GB',
                                    },
                                    {
                                      'title': 'Google Drive',
                                      'icon': Icons.cloud,
                                      'color': Colors.amber,
                                      'count': '1328 Files',
                                      'size': '2.9GB',
                                    },
                                    {
                                      'title': 'One Drive',
                                      'icon': Icons.cloud_circle,
                                      'color': Colors.lightBlue,
                                      'count': '1328 Files',
                                      'size': '1GB',
                                    },
                                    {
                                      'title': 'Documents',
                                      'icon': Icons.folder,
                                      'color': Colors.blue,
                                      'count': '5328 Files',
                                      'size': '7.3GB',
                                    },
                                  ];
                                  return _buildFileCard(
                                    fileCards[index]['title'],
                                    fileCards[index]['icon'],
                                    fileCards[index]['color'],
                                    fileCards[index]['count'],
                                    fileCards[index]['size'],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Recent Files and Storage
                              Responsive.isDesktop(context)
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildRecentFilesSection(),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStorageDetailsSection(),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildRecentFilesSection(),
                                        const SizedBox(height: 16),
                                        _buildStorageDetailsSection(),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: isActive ? Colors.blue.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        onTap: () {
          setState(() {
            _selectedIndex = title == 'Dashboard'
                ? 0
                : title == 'Transaction'
                    ? 1
                    : title == 'Task'
                        ? 2
                        : title == 'Documents'
                            ? 3
                            : title == 'Store'
                                ? 4
                                : title == 'Notification'
                                    ? 5
                                    : title == 'Settings'
                                        ? 6
                                        : 7;
          });

          // Show a snackbar when menu item is clicked
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bạn đã chọn: $title'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showAddButton) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (showAddButton)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildFileCard(
    String title,
    IconData icon,
    Color color,
    String count,
    String size,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(count, style: const TextStyle(color: Colors.grey)),
              Text(size, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFilesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Files',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildFileHeader(),
              _buildFileRow('XD File', Colors.pink, '01-03-2021', '3.5mb'),
              _buildFileRow('Figma File', Colors.pink, '27-02-2021', '19.0mb'),
              _buildFileRow('Documents', Colors.red, '23-02-2021', '32.5mb'),
              _buildFileRow('Sound File', Colors.orange, '21-02-2021', '3.5mb'),
              _buildFileRow('Media File', Colors.amber, '23-02-2021', '2.5gb'),
              _buildFileRow('Sais PDF', Colors.green, '25-02-2021', '3.5mb'),
              _buildFileRow('Excel File', Colors.blue, '25-02-2021', '34.5mb'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'File Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          if (!Responsive.isMobile(context))
            const Expanded(
              flex: 1,
              child: Text(
                'Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          const Expanded(
            flex: 1,
            child: Text(
              'Size',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(
    String fileName,
    Color iconColor,
    String date,
    String size,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.insert_drive_file,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          if (!Responsive.isMobile(context))
            Expanded(
              flex: 1,
              child: Text(date, style: TextStyle(color: Colors.grey[600])),
            ),
          Expanded(
            flex: 1,
            child: Text(size, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 15.0,
              animation: true,
              percent: 0.29,
              center: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "29.1",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                  Text(
                    "Of 128GB",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.blue,
              backgroundColor: Colors.blue,
              arcBackgroundColor: Colors.red,
              arcType: ArcType.HALF,
              startAngle: 150,
              animationDuration: 1200,
            ),
          ),
          const SizedBox(height: 20),
          _buildStorageTypeRow(
            'Documents Files',
            '1328 Files',
            Colors.blue,
            '1.3GB',
          ),
          _buildStorageTypeRow(
            'Media Files',
            '1328 Files',
            Colors.cyan,
            '15.13GB',
          ),
          _buildStorageTypeRow(
            'Other Files',
            '1328 Files',
            Colors.amber,
            '1.3GB',
          ),
          _buildStorageTypeRow('Unknown', '140 Files', Colors.red, '1.3GB'),
        ],
      ),
    );
  }

  Widget _buildStorageTypeRow(
    String title,
    String count,
    Color color,
    String size,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              title.contains('Documents')
                  ? Icons.article
                  : title.contains('Media')
                      ? Icons.video_library
                      : title.contains('Other')
                          ? Icons.folder
                          : Icons.help_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  count,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(size, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
