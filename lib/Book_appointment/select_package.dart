import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Book_appointment/add_package_dialog.dart';
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Book_appointment/packages_api_controller.dart';
import 'package:ms_salon_task/Book_appointment/special_services.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/offers%20and%20membership/store_packages.dart';
import 'package:ms_salon_task/services/special_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SelectPackagePage extends StatefulWidget {
  @override
  _SelectPackagePageState createState() => _SelectPackagePageState();
}

class _SelectPackagePageState extends State<SelectPackagePage> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, bool> _selectedPackages = {};
  List<Package> _packages = [];
  List<Package> _filteredPackages = [];
  String _customerID = '';
  String _branchID = '';
  String _salonID = '';
  String _searchQuery = '';
  Map<String, bool> _expandedPackages = {};
  ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Map to keep track of selected services
  Map<String, bool> _selectedServices = {};
  bool _hasMore = true;
  // Set to keep track of checked products in the dialog
  Set<String> _checkedProductIds = {};
  bool isSelected = false;
  Map<int, dynamic> servicesData = {};
  Map<int, dynamic> servicesData2 = {}; // Stores services data
  bool isLoading = true; // To track loading state
  String? _selectedPackageId; // Define this here
  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve and determine the customer ID
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String customerID = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid customer ID found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _customerID = customerID;
      _branchID = branchID;
      _salonID = salonID;
      _isLoading = true; // Indicate loading state
    });

    try {
      final apiController = PackageApiController();
      List<Package> packages =
          await apiController.fetchPackages(_salonID, _branchID, _customerID);

      setState(() {
        _packages = packages;
        _filteredPackages =
            List.from(_packages); // Initialize filtered packages
        _isLoading = false;

        // Initialize _selectedServices map with default values
        _selectedServices = {
          for (var package in _packages)
            for (var service in package.services)
              service.serviceId: false, // Default value for each service
        };
      });

      // Retrieve and print the selected_package_id
      final String? selectedPackageId = prefs.getString('selected_package_id');
      print('Selected Package ID from prefs: $selectedPackageId');

      // Retrieve and print the selected_service_data string
      final String? selectedServiceDataJson =
          prefs.getString('selected_service_data');
      print('Selected Service Data in packages: $selectedServiceDataJson');

      if (selectedServiceDataJson != null &&
          selectedServiceDataJson.isNotEmpty) {
        final Map<String, dynamic> selectedServiceData =
            jsonDecode(selectedServiceDataJson);

        setState(() {
          _selectedPackages = {};
          _selectedServices = {};

          for (var package in _packages) {
            // Check if any service in this package is in the selected service data
            bool isPackageSelected = package.services.any((service) {
              return selectedServiceData.containsKey(service.serviceId);
            });

            if (isPackageSelected) {
              _selectedPackages[package.packageId] = true;

              // Mark all services in the selected package as selected
              for (var service in package.services) {
                if (selectedServiceData.containsKey(service.serviceId)) {
                  _selectedServices[service.serviceId] = true;
                }
              }

              // Print package ID for debugging
              print('Package selected: ${package.packageId}');
            }
          }

          // Update selected package ID if there are packages with selected services
          _selectedPackageId = selectedPackageId;

          // Print the currently selected package ID for debugging
          print('Selected Package ID: $_selectedPackageId');
        });

        // Store selected services
        await _storeSelectedServices();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error loading data: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _initializeData();
  }

  Future<void> _toggleServiceSelection(
      String serviceId, String packageId) async {
    String uniqueServiceId = '$packageId:$serviceId';

    print('Toggling selection for: $uniqueServiceId');

    // Check if there are any selected services from different packages
    bool hasSelectedServicesInOtherPackages = _selectedServices.keys
        .where((key) => _selectedServices[key] == true)
        .any((key) => key.split(':')[0] != packageId);

    if (hasSelectedServicesInOtherPackages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please deselect services from the current package before selecting from another package.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedServices.containsKey(uniqueServiceId)) {
        _selectedServices[uniqueServiceId] =
            !_selectedServices[uniqueServiceId]!;
        print(
            'Service selection toggled: ${_selectedServices[uniqueServiceId]}');
      } else {
        _selectedServices[uniqueServiceId] = true;
        print('Service selected: $uniqueServiceId');
      }
    });

    // Collect selected service data
    Map<String, Map<String, dynamic>> selectedServiceData = {};

    for (var package in _packages) {
      for (var service in package.services) {
        String key = '${package.packageId}:${service.serviceId}';
        if (_selectedServices.containsKey(key) &&
            _selectedServices[key] == true) {
          selectedServiceData[key] = {
            'serviceId': service.serviceId,
            'serviceName': service.serviceName,
            'serviceMarathiName': service.serviceMarathiName,
            'packageName': package.packageName,
            'package_id': service.packageId,
            'price': service.price,
            'is_old_package': service.isOldPackage,
            'package_allocation_id': service.packageAllocationId,
            'is_offer_applied': '',
            'applied_offer_id': '',
            'image': service.image,
            'duration': service.duration,
            'is_service_available': service.isServiceAvailable,
            'products': service.products.map((product) {
              return {
                'productId': product.productId,
                'productName': product.productName,
                'productPrice': product.price,
              };
            }).toList(),
          };
        }
      }
    }

    // Remove unique service IDs and encode to JSON
    Map<String, dynamic> dataWithoutKeys =
        selectedServiceData.map((key, value) => MapEntry(
            value['serviceId'], // Use serviceId as the key
            value));
    String selectedServiceDataJson = jsonEncode(dataWithoutKeys);

    // Print the updated JSON and selected service IDs
    List<String> selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print('Selected Service IDs in package: $selectedServiceIds');
    print('Selected Service Data JSON: $selectedServiceDataJson');

    // Save to shared preferences
    await _saveSelectedServicesToPreferences(selectedServiceDataJson);
  }

  Future<void> _saveSelectedServicesToPreferences(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_service_data', jsonString);
  }

  void _onPackageSelected(String packageId) {
    setState(() {
      // Deselect all packages
      _selectedPackages.forEach((key, value) {
        _selectedPackages[key] = false;
      });
      // Select the current package
      _selectedPackages[packageId] = true;
      // Store selected services based on the newly selected package
      _storeSelectedServices();
    });
  }

  Future<void> _storeSelectedServices() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedPackageId == null) return;

    final selectedPackage =
        _packages.firstWhere((pkg) => pkg.packageId == _selectedPackageId);
    final selectedServiceData = {
      for (var service in selectedPackage.services)
        service.serviceId: {
          // 'isSpecial': service.isSpecial,
          'isSpecial': service.isSpecial,
          'serviceId': service.serviceId,
          'serviceName': service.serviceName,
          'serviceMarathiName': service.serviceMarathiName,
          'duration': service.duration,
          'image': service.image,
          'isServiceAvailable': service.isServiceAvailable,
          'products': service.products.map((product) {
            return {
              'productId': product.productId,
              'productName': product.productName,
              'productPrice': product.price,
            };
          }).toList(),
        },
    };

    // Convert to JSON
    String selectedServiceDataJson = jsonEncode(selectedServiceData);

    // Save to SharedPreferences
    await prefs.setString('selected_service_data', selectedServiceDataJson);

    // Print the saved JSON to confirm
    print('Stored Selected Service Data JSON: $selectedServiceDataJson');
  }

  Future<void> _storeSelectedPackages() async {
    final prefs = await SharedPreferences.getInstance();

    // Collect selected package data
    Map<String, Map<String, dynamic>> selectedPackageData = {};

    for (var package in _filteredPackages) {
      if (_selectedPackages[package.packageId] == true) {
        selectedPackageData[package.packageId] = {
          'packageId': package.packageId,
          'packageName': package.packageName,
          'services': package.services.map((service) {
            return {
              'serviceId': service.serviceId,
              'serviceName': service.serviceName,
              'serviceMarathiName': service.serviceMarathiName,
              'duration': service.duration,
              'image': service.image,
              'isServiceAvailable': service.isServiceAvailable,
              'products': service.products.map((product) {
                return {
                  'productId': product.productId,
                  'productName': product.productName,
                  'productPrice': product.price,
                };
              }).toList(),
            };
          }).toList(),
        };
      }
    }

    // Convert the map to JSON
    String selectedPackageDataJson = jsonEncode(selectedPackageData);

    // Save the JSON to SharedPreferences
    await prefs.setString('selected_package_data', selectedPackageDataJson);

    // Print the saved JSON to confirm
    print('Stored Selected Package Data JSON: $selectedPackageDataJson');
  }

  void _showOfferedProductsDialog(List<ProductInPackage> products) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFFAFAFA),
              title: Text('Offered Products'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: products.map((product) {
                    return CheckboxListTile(
                      value: _checkedProductIds.contains(product.productId),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _checkedProductIds.add(product.productId);
                          } else {
                            _checkedProductIds.remove(product.productId);
                          }
                        });
                      },
                      title: Text(
                        '${product.productName}  ₹ ${product.price ?? ''}',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList(
                        'selected_product_ids', _checkedProductIds.toList());
                    await _storeSelectedServices();
                    Navigator.of(context).pop();
                    print(
                        'Confirmed products in package: ${_checkedProductIds.toList()}');
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterPackages(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPackages = _packages.where((package) {
        String normalizedQuery = query.toLowerCase().trim();
        return package.packageName.toLowerCase().contains(normalizedQuery) ||
            package.services.any((service) =>
                service.serviceName.toLowerCase().contains(normalizedQuery) ||
                service.serviceMarathiName
                    .toLowerCase()
                    .contains(normalizedQuery));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.1;

    Widget _buildSkeletonLoader() {
      return ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => SizedBox(height: 20),
        itemCount: _filteredPackages.length, // Number of skeleton items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x00000008),
                    offset: Offset(0, 5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                ),
                title: Container(
                  color: Colors.grey,
                  height: 20,
                  width: double.infinity,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.grey,
                      height: 15,
                      width: 100,
                    ),
                    SizedBox(height: 4),
                    Container(
                      color: Colors.grey,
                      height: 15,
                      width: 150,
                    ),
                  ],
                ),
                trailing: Container(
                  color: Colors.grey,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          );
        },
      );
    }

    // ignore: deprecated_member_use
    return WillPopScope(
      // onWillPop: () async {
      //   Navigator.pushNamed(
      //     context,
      //     '/book_appointment', // Replace with your desired route name
      //   );
      //   return false; // Prevent the default back navigation
      // },
      onWillPop: () async {
        // This will navigate back to BookAppointmentPage and clear the navigation stack
        Navigator.pop(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => BookAppointmentPage()),
        // );
        return Future.value(false); // Prevent the default back action
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => BookAppointmentPage()),
                  // );
                  // Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              Text(
                'Select Package',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.all(12), // Adjust padding as needed
              //   decoration: BoxDecoration(
              //     color: CustomColors.backgroundLight,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(
              //             0.2), // Optional shadow for the outer container
              //         // spreadRadius: 2,
              //         // blurRadius: 5,
              //         // offset: Offset(0, 3), // Changes the position of the shadow
              //       ),
              //     ],
              //   ),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 12),
              //     height: 40,
              //     width: screenWidth - 24,
              //     decoration: BoxDecoration(
              //       color: Color(0xFFF2F2F2),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: TextField(
              //       controller:
              //           _searchController, // Add a TextEditingController
              //       onChanged: (query) => _filterPackages(query),
              //       decoration: InputDecoration(
              //         contentPadding:
              //             EdgeInsets.symmetric(vertical: 1, horizontal: 12),
              //         hintText: 'Search...',
              //         hintStyle: TextStyle(
              //           fontFamily: 'Lato',
              //           fontSize: 14,
              //           fontWeight: FontWeight.w400,
              //           height: 14.4 / 5,
              //           color: Color(0xFFC4C4C4),
              //         ),
              //         border: InputBorder.none,
              //         prefixIcon: Padding(
              //           padding:
              //               EdgeInsets.only(left: 8.0, top: 2.0, right: 8.0),
              //           child: Icon(
              //             CupertinoIcons.search,
              //             size: 25,
              //             color: Colors.blue,
              //           ),
              //         ),
              //         suffixIcon: _searchController.text.isNotEmpty
              //             ? GestureDetector(
              //                 onTap: () {
              //                   _searchController.clear(); // Clear the text
              //                   _filterPackages(''); // Reset the filter
              //                 },
              //                 child: Icon(
              //                   CupertinoIcons.clear_circled,
              //                   color: Colors.grey,
              //                   size: 22,
              //                 ),
              //               )
              //             : null,
              //       ),
              //     ),
              //   ),
              // ),

              SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: CustomColors.backgroundtext, width: 0.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x00000008),
                      offset: Offset(15, 15),
                      blurRadius: 90,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                height: containerHeight * 0.5,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookAppointmentPage(), // Replace with your actual page
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Services',
                              style: GoogleFonts.lato(
                                color: CustomColors.backgroundtext,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         SelectPackagePage(), // Replace with your actual page
                          //   ),
                          // );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: CustomColors.backgroundtext,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Package',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Expanded(
              //   child: _isLoading
              //       ? _buildSkeletonLoader()
              //       : _errorMessage.isNotEmpty
              //           ? Center(
              //               child: Container(
              //                 alignment: Alignment.center,
              //                 padding: EdgeInsets.only(
              //                   right: MediaQuery.of(context).size.width * 0.0,
              //                   left: MediaQuery.of(context).size.width * 0.02,
              //                 ),
              //                 child: Image.asset(
              //                   'assets/nodata2.png', // Replace with your image path
              //                   height: MediaQuery.of(context).size.height *
              //                       0.7, // 70% of screen height
              //                   width: MediaQuery.of(context).size.width *
              //                       0.7, // 70% of screen width
              //                 ),
              //               ),
              //             )
              //           : _filteredPackages
              //                   .isEmpty // Check here for filtered packages
              //               ? Center(
              //                   child: SingleChildScrollView(
              //                     child: Column(
              //                       mainAxisAlignment: MainAxisAlignment.center,
              //                       children: [
              //                         Image.asset(
              //                           'assets/nodata2.png', // Replace with your image path
              //                           height:
              //                               MediaQuery.of(context).size.height *
              //                                   0.4, // 40% of screen height
              //                           width:
              //                               MediaQuery.of(context).size.width *
              //                                   0.7, // 70% of screen width
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 )
              //               : LayoutBuilder(
              //                   builder: (context, constraints) {
              //                     double horizontalMargin =
              //                         constraints.maxWidth * 0.05;
              //                     return ListView.separated(
              //                       controller: _scrollController,
              //                       separatorBuilder: (context, index) =>
              //                           SizedBox(height: 20),
              //                       itemCount: _filteredPackages.length,
              //                       itemBuilder: (context, index) {
              //                         final package = _filteredPackages[index];
              //                         bool isExpanded = _expandedPackages[
              //                                 package.packageId] ??
              //                             false;
              //                         bool isSelected = _selectedPackageId ==
              //                             package.packageId;

              //                         return GestureDetector(
              //                           onTap: () async {
              //                             SharedPreferences prefs =
              //                                 await SharedPreferences
              //                                     .getInstance();

              //                             setState(() {
              //                               // Toggle expanded state
              //                               _expandedPackages[package
              //                                   .packageId] = !isExpanded;

              //                               if (_selectedPackageId !=
              //                                   package.packageId) {
              //                                 // New package selected
              //                                 _selectedPackageId =
              //                                     package.packageId;
              //                                 // Save the selected package ID to SharedPreferences
              //                                 prefs.setString(
              //                                     'selected_package_id',
              //                                     package.packageId);
              //                                 _storeSelectedServices(); // Store services for the selected package
              //                                 print(
              //                                     'Package selected: ${package.packageName}');
              //                               } else {
              //                                 // Package deselected
              //                                 _selectedPackageId = null;
              //                                 prefs.remove(
              //                                     'selected_service_data'); // Clear the stored data
              //                                 print(
              //                                     'Package deselected: ${package.packageName}');
              //                               }
              //                             });
              //                           },
              //                           child: Container(
              //                             margin: EdgeInsets.symmetric(
              //                                 horizontal: horizontalMargin),
              //                             padding: EdgeInsets.all(10),
              //                             decoration: BoxDecoration(
              //                               color: Colors.white,
              //                               borderRadius:
              //                                   BorderRadius.circular(15),
              //                               boxShadow: const [
              //                                 BoxShadow(
              //                                   color: Color(0x00000008),
              //                                   offset: Offset(0, 5),
              //                                   blurRadius: 10,
              //                                   spreadRadius: 1,
              //                                 ),
              //                               ],
              //                             ),
              //                             child: Column(
              //                               crossAxisAlignment:
              //                                   CrossAxisAlignment.start,
              //                               children: [
              //                                 Row(
              //                                   children: [
              //                                     Container(
              //                                       width: 24,
              //                                       height: 24,
              //                                       decoration: BoxDecoration(
              //                                         shape: BoxShape.circle,
              //                                         color: isSelected
              //                                             ? CustomColors
              //                                                 .backgroundtext
              //                                             : Colors.transparent,
              //                                         border: Border.all(
              //                                           color: CustomColors
              //                                               .backgroundtext,
              //                                           width: 2,
              //                                         ),
              //                                       ),
              //                                       child: isSelected
              //                                           ? const Center(
              //                                               child: Icon(
              //                                                 Icons.check,
              //                                                 color:
              //                                                     Colors.white,
              //                                                 size: 18,
              //                                               ),
              //                                             )
              //                                           : null,
              //                                     ),
              //                                     SizedBox(width: 10),
              //                                     Container(
              //                                       width: 60,
              //                                       height: 60,
              //                                       decoration: BoxDecoration(
              //                                         shape: BoxShape.circle,
              //                                         color: Colors.grey[200],
              //                                       ),
              //                                       child: ClipOval(
              //                                         child: Image.network(
              //                                           package.image,
              //                                           fit: BoxFit.cover,
              //                                           errorBuilder: (context,
              //                                               error, stackTrace) {
              //                                             return const Icon(
              //                                               Icons.person,
              //                                               size: 60,
              //                                               color: Colors.grey,
              //                                             );
              //                                           },
              //                                         ),
              //                                       ),
              //                                     ),
              //                                     SizedBox(width: 10),
              //                                     Expanded(
              //                                       child: Text(
              //                                         '${package.packageName} | ${package.packageNameMarathi ?? ''}',
              //                                         style: GoogleFonts.lato(
              //                                           fontSize: 18,
              //                                           fontWeight:
              //                                               FontWeight.w600,
              //                                         ),
              //                                       ),
              //                                     ),
              //                                     Icon(
              //                                       isExpanded
              //                                           ? CupertinoIcons
              //                                               .chevron_up
              //                                           : CupertinoIcons
              //                                               .chevron_down,
              //                                       color: Colors.black,
              //                                     ),
              //                                   ],
              //                                 ),
              //                                 SizedBox(height: 20),
              //                                 if (isExpanded)
              //                                   AnimatedContainer(
              //                                     duration: Duration(
              //                                         milliseconds: 300),
              //                                     height:
              //                                         package.services.length *
              //                                             80.0,
              //                                     decoration: BoxDecoration(
              //                                       color: CustomColors
              //                                           .backgroundPrimary, // Set your desired background color here
              //                                       borderRadius:
              //                                           BorderRadius.circular(
              //                                               15), // Set border radius
              //                                     ),
              //                                     child: ListView(
              //                                       shrinkWrap: true,
              //                                       children: package.services
              //                                           .map((service) {
              //                                         return Padding(
              //                                           padding: const EdgeInsets
              //                                               .symmetric(
              //                                               vertical:
              //                                                   5), // Adjust gap here
              //                                           child: Container(
              //                                             decoration:
              //                                                 BoxDecoration(
              //                                               color: Color(
              //                                                   0xFFFAFAFA), // Optional: background color for each card
              //                                               borderRadius:
              //                                                   BorderRadius
              //                                                       .circular(
              //                                                           10), // Optional: border radius for cards
              //                                             ),
              //                                             child: ListTile(
              //                                               leading: Container(
              //                                                 width: 40,
              //                                                 height: 40,
              //                                                 decoration:
              //                                                     BoxDecoration(
              //                                                   shape: BoxShape
              //                                                       .rectangle,
              //                                                   color: Colors
              //                                                       .grey[200],
              //                                                 ),
              //                                                 child: ClipRect(
              //                                                   child: Image
              //                                                       .network(
              //                                                     service.image,
              //                                                     fit: BoxFit
              //                                                         .cover,
              //                                                     errorBuilder:
              //                                                         (context,
              //                                                             error,
              //                                                             stackTrace) {
              //                                                       return const Icon(
              //                                                         Icons
              //                                                             .person,
              //                                                         size: 40,
              //                                                         color: Colors
              //                                                             .grey,
              //                                                       );
              //                                                     },
              //                                                   ),
              //                                                 ),
              //                                               ),
              //                                               title: Text(
              //                                                 '${service.serviceName} | ${service.serviceMarathiName ?? ''}',
              //                                                 overflow:
              //                                                     TextOverflow
              //                                                         .ellipsis,
              //                                                 style: GoogleFonts
              //                                                     .lato(
              //                                                   fontSize: 16,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .bold,
              //                                                   color: service.isServiceAvailable ==
              //                                                           '1'
              //                                                       ? Colors
              //                                                           .black
              //                                                       : Colors
              //                                                           .grey,
              //                                                 ),
              //                                               ),
              //                                               subtitle: Text(
              //                                                 '${service.duration} minutes',
              //                                                 style: GoogleFonts
              //                                                     .lato(
              //                                                   fontSize: 12,
              //                                                   color:
              //                                                       Colors.grey,
              //                                                 ),
              //                                               ),
              //                                             ),
              //                                           ),
              //                                         );
              //                                       }).toList(),
              //                                     ),
              //                                   ),
              //                               ],
              //                             ),
              //                           ),
              //                         );
              //                       },
              //                     );
              //                   },
              //                 ),
              // ),
              Expanded(
                child: _isLoading
                    ? _buildSkeletonLoader()
                    : _filteredPackages.isEmpty
                        ? Center(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.0,
                                left: MediaQuery.of(context).size.width * 0.02,
                              ),
                              child: Image.asset(
                                'assets/nodata2.png', // Replace with your image path
                                height: MediaQuery.of(context).size.height *
                                    0.7, // 70% of screen height
                                width: MediaQuery.of(context).size.width *
                                    0.7, // 70% of screen width
                              ),
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 20),
                            itemCount: _filteredPackages.length,
                            itemBuilder: (context, index) {
                              final package = _filteredPackages[index];
                              final isExpanded =
                                  _expandedPackages[package.packageId] ??
                                      false; // Track expansion state
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x00000008),
                                      offset: Offset(0, 5),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _expandedPackages[package.packageId] =
                                              !isExpanded; // Toggle expansion state
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child: Image.network(
                                                package.image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  // Display a Flutter icon when the image is not available
                                                  return Icon(
                                                    Icons.image_not_supported,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  // Display a loading spinner while the image is loading
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${package.packageName} | ${package.packageNameMarathi ?? ''}',
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                // Uncomment if you want to show the price
                                                // Text(
                                                //   '₹${package.price}',
                                                //   style: TextStyle(
                                                //     fontFamily: 'Lato',
                                                //     fontSize: 16,
                                                //     fontWeight: FontWeight.bold,
                                                //     color: Colors.black,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? CupertinoIcons.chevron_up
                                                : CupertinoIcons.chevron_down,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isExpanded) ...[
                                      SizedBox(height: 10),
                                      Column(
                                        children:
                                            package.services.map((service) {
                                          final isSelected = _selectedServices[
                                                  service.serviceId] ??
                                              false;
                                          final isAvailable =
                                              service.isServiceAvailable == '1';
                                          final hasProducts =
                                              service.products.isNotEmpty;

                                          return GestureDetector(
                                            onTap: isAvailable
                                                ? () {
                                                    // Create uniqueServiceId here
                                                    String uniqueServiceId =
                                                        '${package.packageId}:${service.serviceId}';
                                                    _toggleServiceSelection(
                                                        service.serviceId,
                                                        package.packageId);
                                                  }
                                                : null,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 15),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isAvailable
                                                    ? Color(0xFFFAFAFA)
                                                    : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x00000008),
                                                    offset: Offset(0, 5),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                leading: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          service.image),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  '${service.serviceName} | ${service.serviceMarathiName ?? ''}',
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isAvailable
                                                          ? Colors.black
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Uncomment if you want to show the price
                                                    // Text(
                                                    //   '₹${service.price}',
                                                    //   style: TextStyle(
                                                    //     fontFamily: 'Lato',
                                                    //     fontSize: 16,
                                                    //     fontWeight: FontWeight.bold,
                                                    //     color: isAvailable
                                                    //         ? Colors.black
                                                    //         : Colors.grey,
                                                    //   ),
                                                    // ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons.clock,
                                                          size: 18,
                                                          color: isAvailable
                                                              ? Colors.grey
                                                              : Colors.grey,
                                                        ),
                                                        SizedBox(width: 4),
                                                        // Text(
                                                        //   '${service.duration} minutes',
                                                        //   style:
                                                        //       GoogleFonts.lato(
                                                        //     textStyle:
                                                        //         TextStyle(
                                                        //       fontSize: 12,
                                                        //       color: isAvailable
                                                        //           ? Colors.grey
                                                        //           : Colors
                                                        //               .grey, // Both conditions have the same color
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          '${(int.tryParse(service.duration.toString()) ?? 0) >= 60 ? (int.tryParse(service.duration.toString()) ?? 0) ~/ 60 : ''}${(int.tryParse(service.duration.toString()) ?? 0) >= 60 ? ' hour ' : ''}${(int.tryParse(service.duration.toString()) ?? 0) % 60} minutes',
                                                          style:
                                                              GoogleFonts.lato(
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 12,
                                                              color: isAvailable
                                                                  ? Colors.grey
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        if (hasProducts)
                                                          GestureDetector(
                                                            onTap: isAvailable
                                                                ? () {
                                                                    // _showOfferedProductsDialog(service
                                                                    //     .products
                                                                    //     .cast<
                                                                    //         ProductInPackage>());
                                                                  }
                                                                : null,
                                                            child: Text(
                                                              '',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: isAvailable
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                trailing: Icon(
                                                  _selectedServices[
                                                              '${package.packageId}:${service.serviceId}'] ??
                                                          false
                                                      ? CupertinoIcons
                                                          .check_mark_circled_solid
                                                      : CupertinoIcons.circle,
                                                  color: isAvailable
                                                      ? Colors.blue[900]
                                                      : Colors.grey,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
              )
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Aligns buttons on both sides
              children: [
                Container(
                  width:
                      135, // Set the width of the button container to 135 pixels
                  height:
                      40, // Set the height of the button container to 40 pixels
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the background color to white
                    border: Border.all(
                        color: CustomColors.backgroundtext,
                        width: 2), // Add a blue border
                    borderRadius: BorderRadius.circular(6), // Set border radius
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PackageSelectionPage(
                      //       onConfirm: () {
                      //         // Your callback logic here
                      //       },
                      //     ),
                      //   ),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StorePackagePage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove any default padding
                      minimumSize: Size(135,
                          40), // Set minimum size to match the Container size
                      backgroundColor: Colors
                          .transparent, // Make the button background transparent
                    ),
                    child: Text(
                      'Buy Package',
                      style: GoogleFonts.lato(
                        fontSize: 14, // Adjust font size for the button text
                        color: CustomColors
                            .backgroundtext, // Set text color to blue
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _selectedServices.values.any((selected) => selected),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: CustomColors.backgroundtext,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        // Check if any service is selected
                        bool anyServiceSelected = _selectedServices.values
                            .any((selected) => selected);
                        if (!anyServiceSelected) {
                          // Show a snackbar or a message if no services are selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please select at least one service before proceeding.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; // Prevent navigation if no services are selected
                        }

                        // Proceed to the next step if services are selected
                        await _storeSelectedServices();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SpecialServices()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(120, 35),
                        backgroundColor: CustomColors.backgroundtext,
                      ),
                      child: Text(
                        'Next Step',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                // Container(
                //   width:
                //       135, // Set the width of the button container to 135 pixels
                //   height:
                //       40, // Set the height of the button container to 40 pixels
                //   decoration: BoxDecoration(
                //     color: _selectedPackageId != null
                //         ? Color(
                //             0xFF0056D0) // Blue color if a package is selected
                //         : Color(
                //             0xFF0056D0), // Grey color if no package is selected
                //     borderRadius: BorderRadius.circular(6), // Set border radius
                //   ),
                //   child: TextButton(
                //     onPressed: () async {
                //       if (_selectedPackageId == null) {
                //         // Show a snackbar if no package is selected
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(
                //             content: Text(
                //                 'Please select a package before proceeding.'),
                //             backgroundColor: Colors
                //                 .red, // Set the background color for the snackbar
                //             duration: Duration(
                //                 seconds:
                //                     2), // Duration for how long the snackbar is displayed
                //           ),
                //         );
                //       } else {
                //         // Perform the action if a package is selected
                //         await _storeSelectedServices();
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => SpecialServices(),
                //           ),
                //         );
                //       }
                //     },
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.zero, // Remove any default padding
                //       minimumSize: Size(135,
                //           40), // Set minimum size to match the Container size
                //       backgroundColor: Colors
                //           .transparent, // Make the button background transparent
                //     ),
                //     child: Text(
                //       'Next Step',
                //       style: GoogleFonts.lato(
                //         fontSize: 14, // Adjust font size for the button text
                //         color: Colors.white,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // )

                // Container(
                //   width:
                //       135, // Set the width of the button container to 135 pixels
                //   height:
                //       40, // Set the height of the button container to 40 pixels
                //   decoration: BoxDecoration(
                //     color: _selectedPackageId != null
                //         ? Color(
                //             0xFF0056D0) // Blue color if a package is selected
                //         : Colors.grey, // Grey color if no package is selected
                //     borderRadius: BorderRadius.circular(6), // Set border radius
                //   ),
                //   child: TextButton(
                //     onPressed: _selectedPackageId != null
                //         ? () async {
                //             await _storeSelectedServices();
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => SpecialServicesPage(),
                //               ),
                //             );
                //           }
                //         : null, // Disable button if no package is selected
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.zero, // Remove any default padding
                //       minimumSize: Size(135,
                //           40), // Set minimum size to match the Container size
                //       backgroundColor: Colors
                //           .transparent, // Make the button background transparent
                //     ),
                //     child: Text(
                //       'Next Step',
                //       style: GoogleFonts.lato(
                //         fontSize: 14, // Adjust font size for the button text
                //         color: Colors.white,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
