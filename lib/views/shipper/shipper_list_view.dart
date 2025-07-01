// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:admin/viewmodels/shipper_viewmodel.dart';
// import 'package:admin/models/shipper_model.dart';

// class ShipperListView extends StatefulWidget {
//   const ShipperListView({super.key});

//   @override
//   State<ShipperListView> createState() => _ShipperListViewState();
// }

// class _ShipperListViewState extends State<ShipperListView> {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedStatus = 'all';

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => context.read<ShipperViewModel>().loadShippers());
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quản lý Shipper'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => context.read<ShipperViewModel>().loadShippers(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search and filter section
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Tìm kiếm shipper...',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) => setState(() {}),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 DropdownButton<String>(
//                   value: _selectedStatus,
//                   items: const [
//                     DropdownMenuItem(value: 'all', child: Text('Tất cả')),
//                     DropdownMenuItem(
//                       value: 'active',
//                       child: Text('Đang hoạt động'),
//                     ),
//                     DropdownMenuItem(
//                       value: 'inactive',
//                       child: Text('Không hoạt động'),
//                     ),
//                   ],
//                   onChanged: (value) =>
//                       setState(() => _selectedStatus = value!),
//                 ),
//               ],
//             ),
//           ),

//           // Shipper list
//           Expanded(
//             child: Consumer<ShipperViewModel>(
//               builder: (context, viewModel, child) {
//                 if (viewModel.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (viewModel.error != null) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(viewModel.error!),
//                         ElevatedButton(
//                           onPressed: () => viewModel.loadShippers(),
//                           child: const Text('Thử lại'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 var filteredShippers = viewModel.shippers;

//                 // Apply search filter
//                 if (_searchController.text.isNotEmpty) {
//                   filteredShippers = viewModel.searchShippers(
//                     _searchController.text,
//                   );
//                 }

//                 // Apply status filter
//                 if (_selectedStatus != 'all') {
//                   filteredShippers = filteredShippers
//                       .where((shipper) => shipper.status == _selectedStatus)
//                       .toList();
//                 }

//                 if (filteredShippers.isEmpty) {
//                   return const Center(
//                     child: Text('Không tìm thấy shipper nào'),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: filteredShippers.length,
//                   itemBuilder: (context, index) {
//                     final shipper = filteredShippers[index];
//                     return _buildShipperCard(shipper, viewModel);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShipperCard(ShipperModel shipper, ShipperViewModel viewModel) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: shipper.avatarUrl.isNotEmpty
//               ? NetworkImage(shipper.avatarUrl)
//               : null,
//           child: shipper.avatarUrl.isEmpty
//               ? Text(shipper.name[0].toUpperCase())
//               : null,
//         ),
//         title: Text(shipper.name),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('SĐT: ${shipper.phoneNumber}'),
//             Text('Email: ${shipper.email}'),
//             Text('Trạng thái: ${shipper.status}'),
//           ],
//         ),
//         trailing: PopupMenuButton(
//           itemBuilder: (context) => [
//             const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
//             const PopupMenuItem(value: 'delete', child: Text('Xóa')),
//           ],
//           onSelected: (value) async {
//             if (value == 'edit') {
//             } else if (value == 'delete') {
//               final confirmed = await showDialog<bool>(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Xác nhận xóa'),
//                   content: Text(
//                     'Bạn có chắc muốn xóa shipper ${shipper.name}?',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text('Hủy'),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text('Xóa'),
//                     ),
//                   ],
//                 ),
//               );

//               if (confirmed == true) {
//                 await viewModel.deleteShipper(shipper.id);
//               }
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
