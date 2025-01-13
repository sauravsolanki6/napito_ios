// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
// // import 'package:ms_salon_task/Book_appointment/select_package_details.dart';

// // class SelectPackagePage extends StatefulWidget {
// //   @override
// //   _SelectPackagePageState createState() => _SelectPackagePageState();
// // }

// // class _SelectPackagePageState extends State<SelectPackagePage> {
// //   bool isSelected = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         backgroundColor: Color(0xFFFFFFFF),
// //         elevation: 0,
// //         title: Row(
// //           children: [
// //             IconButton(
// //               icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
// //               onPressed: () {
// //                 Navigator.pop(context);
// //               },
// //             ),
// //             Text(
// //               'Select Package',
// //               style: TextStyle(
// //                 fontFamily: 'Lato',
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.w600,
// //                 color: Colors.black,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: Column(
// //         // Wrap ListView with Column
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
// //             child: Container(
// //               width: 430,
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 16),
// //                     height: 40,
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFFF2F2F2),
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: TextField(
// //                       decoration: InputDecoration(
// //                         hintText: 'Search...',
// //                         hintStyle: TextStyle(
// //                           fontFamily: 'Lato',
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w400,
// //                           height: 14.4 / 6.4,
// //                           color: Color(0xFFC4C4C4),
// //                         ),
// //                         border: InputBorder.none,
// //                         icon: Padding(
// //                           padding: const EdgeInsets.only(top: 2.0),
// //                           child: Icon(
// //                             CupertinoIcons.search,
// //                             size: 25,
// //                             color: Colors.blue,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Container(
// //                     margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(
// //                         color: CustomColors.backgroundtext,
// //                         width: 0.5,
// //                       ),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Color(0x00000008),
// //                           offset: Offset(15, 15),
// //                           blurRadius: 90,
// //                           spreadRadius: 4,
// //                         ),
// //                       ],
// //                     ),
// //                     height: 43,
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           child: GestureDetector(
// //                             onTap: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                     builder: (context) =>
// //                                         BookAppointmentPage()),
// //                               );
// //                             },
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.only(
// //                                   topLeft: Radius.circular(10),
// //                                   bottomLeft: Radius.circular(10),
// //                                 ),
// //                               ),
// //                               child: Center(
// //                                 child: Text(
// //                                   'Services',
// //                                   style: TextStyle(
// //                                     fontFamily: 'Lato',
// //                                     color: CustomColors.backgroundtext,
// //                                     fontWeight: FontWeight.normal,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           child: GestureDetector(
// //                             onTap: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                     builder: (context) => SelectPackagePage()),
// //                               );
// //                             },
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 color: CustomColors.backgroundtext,
// //                                 borderRadius: BorderRadius.only(
// //                                   topRight: Radius.circular(10),
// //                                   bottomRight: Radius.circular(10),
// //                                 ),
// //                               ),
// //                               child: Center(
// //                                 child: Text(
// //                                   'Package',
// //                                   style: TextStyle(
// //                                     fontFamily: 'Lato',
// //                                     color: Colors.white,
// //                                     fontWeight: FontWeight.normal,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 10),
// //                   GestureDetector(
// //                     onTap: () {
// //                       setState(() {
// //                         isSelected = !isSelected;
// //                       });
// //                     },
// //                     child: HeadMassageContainer(
// //                       isSelected: isSelected,
// //                       imagePath: 'assets/bridal.png',
// //                       title: 'Bridal Beauty Makeup\n(वधू सौंदर्य मेकअप)',
// //                       description: 'Special package, valid until May 10, 2024 ',
// //                       price: '₹15000',
// //                       duration: '1 hrs',
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class HeadMassageContainer extends StatelessWidget {
// //   final bool isSelected;
// //   final String imagePath;
// //   final String title;
// //   final String description;
// //   final String price;
// //   final String duration;

// //   const HeadMassageContainer({
// //     Key? key,
// //     required this.isSelected,
// //     required this.imagePath,
// //     required this.title,
// //     required this.description,
// //     required this.price,
// //     required this.duration,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       height: 130,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(10),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Color(0x00000008),
// //             offset: Offset(15, 15),
// //             blurRadius: 90,
// //             spreadRadius: 4,
// //           ),
// //         ],
// //       ),
// //       child: Stack(
// //         children: [
// //           Positioned(
// //             top: -40,
// //             left: -38,
// //             child: Container(
// //               width: 200,
// //               height: 200,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(25),
// //                 image: DecorationImage(
// //                   image: AssetImage(imagePath),
// //                   fit: BoxFit.cover,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             top: 11,
// //             left: 90,
// //             child: Text(
// //               title,
// //               style: TextStyle(
// //                 fontFamily: 'Lato',
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF424752),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             top: 65,
// //             left: 90,
// //             child: Text(
// //               description,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontFamily: 'Lato',
// //                 fontSize: 14,
// //                 color: Color(0xFF424752),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             top: 100,
// //             left: 95,
// //             child: Row(
// //               children: [
// //                 Text(
// //                   price,
// //                   style: TextStyle(
// //                     fontFamily: 'Lato',
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF424752),
// //                   ),
// //                 ),
// //                 SizedBox(width: 10),
// //                 GestureDetector(
// //                   onTap: () {
// //                     showDialog(
// //                       context: context,
// //                       builder: (BuildContext context) {
// //                         return AlertDialog(
// //                           content: Container(
// //                             width: 186,
// //                             height: 161,
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(bottom: 8.0),
// //                                   child: Text(
// //                                     'Offered Product',
// //                                     style: TextStyle(
// //                                       fontFamily: 'Lato',
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.w600,
// //                                       color: Color(0xFF424752),
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 Container(
// //                                   width: double.infinity,
// //                                   height: 1,
// //                                   color: Color(0xFFD3D6DA),
// //                                   margin: EdgeInsets.symmetric(vertical: 8.0),
// //                                 ),
// //                                 SizedBox(height: 10.35),
// //                                 Text(
// //                                   'Cleansers',
// //                                   style: TextStyle(
// //                                     fontFamily: 'Lato',
// //                                     fontSize: 12,
// //                                     fontWeight: FontWeight.w600,
// //                                     height: 14.4 / 12,
// //                                     letterSpacing: 0.02,
// //                                     color: Color(0xFF424752),
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: 28.35),
// //                                 Text(
// //                                   'Face Creme',
// //                                   style: TextStyle(
// //                                     fontFamily: 'Lato',
// //                                     fontSize: 12,
// //                                     fontWeight: FontWeight.w600,
// //                                     height: 14.4 / 12,
// //                                     letterSpacing: 0.02,
// //                                     color: Color(0xFF424752),
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: 28.35),
// //                                 Text(
// //                                   'Lotion',
// //                                   style: TextStyle(
// //                                     fontFamily: 'Lato',
// //                                     fontSize: 12,
// //                                     fontWeight: FontWeight.w600,
// //                                     height: 14.4 / 12,
// //                                     letterSpacing: 0.02,
// //                                     color: Color(0xFF424752),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     );
// //                   },
// //                   child: Row(
// //                     children: [
// //                       Text(
// //                         'Offered Product',
// //                         style: TextStyle(
// //                           fontFamily: 'Lato',
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w500,
// //                           color: Color(0xFF424752),
// //                         ),
// //                       ),
// //                       SizedBox(width: 0),
// //                       Image.asset(
// //                         'assets/bottle.png',
// //                         width: 20,
// //                         height: 20,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(width: 10),
// //                 Icon(
// //                   CupertinoIcons.stopwatch,
// //                   size: 18,
// //                   color: Color(0xFFA1A1A1),
// //                 ),
// //                 SizedBox(width: 5),
// //                 Text(
// //                   duration,
// //                   style: TextStyle(
// //                     fontFamily: 'Lato',
// //                     fontSize: 15,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFFA1A1A1),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Positioned(
// //           //   top: 35,
// //           //   right: 15,
// //           //   child: Container(
// //           //     width: 20,
// //           //     height: 20,
// //           //     decoration: BoxDecoration(
// //           //       color: isSelected ? Colors.transparent : Colors.grey[300],
// //           //       borderRadius: BorderRadius.circular(10),
// //           //     ),
// //           //     child: isSelected
// //           //         ? Icon(
// //           //             CupertinoIcons.checkmark_alt_circle_fill,
// //           //             color: Color.fromARGB(255, 28, 73, 221),
// //           //           )
// //           //         : Container(),
// //           //   ),
// //           // ),
// //           SizedBox(height: 10),
// //           Positioned(
// //             top: 88, // Adjusted top position to bring the button higher
// //             left: 0,
// //             child: Container(
// //               width: 75,
// //               height: 35, // Increased height for better touch area
// //               decoration: BoxDecoration(
// //                 color: CustomColors.backgroundtext,
// //                 borderRadius: BorderRadius.circular(8.0),
// //               ),
// //               child: TextButton(
// //                 onPressed: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (context) => SelectPackageDetailsPage(),
// //                     ),
// //                   );
// //                 },
// //                 child: Column(
// //                   // Using a Column to position text higher inside the button
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Text(
// //                       'Book Now',
// //                       style: TextStyle(
// //                         fontFamily: 'Lato',
// //                         fontSize: 12, // Adjusted font size
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
// import 'package:ms_salon_task/Book_appointment/packages_api_controller.dart';
// import 'package:ms_salon_task/services/special_services.dart';
// // Update with the actual path
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// class SelectPackagePage extends StatefulWidget {
//   @override
//   _SelectPackagePageState createState() => _SelectPackagePageState();
// }

// class _SelectPackagePageState extends State<SelectPackagePage> {
//   bool _isLoading = true;
//   String _errorMessage = '';
//   List<Package> _packages = [];
//   List<Package> _filteredPackages = [];
//   String _customerID = '';
//   String _branchID = '';
//   String _salonID = '';
//   String _searchQuery = ''; // Search query state

//   // Map to keep track of selected services
//   Map<String, bool> _selectedServices = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _customerID = prefs.getString('customer_id') ?? '';
//       _branchID = prefs.getString('branch_id') ?? '';
//       _salonID = prefs.getString('salon_id') ?? '';
//     });

//     try {
//       final apiController = PackageApiController();
//       List<Package> packages =
//           await apiController.fetchPackages(_salonID, _branchID, _customerID);
//       setState(() {
//         _packages = packages;
//         _filteredPackages =
//             List.from(_packages); // Initialize filtered packages
//         _isLoading = false;

//         // Initialize the _selectedServices map with default values
//         _selectedServices = {
//           for (var package in _packages)
//             for (var service in package.services) service.serviceId: false,
//         };
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     await _initializeData();
//   }

//   void _toggleServiceSelection(String serviceId) {
//     setState(() {
//       _selectedServices[serviceId] = !_selectedServices[serviceId]!;
//     });

//     // Print all selected service IDs
//     List<String> selectedServiceIds = _selectedServices.entries
//         .where((entry) => entry.value)
//         .map((entry) => entry.key)
//         .toList();

//     print('Selected Service IDs: $selectedServiceIds');
//   }

//   Future<void> _storeSelectedServices() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> selectedServiceIds = _selectedServices.entries
//         .where((entry) => entry.value)
//         .map((entry) => entry.key)
//         .toList();
//     await prefs.setStringList('selected_service_ids', selectedServiceIds);
//   }

//   void _filterPackages(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredPackages = _packages.where((package) {
//         return package.packageName
//                 .toLowerCase()
//                 .contains(query.toLowerCase()) ||
//             package.services.any((service) => service.serviceName
//                 .toLowerCase()
//                 .contains(query.toLowerCase()));
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final containerHeight = screenHeight * 0.1;

//     Widget _buildSkeletonLoader() {
//       return ListView.separated(
//         separatorBuilder: (context, index) => SizedBox(height: 20),
//         itemCount: 5, // Number of skeleton items
//         itemBuilder: (context, index) {
//           return Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0x00000008),
//                     offset: Offset(0, 5),
//                     blurRadius: 10,
//                     spreadRadius: 1,
//                   ),
//                 ],
//               ),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.grey,
//                 ),
//                 title: Container(
//                   color: Colors.grey,
//                   height: 20,
//                   width: double.infinity,
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       color: Colors.grey,
//                       height: 15,
//                       width: 100,
//                     ),
//                     SizedBox(height: 4),
//                     Container(
//                       color: Colors.grey,
//                       height: 15,
//                       width: 150,
//                     ),
//                   ],
//                 ),
//                 trailing: Container(
//                   color: Colors.grey,
//                   width: 30,
//                   height: 30,
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     return Scaffold(
//       backgroundColor: Color(0xFFFAFAFA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFFFFFFFF),
//         elevation: 0,
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             Text(
//               'Select Package',
//               style: TextStyle(
//                 fontFamily: 'Lato',
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: Column(
//           children: [
//             SizedBox(height: 10),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               height: 40,
//               width: screenWidth - 24,
//               decoration: BoxDecoration(
//                 color: Color(0xFFF2F2F2),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: TextField(
//                 onChanged: (query) => _filterPackages(query),
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.zero,
//                   hintText: 'Search...',
//                   hintStyle: TextStyle(
//                     fontFamily: 'Lato',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     height: 14.4 / 5,
//                     color: Color(0xFFC4C4C4),
//                   ),
//                   border: InputBorder.none,
//                   prefixIcon: Padding(
//                     padding:
//                         const EdgeInsets.only(left: 8.0, top: 2.0, right: 8.0),
//                     child: Icon(
//                       CupertinoIcons.search,
//                       size: 25,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: CustomColors.backgroundtext, width: 0.5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0x00000008),
//                     offset: Offset(15, 15),
//                     blurRadius: 90,
//                     spreadRadius: 4,
//                   ),
//                 ],
//               ),
//               height: containerHeight * 0.5,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 BookAppointmentPage(), // Replace with your actual page
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             bottomLeft: Radius.circular(10),
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Services',
//                             style: TextStyle(
//                               fontFamily: 'Lato',
//                               color: CustomColors.backgroundtext,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 SelectPackagePage(), // Replace with your actual page
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(10),
//                             bottomRight: Radius.circular(10),
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Packages',
//                             style: TextStyle(
//                               fontFamily: 'Lato',
//                               color: CustomColors.backgroundtext,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: _isLoading
//                   ? _buildSkeletonLoader()
//                   : _errorMessage.isNotEmpty
//                       ? Center(
//                           child: Text(_errorMessage),
//                         )
//                       : ListView.separated(
//                           separatorBuilder: (context, index) =>
//                               SizedBox(height: 20),
//                           itemCount: _filteredPackages.length,
//                           itemBuilder: (context, index) {
//                             final package = _filteredPackages[index];
//                             return Container(
//                               margin: EdgeInsets.symmetric(horizontal: 15),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(15),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Color(0x00000008),
//                                     offset: Offset(0, 5),
//                                     blurRadius: 10,
//                                     spreadRadius: 1,
//                                   ),
//                                 ],
//                               ),
//                               child: ExpansionTile(
//                                 leading: CircleAvatar(
//                                   backgroundImage: NetworkImage(package.image),
//                                 ),
//                                 title: Text(
//                                   package.packageName,
//                                   style: TextStyle(
//                                     fontFamily: 'Lato',
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   package.description,
//                                   style: TextStyle(
//                                     fontFamily: 'Lato',
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                                 children: package.services.map((service) {
//                                   return ListTile(
//                                     leading: CircleAvatar(
//                                       backgroundImage:
//                                           NetworkImage(service.image),
//                                     ),
//                                     title: Text(
//                                       service.serviceName,
//                                       style: TextStyle(
//                                         fontFamily: 'Lato',
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       service.duration,
//                                       style: TextStyle(
//                                         fontFamily: 'Lato',
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     trailing: Checkbox(
//                                       value:
//                                           _selectedServices[service.serviceId],
//                                       onChanged: (value) {
//                                         _toggleServiceSelection(
//                                             service.serviceId);
//                                       },
//                                     ),
//                                     onTap: () {
//                                       _showOfferedProductsDialog(service);
//                                     },
//                                   );
//                                 }).toList(),
//                               ),
//                             );
//                           },
//                         ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         height: 50,
//         child: ElevatedButton(
//           onPressed: () async {
//             await _storeSelectedServices();
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     SpecialServicesPage(), // Replace with your actual page
//               ),
//             );
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: CustomColors.backgroundtext,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: Text(
//             'Next Step',
//             style: TextStyle(
//               fontFamily: 'Lato',
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _showOfferedProductsDialog(ServiceInPackage service) async {
//     Set<String> checkedProductIds = {};

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Offered Products'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: service.products.map((product) {
//               return CheckboxListTile(
//                 title: Text(product.productName),
//                 subtitle: Text('Price: ${product.price}'),
//                 value: checkedProductIds.contains(product.productId),
//                 onChanged: (bool? value) {
//                   setState(() {
//                     if (value == true) {
//                       checkedProductIds.add(product.productId);
//                     } else {
//                       checkedProductIds.remove(product.productId);
//                     }
//                   });
//                 },
//               );
//             }).toList(),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ms_salon_task/My_Bookings/my_bookings.dart';
// import 'package:ms_salon_task/Payment/review_summary.dart';

// class SDateTime extends StatefulWidget {
//   @override
//   _SelectDateTimeState createState() => _SelectDateTimeState();
// }

// class _SelectDateTimeState extends State<SDateTime> {
//   TextEditingController _dateController = TextEditingController();
//   String _selectedTimeSlot = '';
//   String _selectedTime = '';

//   List<String> specialists = [
//     'assets/model.png',
//     'assets/model.png',
//     'assets/model.png',
//     'assets/model.png',
//     'assets/model.png',
//     'assets/model.png',
//   ];

//   List<String> specialistNames = [
//     'Dr. Smith',
//     'Dr. Johnson',
//     'Dr. Williams',
//     'Dr. Brown',
//     'Dr. Jones',
//     'Dr. Garcia',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _dateController = TextEditingController(); // Initialize the controller
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFAFAFA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             Text(
//               'Select Date and Time',
//               style: TextStyle(
//                 fontFamily: 'Lato',
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onTap: () async {
//                     final DateTime? picked = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime(DateTime.now().year + 1),
//                     );
//                     if (picked != null) {
//                       setState(() {
//                         _dateController.text =
//                             DateFormat('yyyy-MM-dd').format(picked);
//                       });
//                     }
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: Colors.grey[300]!, // Grey line color
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           _dateController.text.isEmpty
//                               ? 'Booking Date'
//                               : _dateController.text,
//                           style: TextStyle(
//                             fontFamily: 'Lato',
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Icon(Icons.calendar_today_outlined,
//                             color: Colors.black),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20), // Grey line height adjustment
//                 Container(
//                   height: 1,
//                   color: Colors.grey[300], // Grey line color
//                 ),
//                 SizedBox(height: 20), // Spacing adjustment after the grey line
//                 Text(
//                   'Select Specialist',
//                   style: TextStyle(
//                     fontFamily: 'Lato',
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 25),
//                 SizedBox(
//                   height: 120,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: specialists.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         width: 100,
//                         margin: EdgeInsets.symmetric(horizontal: 8),
//                         child: Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 40,
//                               backgroundImage: AssetImage(specialists[index]),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               specialistNames[index],
//                               style: TextStyle(
//                                 fontFamily: 'Lato',
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10), // Grey line height adjustment
//                 Container(
//                   height: 1,
//                   color: Colors.grey[300], // Grey line color
//                 ),
//                 SizedBox(height: 10),
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 15),
//                       Text(
//                         'Available Time Slot',
//                         style: TextStyle(
//                           fontFamily: 'Lato',
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border:
//                               Border.all(color: CustomColors.backgroundtext, width: 1),
//                         ),
//                         child: Text(
//                           'Selected Time $_selectedTime',
//                           style: TextStyle(
//                             fontFamily: 'Lato',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: CustomColors.backgroundtext,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Column(
//                             children: [
//                               _buildTimeSlot('08:00 AM'),
//                               SizedBox(height: 8),
//                               _buildTimeSlot('09:00 AM'),
//                               SizedBox(height: 8),
//                               _buildTimeSlot('10:00 AM'),
//                             ],
//                           ),
//                           Column(
//                             children: [
//                               _buildTimeSlot('12:00 PM'),
//                               SizedBox(height: 8),
//                               _buildTimeSlot('01:00 PM'),
//                               SizedBox(height: 8),
//                               _buildTimeSlot('02:00 PM'),
//                             ],
//                           ),
//                           Column(
//                             children: [
//                               _buildTimeSlot('05:00 PM'),
//                               SizedBox(height: 8),
//                               _buildTimeSlot('06:00 PM'),
//                               SizedBox(height: 8),
//                               _buildTimeSlot('07:00 PM'),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Spacer(),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: CustomColors.backgroundtext),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text(
//                     'Back',
//                     style: TextStyle(
//                       fontFamily: 'Lato',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: CustomColors.backgroundtext,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ReviewSummary(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: CustomColors.backgroundtext,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text(
//                     'Next Step',
//                     style: TextStyle(
//                       fontFamily: 'Lato',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeSlot(String time) {
//     bool isSelected = time == _selectedTimeSlot;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedTimeSlot = time;
//           _selectedTime = time; // Update selected time when tapped
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: CustomColors.backgroundtext, // Always blue border color
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(5),
//           color: isSelected ? CustomColors.backgroundtext : Colors.white,
//         ),
//         child: Text(
//           time,
//           style: TextStyle(
//             fontFamily: 'Lato',
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: isSelected ? Colors.white : CustomColors.backgroundtext,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
// import 'package:ms_salon_task/Colors/custom_colors.dart';
// import 'dart:convert';
// import 'package:ms_salon_task/My_Bookings/datetime.dart';
// import 'package:ms_salon_task/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SpecialServices extends StatefulWidget {
//   @override
//   _SpecialServicesState createState() => _SpecialServicesState();
// }

// class _SpecialServicesState extends State<SpecialServices> {
//   List<dynamic> services = []; // Fetched special services
//   Map<String, dynamic> storedServices = {}; // Retrieved stored services
//   bool isLoading = true; // To track loading state
//   Set<String> selectedServices = Set<String>(); // Track selected services

//   @override
//   void initState() {
//     super.initState();
//     fetchSpecialServices();
//   }

//   Future<void> fetchSpecialServices() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? customerId1 = prefs.getString('customer_id');
//     final String? customerId2 = prefs.getString('customer_id2');
//     final String branchID = prefs.getString('branch_id') ?? '';
//     final String salonID = prefs.getString('salon_id') ?? '';

//     // Retrieve and print the stored service data
//     final String? storedData = prefs.getString('selected_service_data1');
//     print('Stored Data: $storedData');

//     List<String> ignoreServices = [];

//     if (storedData != null) {
//       final Map<String, dynamic> decodedData = jsonDecode(storedData);

//       setState(() {
//         storedServices = decodedData;
//       });

//       decodedData.forEach((key, service) {
//         if (service['isSpecial'] == "1") {
//           ignoreServices.add(service['serviceId'].toString());
//         }
//       });
//     }

//     final String customerId = customerId1?.isNotEmpty == true
//         ? customerId1!
//         : customerId2?.isNotEmpty == true
//             ? customerId2!
//             : '';

//     if (customerId.isEmpty) {
//       throw Exception('No valid customer ID found');
//     }

//     final String url = '${Config.apiUrl}customer/store-special-services/';

//     final Map<String, dynamic> body = {
//       "salon_id": salonID,
//       "branch_id": branchID,
//       "customer_id": customerId,
//       "ignore_services": ignoreServices
//     };

//     print('Request URL: $url');
//     print('Request Body: ${jsonEncode(body)}');

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body)['data'];
//         setState(() {
//           services = data;
//           isLoading = false;
//         });
//       } else {
//         print('Failed to load special services: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   // Helper function to style text with Lato font
//   TextStyle latoStyle(double fontSize, FontWeight fontWeight,
//       {FontStyle fontStyle = FontStyle.normal}) {
//     return GoogleFonts.lato(
//       fontSize: fontSize,
//       fontWeight: fontWeight,
//       fontStyle: fontStyle,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Navigate to SDateTime when back button is pressed
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => BookAppointmentPage(),
//           ),
//         );
//         return false; // Prevent default back navigation
//       },
//       child: Scaffold(
//         backgroundColor: CustomColors.backgroundPrimary,
//         appBar: AppBar(
//           title: Text(
//             'Special Services',
//             style: GoogleFonts.lato(),
//           ),
//           backgroundColor: CustomColors.backgroundLight,
//         ),
//         bottomNavigationBar: BottomAppBar(
//           color: CustomColors.backgroundLight,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton(
//                 onPressed: () {
//                   // Navigator.pop(context);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BookAppointmentPage(),
//                     ),
//                   );
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: CustomColors.backgroundtext,
//                   backgroundColor: CustomColors.backgroundLight,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     side: BorderSide(
//                       color: CustomColors.backgroundtext,
//                       width: 1,
//                     ),
//                   ),
//                   padding: EdgeInsets.zero,
//                   minimumSize: Size(135, 40),
//                 ),
//                 child: Text(
//                   'Back',
//                   style: latoStyle(15, FontWeight.w600),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   // Create a map to hold the combined services
//                   Map<String, dynamic> combinedServices =
//                       Map.from(storedServices);

//                   // Iterate through the selected services and format them for storage
//                   for (var service in services) {
//                     if (selectedServices.contains(service['service_id'])) {
//                       combinedServices[service['service_id']] = {
//                         'isSpecial': "1",
//                         'serviceId': service['service_id'],
//                         'categoryId': service[
//                             'categoryId'], // Ensure this field is available
//                         'serviceName':
//                             service['service_name'], // Use the appropriate keys
//                         'price': service['price'],
//                         'serviceMarathiName': service['service_marathi_name'],
//                         'isOfferApplied': "0", // Adjust as necessary
//                         'appliedOfferId': "", // Adjust as necessary
//                         'image': service['image'],
//                         'duration':
//                             service['service_duration'], // Adjust as necessary
//                         'products':
//                             [], // Add any other relevant fields as necessary
//                       };
//                     }
//                   }

//                   // Save the combined services to SharedPreferences
//                   final prefs = await SharedPreferences.getInstance();
//                   String jsonData = jsonEncode(combinedServices);
//                   await prefs.setString('selected_service_data1', jsonData);

//                   // Print the updated stored data
//                   print('Updated Selected Service Data JSON: $jsonData');

//                   // Navigate to the next screen
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SDateTime(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: CustomColors.backgroundtext,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   padding: EdgeInsets.zero,
//                   minimumSize: Size(135, 40),
//                 ),
//                 child: Text(
//                   'Next Step',
//                   style: latoStyle(15, FontWeight.w600,
//                       fontStyle: FontStyle.normal),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: isLoading
//             ? Center(child: CircularProgressIndicator())
//             : ListView(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 children: [
//                   // Header for Selected Services
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: Text(
//                       'Selected Services',
//                       style: latoStyle(20, FontWeight.bold),
//                     ),
//                   ),
//                   // Display stored services without checkboxes
//                   ...storedServices.entries.map((entry) {
//                     final service = entry.value;
//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.network(
//                                   service['image'],
//                                   height: 80,
//                                   width: 80,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${service['serviceName']} || ${service['serviceMarathiName']}',
//                                       style: latoStyle(18, FontWeight.bold),
//                                     ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       'Duration: ${service['duration']} mins',
//                                       style: latoStyle(14, FontWeight.normal,
//                                           fontStyle: FontStyle.italic),
//                                     ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       '\₹${service['price']}',
//                                       style: latoStyle(16, FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   // Header for Special Services
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: Text(
//                       'Special Services',
//                       style: latoStyle(20, FontWeight.bold),
//                     ),
//                   ),
//                   // Display fetched services with round checkbox
//                   // Inside the ListView where you display the special services
//                   ...services.map((service) {
//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             // Toggle the selection when the card is tapped
//                             if (selectedServices
//                                 .contains(service['service_id'])) {
//                               selectedServices.remove(service['service_id']);
//                             } else {
//                               selectedServices.add(service['service_id']);
//                             }
//                             // Print selected services as JSON
//                             printSelectedServices();
//                           });
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(10),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.network(
//                                     service['image'],
//                                     height: 80,
//                                     width: 80,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${service['service_name']} || ${service['service_marathi_name']}',
//                                         style: latoStyle(18, FontWeight.bold),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         'Duration: ${service['service_duration']} mins',
//                                         style: latoStyle(14, FontWeight.normal,
//                                             fontStyle: FontStyle.italic),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         '\₹${service['price']}',
//                                         style: latoStyle(16, FontWeight.bold),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // Round Checkbox for special services selection
//                                 Checkbox(
//                                   value: selectedServices
//                                       .contains(service['service_id']),
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       if (value == true) {
//                                         selectedServices
//                                             .add(service['service_id']);
//                                       } else {
//                                         selectedServices
//                                             .remove(service['service_id']);
//                                       }
//                                       // Print selected services as JSON
//                                       printSelectedServices();
//                                     });
//                                   },
//                                   shape: CircleBorder(),
//                                   activeColor: CustomColors.backgroundtext,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//       ),
//     );
//   }

//   void printSelectedServices() {
//     // Create a list of selected services data
//     List<Map<String, dynamic>> selectedServicesData = services
//         .where((service) => selectedServices.contains(service['service_id']))
//         .map((service) => {
//               'service_id': service['service_id'],
//               'service_name': service['service_name'],
//               'service_marathi_name': service['service_marathi_name'],
//               'duration': service['service_duration'],
//               'price': service['price'],
//               'image': service['image'],
//             })
//         .toList();

//     // Convert the list to JSON
//     String jsonData = jsonEncode(selectedServicesData);
//     print('Selected Services JSON: $jsonData');
//   }
// }
