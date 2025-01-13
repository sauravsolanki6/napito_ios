import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Book_appointment/add_package_dialog.dart';
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Book_appointment/packages_api_controller.dart';
import 'package:ms_salon_task/Book_appointment/select_package.dart';
import 'package:ms_salon_task/Book_appointment/special_services.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/offers%20and%20membership/store_packages.dart';
import 'package:ms_salon_task/services/special_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CustomerPackages1 extends StatefulWidget {
  @override
  _CustomerPackages1State createState() => _CustomerPackages1State();
}

class _CustomerPackages1State extends State<CustomerPackages1> {
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  List<Package> _packages = [];
  List<Package> _filteredPackages = [];
  String _customerID = '';
  String _branchID = '';
  String _salonID = '';
  String _searchQuery = '';
  Map<String, bool> _expandedPackages = {};

  // Map to keep track of selected services
  Map<String, bool> _selectedServices = {};

  // Set to keep track of checked products in the dialog
  Set<String> _checkedProductIds = {};
  bool isSelected = false;
  Map<int, dynamic> servicesData = {};
  Map<int, dynamic> servicesData2 = {}; // Stores services data
  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    _initializeData();
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
      // Handle the error as needed, e.g., by showing an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
    } catch (e) {
      print('Error fetching packages: $e'); // Log the error for debugging
      setState(() {
        _filteredPackages =
            []; // Set to empty to trigger "No Packages Available"
        _isLoading = false;
      });
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
        SnackBar(
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

    // Check if any service is selected and store flag in shared preferences
    bool anyServiceSelected =
        _selectedServices.values.any((selected) => selected);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('anyServiceSelectedFlag', anyServiceSelected ? 1 : 0);

    // Print the flag value
    int flagValue = prefs.getInt('anyServiceSelectedFlag') ?? 0;
    print('Any service selected flag: $flagValue');
  }

  Future<void> _saveSelectedServicesToPreferences(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_service_data', jsonString);
  }

  Future<void> _storeSelectedServices() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedServiceIds.isEmpty) {
      // If no services are selected, clear the relevant data from SharedPreferences
      await prefs.remove('selected_service_data');
      await prefs.remove('selected_service_ids');
      await prefs.remove(
          'selected_product_ids'); // Clear selected product ids if needed
    } else {
      // If services are selected, save the service IDs and detailed information
      await prefs.setStringList('selected_service_ids', selectedServiceIds);

      // Map to store detailed information about selected services
      Map<String, dynamic> selectedServiceData = {};

      // Iterate over packages to find selected services and their details
      for (var package in _packages) {
        for (var service in package.services) {
          if (_selectedServices.containsKey(service.serviceId) &&
              _selectedServices[service.serviceId] == true) {
            // Collect all data for the service, including all products
            selectedServiceData[service.serviceId] = {
              'serviceId': service.serviceId,
              'serviceName': service.serviceName,

              'packageName': package.packageName,
              'package_id': service.packageId,
              'price': service.price,
              'is_old_package': service.isOldPackage,
              'package_allocation_id': service.packageAllocationId,
              'is_offer_applied': '', // Adjust if needed
              'applied_offer_id': '', // Adjust if needed
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

      // Convert the map to JSON
      String selectedServiceDataJson = jsonEncode(selectedServiceData);

      // Save the JSON to SharedPreferences
      await prefs.setString('selected_service_data2', selectedServiceDataJson);
      print(selectedServiceDataJson);

      // Retrieve and print the saved JSON to confirm
      String? storedServiceDataJson = prefs.getString('selected_service_data2');
      print('Stored Selected Service Data JSON: $storedServiceDataJson');
    }
  }

  // void _showOfferedProductsDialog(List<ProductInPackage> products) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             backgroundColor: Color(0xFFFAFAFA),
  //             title: Text('Offered Products'),
  //             content: SizedBox(
  //               width: double.maxFinite,
  //               child: ListView(
  //                 shrinkWrap: true,
  //                 children: products.map((product) {
  //                   return CheckboxListTile(
  //                     value: _checkedProductIds.contains(product.productId),
  //                     onChanged: (bool? value) {
  //                       setState(() {
  //                         if (value == true) {
  //                           _checkedProductIds.add(product.productId);
  //                         } else {
  //                           _checkedProductIds.remove(product.productId);
  //                         }
  //                       });
  //                     },
  //                     title: Text(
  //                       '${product.productName}  ₹ ${product.price ?? ''}',
  //                     ),
  //                     controlAffinity: ListTileControlAffinity.leading,
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('Close'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   final prefs = await SharedPreferences.getInstance();
  //                   await prefs.setStringList(
  //                       'selected_product_ids', _checkedProductIds.toList());
  //                   await _storeSelectedServices();
  //                   Navigator.of(context).pop();
  //                   print(
  //                       'Confirmed products in package: ${_checkedProductIds.toList()}');
  //                 },
  //                 child: Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _onBuyPackagesPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StorePackagePage()),
      //  builder: (context) => StorePackagePage()),
    );
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Buy Packages button pressed!'),
    //     duration: Duration(seconds: 2),
    //   ),
    // );
    // Add your navigation or functionality here
  }

  void _filterPackages(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPackages = _packages.where((package) {
        return package.packageName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            package.services.any((service) => service.serviceName
                .toLowerCase()
                .contains(query.toLowerCase()));
      }).toList();
    });
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(height: 20),
      itemCount: 5, // Number of skeleton items
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
              leading: CircleAvatar(
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

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_service_data1');
    await prefs.remove('selected_service_data');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.1;

    return WillPopScope(
      onWillPop: () async {
        // This will navigate back to the first occurrence of `HomePage` in the stack
        // Navigator.of(context).pop((route) => route.isFirst);
        await _clearPreferences();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    title: '',
                  )),
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Text(
            'Customer Packages',
            style: GoogleFonts.lato(
              textStyle: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: CustomColors.backgroundLight,
          iconTheme: IconThemeData(color: CustomColors.backgroundtext),
          // elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await _clearPreferences();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          title: '',
                        )),
              );
              // Navigator.pop(
              //     context); // This will take the user back to the previous screen
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: _onBuyPackagesPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    CustomColors.backgroundtext, // Set the text color to white
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Set border radius to 8
                ),
              ),
              child: Text(
                'BUY PACKAGES',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10), // Add some spacing between button and edge
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                height: 40,
                width: screenWidth - 24,
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController, // Add a TextEditingController
                  onChanged: (query) => _filterPackages(query),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 14.4 / 5,
                        color: Color(0xFFC4C4C4),
                      ),
                    ),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 2.0, right: 8.0),
                      child: Icon(
                        CupertinoIcons.search,
                        size: 25,
                        color: Colors.blue,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear(); // Clear the text
                              _filterPackages(''); // Reset the filter
                            },
                            child: Icon(
                              CupertinoIcons.clear_circled,
                              color: Colors.grey,
                              size: 22,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 15),
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
                  height: 35,
                  decoration: BoxDecoration(
                    color: CustomColors.backgroundtext,
                    borderRadius: BorderRadius.circular(6),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
