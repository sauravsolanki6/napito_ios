import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Book_appointment/add_package_dialog.dart';
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Book_appointment/packages_api_controller.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
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
      // Handle the error as needed, e.g., by showing an error message
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
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });

      // Show error message to the user using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

    // Map to collect selected service data
    Map<String, Map<String, dynamic>> selectedServiceData = {};

    // Iterate over packages and collect selected services only
    for (var package in _filteredPackages) {
      if (_selectedPackages[package.packageId] == true) {
        for (var service in package.services) {
          selectedServiceData[service.serviceId] = {
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
        }
      }
    }

    // Convert the map to JSON format
    String selectedServiceDataJson = jsonEncode(selectedServiceData);

    // Save the JSON to SharedPreferences
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
        return package.packageName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            package.services.any((service) => service.serviceName
                .toLowerCase()
                .contains(query.toLowerCase()));
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
      onWillPop: () async {
        Navigator.pushNamed(
          context,
          '/book_appointment', // Replace with your desired route name
        );
        return false; // Prevent the default back navigation
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
                },
              ),
              const Text(
                'Select Package',
                style: TextStyle(
                  fontFamily: 'Lato',
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
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                height: 40,
                width: screenWidth - 24,
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  onChanged: (query) => _filterPackages(query),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 14.4 / 5,
                      color: Color(0xFFC4C4C4),
                    ),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 2.0, right: 8.0),
                      child: Icon(
                        CupertinoIcons.search,
                        size: 25,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
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
                          child: const Center(
                            child: Text(
                              'Services',
                              style: TextStyle(
                                fontFamily: 'Lato',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectPackagePage(), // Replace with your actual page
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: CustomColors.backgroundtext,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Package',
                              style: TextStyle(
                                fontFamily: 'Lato',
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
              Expanded(
                child: _isLoading
                    ? _buildSkeletonLoader()
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              double horizontalMargin =
                                  constraints.maxWidth * 0.05;

                              return ListView.separated(
                                controller:
                                    _scrollController, // For synchronized scrolling
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 20),
                                itemCount: _filteredPackages.length,
                                itemBuilder: (context, index) {
                                  final package = _filteredPackages[index];
                                  bool isExpanded =
                                      _expandedPackages[package.packageId] ??
                                          false;
                                  bool isSelected =
                                      _selectedPackages[package.packageId] ??
                                          false;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Toggle expanded state
                                        _expandedPackages[package.packageId] =
                                            !isExpanded;

                                        // Toggle selected state if not in the expanded state
                                        if (!_expandedPackages[
                                            package.packageId]!) {
                                          _selectedPackages[package.packageId] =
                                              !isSelected;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: horizontalMargin),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (value) {
                                                  setState(() {
                                                    // Update selection state
                                                    if (value == true) {
                                                      _onPackageSelected(
                                                          package.packageId);
                                                      _selectedPackages[package
                                                          .packageId] = true;
                                                    } else {
                                                      _selectedPackages[package
                                                          .packageId] = false;
                                                    }
                                                  });
                                                },
                                              ),
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[200],
                                                ),
                                                child: ClipOval(
                                                  child: Image.network(
                                                    package.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color: Colors.grey,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  '${package.packageName} | ${package.packageNameMarathi ?? ''}',
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                isExpanded
                                                    ? CupertinoIcons.chevron_up
                                                    : CupertinoIcons
                                                        .chevron_down,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                          if (isExpanded)
                                            AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 300),
                                              height: package.services.length *
                                                  80.0,
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: package.services
                                                    .map((service) {
                                                  return ListTile(
                                                    leading: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: ClipRect(
                                                        child: Image.network(
                                                          service.image,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Icon(
                                                              Icons.person,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      '${service.serviceName} | ${service.serviceMarathiName ?? ''}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            service.isServiceAvailable ==
                                                                    '1'
                                                                ? Colors.black
                                                                : Colors.grey,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      '${service.duration} minutes',
                                                      style: TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PackageSelectionPage(
                            onConfirm: () {
                              // Your callback logic here
                            },
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(120, 35),
                      backgroundColor: CustomColors.backgroundtext,
                    ),
                    child: const Text(
                      'Buy Package',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: CustomColors.backgroundtext,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      await _storeSelectedServices();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SpecialServicesPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(120, 35),
                      backgroundColor: CustomColors.backgroundtext,
                    ),
                    child: const Text(
                      'Next Step',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
