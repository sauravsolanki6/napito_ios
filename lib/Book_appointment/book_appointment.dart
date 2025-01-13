import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Book_appointment/services_api_controller.dart';
import 'package:ms_salon_task/Book_appointment/select_package.dart';
import 'package:ms_salon_task/Book_appointment/special_services.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/services/special_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer package for skeleton loader

class BookAppointmentPage extends StatefulWidget {
  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  bool _isLoading = true;
  bool _isGiftCardVisible = true;
  String _errorMessage = '';
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  String _customerID = '';
  String _branchID = '';
  bool _isExpanded = false;
  String _salonID = '';
  String _expandedServiceId = '';
  String _searchQuery = ''; // Added search query state
  String _offerName = '';
  String _offerText = '';
  final TextEditingController _searchController = TextEditingController();
  String? globalGiftCardCode;
  String? globalGiftCardName;
  // Map to keep track of selected services
  Map<String, bool> _selectedServices = {};

  // Set to keep track of checked products in the dialog
  Set<String> _checkedProductIds = {};

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
      throw Exception('No valid customer ID found');
    }

    final String? offersResponse = prefs.getString('offers_response');
    if (offersResponse != null) {
      print('Offers response from SharedPreferences: $offersResponse');

      final Map<String, dynamic> decodedResponse = jsonDecode(offersResponse);
      final List<dynamic> offers = decodedResponse['data'] ?? [];

      if (offers.isNotEmpty) {
        final firstOffer = offers[0];
        _offerName = firstOffer['offer_name'] ?? '';
        _offerText = firstOffer['offer_text'] ?? '';
      } else {
        _offerName = '';
        _offerText = '';
      }
    } else {
      _offerName = '';
      _offerText = '';
    }

    final savedGiftCardCode = prefs.getString('gift_card_code') ?? '';
    final savedGiftCardName = prefs.getString('gift_card_name') ?? '';
    if (savedGiftCardCode.isNotEmpty) {
      globalGiftCardCode = savedGiftCardCode;
      print('Gift Card Code retrieved: $globalGiftCardCode');
    }
    if (savedGiftCardName.isNotEmpty) {
      globalGiftCardName = savedGiftCardName;
      print('Gift Card Name retrieved: $globalGiftCardName');
    }
    setState(() {
      _customerID = customerID;
      _branchID = branchID;
      _salonID = salonID;
      _isLoading = true;
    });

    try {
      final apiController = ServicesApiController();
      List<Category> categories = await apiController.fetchBookingServices(
          _salonID, _branchID, _customerID);

      setState(() {
        _categories = categories;
        _filteredCategories =
            List.from(_categories); // Initialize filtered categories
        _isLoading = false;

        // Initialize the _selectedServices map with default values
        _selectedServices = {
          for (var category in _categories)
            for (var service in category.services) service.serviceId: false,
        };

        _loadSelectedServicesFromPreferences();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSelectedServicesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedServiceDataJson = prefs.getString('selected_service_data1');

    if (selectedServiceDataJson != null) {
      try {
        Map<String, dynamic> selectedServiceData =
            jsonDecode(selectedServiceDataJson);

        setState(() {
          for (var serviceId in selectedServiceData.keys) {
            if (_selectedServices.containsKey(serviceId)) {
              _selectedServices[serviceId] = true;
            }
          }
        });
      } catch (e) {
        print('Error loading selected services: $e');
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _initializeData();
  }

  Future<void> _toggleServiceSelection(String serviceId) async {
    print('Toggling serviceId: $serviceId');
    print('Before toggle: $_selectedServices');

    setState(() {
      // Safely toggle the service selection state
      _selectedServices[serviceId] = !(_selectedServices[serviceId] ?? false);
    });

    print('After toggle: $_selectedServices');

    // Map to store detailed information about selected services
    Map<String, dynamic> selectedServiceData = {};

    // Iterate over categories to find selected services and their details
    for (var category in _categories) {
      // Iterate over subcategories
      for (var subCategory in category.subCategories) {
        for (var service in subCategory.services) {
          print(
              'Service ID: ${service.serviceId}, Selected: ${_selectedServices[service.serviceId]}');
          if (_selectedServices[service.serviceId] == true) {
            selectedServiceData[service.serviceId] = {
              'isSpecial': service.isSpecial,
              'serviceId': service.serviceId,
              'categoryId': category.categoryId,
              'categoryName': category.categoryName,
              'subCategoryId': subCategory.subCategoryId,
              'subCategoryName': subCategory.subCategoryName,
              'serviceName': service.serviceName,
              'serviceMarathiName': service.serviceMarathiName,
              'price': service.price,
              'isOfferApplied': service.isOfferApplied,
              'appliedOfferId': service.appliedOfferId,
              'image': service.image,
              'duration': service.serviceDuration,
              'products': service.products.map((product) {
                return {
                  'productId': product.productId,
                  'productName': product.productName,
                  'productPrice': product.productPrice,
                };
              }).toList(),
            };
          }
        }
      }
    }

    // Convert the map to JSON
    String selectedServiceDataJson = jsonEncode(selectedServiceData);
    print('Selected Service Data JSON: $selectedServiceDataJson');

    // Save the JSON to SharedPreferences
    await _storeSelectedServices();
    await _saveSelectedServicesToPreferences(selectedServiceDataJson);

    // Log the data for debugging
    List<String> selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print('Selected Service IDs: $selectedServiceIds');
  }

  Future<bool> _storeSelectedServices() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedServiceIds.isEmpty) {
      await prefs.remove('selected_service_data1');
      return false; // No services selected
    } else {
      await prefs.setStringList('selected_service_ids', selectedServiceIds);

      Map<String, dynamic> selectedServiceData = {};

      // Iterate through categories and subcategories to find selected services
      for (var category in _categories) {
        for (var subCategory in category.subCategories) {
          for (var service in subCategory.services) {
            if (_selectedServices[service.serviceId] == true) {
              selectedServiceData[service.serviceId] = {
                'isSpecial': service.isSpecial,
                'serviceId': service.serviceId,
                'categoryId': category.categoryId,
                'categoryName': category.categoryName,
                'subCategoryId': subCategory.subCategoryId,
                'subCategoryName': subCategory.subCategoryName,
                'serviceName': service.serviceName,
                'serviceMarathiName': service.serviceMarathiName,
                'price': service.price,
                'isOfferApplied': service.isOfferApplied,
                'appliedOfferId': service.appliedOfferId,
                'image': service.image,
                'duration': service.serviceDuration,
                'products': service.products.where((product) {
                  // Store only checked products
                  return _checkedProductIds.contains(product.productId);
                }).map((product) {
                  return {
                    'productId': product.productId,
                    'productName': product.productName,
                    'productPrice': product.productPrice,
                  };
                }).toList(),
              };
            }
          }
        }
      }

      String selectedServiceDataJson = jsonEncode(selectedServiceData);

      try {
        await _saveSelectedServicesToPreferences(selectedServiceDataJson);
        // Verify by retrieving the stored data
        String? storedData = prefs.getString('selected_service_data1');
        print('Stored data: $storedData');
        return true; // Services selected and saved
      } catch (e) {
        print('Error saving or retrieving data: $e');
        return false; // Error occurred
      }
    }
  }

  Future<void> _saveSelectedServicesToPreferences(String data) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      bool isSaved = await prefs.setString('selected_service_data1', data);
      if (isSaved) {
        print('Data successfully saved.');
      } else {
        print('Failed to save data.');
      }
    } catch (e) {
      print('Error saving data to SharedPreferences: $e');
    }
  }

  // void _showOfferedProductsDialog(List<Product> products) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             backgroundColor: Color(0xFFFAFAFA),
  //             title: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Offered Products',
  //                   style: GoogleFonts.lato(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     height: 14.4 / 12,
  //                     letterSpacing: 0.02,
  //                   ),
  //                 ),
  //                 SizedBox(height: 20),
  //                 Divider(
  //                   color: Colors.grey[400], // Grey line
  //                   thickness: 1.0,
  //                 ),
  //               ],
  //             ),
  //             content: SizedBox(
  //               width: MediaQuery.of(context).size.width *
  //                   0.9, // 90% of screen width
  //               child: Column(
  //                 mainAxisSize: MainAxisSize
  //                     .min, // Adjust size of the column based on content
  //                 children: [
  //                   ListView(
  //                     shrinkWrap:
  //                         true, // Allow the ListView to take minimum space
  //                     physics:
  //                         NeverScrollableScrollPhysics(), // Disable scrolling
  //                     children: products.map((product) {
  //                       return CheckboxListTile(
  //                         value: _checkedProductIds.contains(product.productId),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _checkedProductIds.add(product.productId);
  //                             } else {
  //                               _checkedProductIds.remove(product.productId);
  //                             }
  //                           });
  //                         },
  //                         title: Text(
  //                           '${product.productName}  ₹ ${product.productPrice ?? ''}',
  //                           style: GoogleFonts.lato(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                             height: 14.4 / 12,
  //                             letterSpacing: 0.02,
  //                           ),
  //                         ),
  //                         controlAffinity: ListTileControlAffinity.leading,
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               // TextButton(
  //               //   onPressed: () {
  //               //     Navigator.of(context).pop(); // Close the dialog
  //               //   },
  //               //   child: Text(
  //               //     'Close',
  //               //     style: GoogleFonts.lato(
  //               //       fontSize: 12,
  //               //       fontWeight: FontWeight.w600,
  //               //     ),
  //               //   ),
  //               // ),
  //               TextButton(
  //                 onPressed: () async {
  //                   final prefs = await SharedPreferences.getInstance();
  //                   await prefs.setStringList(
  //                       'selected_product_ids', _checkedProductIds.toList());
  //                   await _storeSelectedServices();
  //                   Navigator.of(context).pop(); // Close the dialog
  //                   print('Confirmed products: ${_checkedProductIds.toList()}');
  //                 },
  //                 child: Text(
  //                   'OK',
  //                   style: GoogleFonts.lato(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void _showOfferedProductsDialog(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    // Load previously selected product IDs
    List<String>? selectedProductIds =
        prefs.getStringList('selected_product_ids');
    if (selectedProductIds != null) {
      _checkedProductIds =
          selectedProductIds.toSet(); // Convert to Set for easier management
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFAFAFA),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Product',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 14.4 / 12,
                      letterSpacing: 0.02,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: Colors.grey[400], // Grey line
                    thickness: 1.0,
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Adjust size of the column based on content
                  children: [
                    ListView(
                      shrinkWrap:
                          true, // Allow the ListView to take minimum space
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling
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
                            '${product.productName}  ₹ ${product.productPrice ?? ''}',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 14.4 / 12,
                              letterSpacing: 0.02,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList(
                        'selected_product_ids', _checkedProductIds.toList());
                    await _storeSelectedServices();
                    Navigator.of(context).pop(); // Close the dialog
                    print('Confirmed products: ${_checkedProductIds.toList()}');
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCategories = _categories.where((category) {
        return category.categoryName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            category.services.any((service) =>
                service.serviceName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                service.serviceMarathiName
                    .toLowerCase()
                    .contains(query.toLowerCase()));
      }).toList();
    });
  }

  Future<void> _clearOffersResponse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offers_response');
  }

  Future<void> _clearGiftcardpref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gift_card_code');
    await prefs.remove('gift_card_name');
  }

  Future<void> _handleOfferClose() async {
    await _clearOffersResponse();
    setState(() {
      _offerName = '';
      _offerText = '';
    });
    await _refreshData();
  }

  Future<void> _handleGiftcardClose() async {
    await _clearGiftcardpref();
    setState(() {
      globalGiftCardCode = '';
      globalGiftCardName = '';
      _isGiftCardVisible = false;
    });
    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.1;

    Widget _buildSkeletonLoader() {
      return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemCount: 5, // Number of skeleton items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300] ?? Colors.grey,
            highlightColor: Colors.grey[100] ?? Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  const BoxShadow(
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
                    const SizedBox(height: 4),
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

    return WillPopScope(
      onWillPop: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('selected_service_data1');
        await prefs.remove('selected_service_data');
        await prefs.remove('gift_card_code');
        await prefs.remove('gift_card_name');
        await prefs.remove('selected_stylist_id');
        // Replace with your key
        await prefs.remove('selected_package_data_add_package');
        await prefs.remove('coupons_response');
        await prefs.remove('minimum_amount');
        await prefs.remove('offered_price');
        await prefs.remove('coupon_applied');
        await prefs.remove('coupon_details');
        await prefs.remove('selected_product_ids');
        await prefs.remove('stylist_service_data_stored');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home', // Replace with your homepage route name
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('gift_card_code');
                  await prefs.remove('gift_card_name');
                  await prefs.remove('selected_service_data1');
                  await prefs.remove('selected_service_data');
                  await prefs.remove('selected_product_ids');
                  await prefs.remove('selected_package_data_add_package');
                  // Replace with your key
                  await prefs.remove('selected_package_data_add_package');
                  await prefs.remove('offer_details');
                  await prefs.remove('offer_applied');
                  await prefs.remove('coupons_response');
                  await prefs.remove('minimum_amount');
                  await prefs.remove('selected_stylist_id');
                  await prefs.remove('offered_price');
                  await prefs.remove('coupon_applied');
                  await prefs.remove('coupon_details');
                  await prefs.remove('stylist_service_data_stored');
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home', // Replace with your homepage route name
                    (Route<dynamic> route) =>
                        false, // This will remove all previous routes
                  );
                },
              ),
              Expanded(
                child: Text(
                  'Select Service',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // SizedBox(height: 10),\
              //seatrchbar
              // Container(
              //   padding: EdgeInsets.all(12), // Adjust padding as needed
              //   decoration: BoxDecoration(
              //     color: CustomColors.backgroundLight,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.white,
              //         spreadRadius: 2,
              //       ),
              //     ],
              //   ),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 12),
              //     height: 40,
              //     width:
              //         screenWidth * 0.9, // Ensure it fits within screen width
              //     decoration: BoxDecoration(
              //       color: Color(0xFFF2F2F2),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: TextField(
              //       onChanged: (query) => _filterCategories(query),
              //       controller:
              //           _searchController, // Add a TextEditingController
              //       decoration: InputDecoration(
              //         contentPadding:
              //             EdgeInsets.symmetric(vertical: 13, horizontal: 12),
              //         hintText: 'Search...',
              //         hintStyle: TextStyle(
              //           fontFamily: 'Lato',
              //           fontSize: 14,
              //           fontWeight: FontWeight.w400,
              //           color: Color(0xFFC4C4C4),
              //         ),
              //         border: InputBorder.none,
              //         prefixIcon: Padding(
              //           padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
              //                   _filterCategories(''); // Reset the filter
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

              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: CustomColors.backgroundtext, width: 0.5),
                  boxShadow: [
                    const BoxShadow(
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
                      child: Container(
                        decoration: const BoxDecoration(
                          color: CustomColors.backgroundtext,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Services',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await _storeSelectedServices(); // Save selected services
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('selected_service_data');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectPackagePage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Package',
                              style: GoogleFonts.lato(
                                color: CustomColors.backgroundtext,
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
              if (_offerName?.isNotEmpty ?? false)
                Container(
                  height: screenHeight * 0.15,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: SizedBox(
                            width: screenWidth * 0.9,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withOpacity(0.9),
                                    Colors.lightBlueAccent.withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black.withOpacity(0.25),
                                //     offset: Offset(0, 6),
                                //     blurRadius: 12,
                                //     spreadRadius: 2,
                                //   ),
                                // ],
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        '$_offerName Offer Applied',
                                        style: const TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Container(
                                      //   // Set the width to 40 pixels
                                      //   child: Text(
                                      //     '$_offerText',
                                      //     style: TextStyle(
                                      //       fontFamily: 'Lato',
                                      //       fontSize: 14,
                                      //       color: Colors.white70,
                                      //     ),
                                      //     maxLines:
                                      //         2, // Limits the text to 2 lines
                                      //     overflow: TextOverflow
                                      //         .ellipsis, // Shows ... after the text
                                      //   ),
                                      // ),
                                      const Text(
                                        'Remove this offer whenever desired.',
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: _handleOfferClose,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isGiftCardVisible &&
                  globalGiftCardCode != null &&
                  globalGiftCardName != null)
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.14, // Dynamically adjust height
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.8),
                            Colors.lightBlueAccent.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Gift Card Applied: $globalGiftCardName',
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Giftcard Code is $globalGiftCardCode',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'You can remove this giftcard anytime.',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _handleGiftcardClose,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? _buildSkeletonLoader()
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/nodata2.png', // Replace with your image path
                                    height: MediaQuery.of(context).size.height *
                                        0.4, // 40% of screen height
                                    width: MediaQuery.of(context).size.width *
                                        0.7, // 70% of screen width
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredCategories.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/nodata2.png', // Replace with your image path
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4, // 40% of screen height
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7, // 70% of screen width
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                    ),
                                    child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 10),
                                      itemCount: _filteredCategories.length,
                                      itemBuilder: (context, index) {
                                        final category =
                                            _filteredCategories[index];

                                        // Check if any service in this category is selected
                                        final isCategoryExpanded =
                                            category.services.any((service) =>
                                                _selectedServices[
                                                    service.serviceId] ??
                                                false);

                                        // Wrap the entire Container in a GestureDetector
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              category.isExpanded = !category
                                                  .isExpanded; // Toggle expansion state
                                            });
                                          },
                                          child:
                                              (category.subCategories != null &&
                                                      category.subCategories
                                                          .isNotEmpty)
                                                  ? Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        color: CustomColors
                                                            .backgroundPrimary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(
                                                            color: const Color
                                                                .fromARGB(
                                                                130,
                                                                255,
                                                                253,
                                                                253)), // Add grey border
                                                        boxShadow: [
                                                          const BoxShadow(
                                                            color: Color(
                                                                0x00000008),
                                                            offset:
                                                                Offset(0, 5),
                                                            blurRadius: 10,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            category.isExpanded =
                                                                !category
                                                                    .isExpanded; // Toggle the expansion state
                                                          });
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(12),
                                                                          topRight:
                                                                              Radius.circular(43),
                                                                          bottomRight:
                                                                              Radius.circular(43),
                                                                          bottomLeft:
                                                                              Radius.circular(12),
                                                                        ),
                                                                        border:
                                                                            Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0), // Change color and opacity here
                                                                          width:
                                                                              2, // Adjust border width as needed
                                                                        ),
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              NetworkImage(category.image),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ClipOval(
                                                                        child: Image
                                                                            .network(
                                                                          category
                                                                              .image,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            return const Center(
                                                                              child: Icon(
                                                                                CupertinoIcons.person,
                                                                                size: 60,
                                                                                color: Colors.grey,
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      '${getLimitedText(category.categoryName)} | ${category.categoryMarathiName ?? ''}',
                                                                      style: GoogleFonts
                                                                          .lato(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: const Color(
                                                                            0xFF424752),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Check if subcategory is not null before rendering the dropdown icon
                                                                if (category.subCategories !=
                                                                        null &&
                                                                    category
                                                                        .subCategories
                                                                        .isNotEmpty)
                                                                  Icon(
                                                                    category.isExpanded
                                                                        ? CupertinoIcons
                                                                            .chevron_up
                                                                        : CupertinoIcons
                                                                            .chevron_right,
                                                                    color: const Color(
                                                                        0xFF424752),
                                                                  ),
                                                              ],
                                                            ),
                                                            if (category
                                                                .isExpanded) ...[
                                                              const SizedBox(
                                                                  height:
                                                                      10), // Space before subcategories
                                                              Column(
                                                                children: category
                                                                    .subCategories
                                                                    .map(
                                                                        (subCategory) {
                                                                  return Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0), // Adjust the gap between items
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                CustomColors.backgroundtextLight,
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          child:
                                                                              ListTile(
                                                                            title:
                                                                                Text(
                                                                              '${subCategory.subCategoryName} ||',
                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                            subtitle:
                                                                                Text(
                                                                              subCategory.subCategoryMarathiName,
                                                                              // style: const TextStyle(color: Colors.grey),
                                                                            ),
                                                                            leading: subCategory.image.isNotEmpty
                                                                                ? Container(
                                                                                    width: 60,
                                                                                    height: 60,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(12),
                                                                                        topRight: Radius.circular(43),
                                                                                        bottomRight: Radius.circular(43),
                                                                                        bottomLeft: Radius.circular(12),
                                                                                      ),
                                                                                      border: Border.all(
                                                                                        color: Colors.white,
                                                                                        width: 1,
                                                                                      ),
                                                                                      image: DecorationImage(
                                                                                        image: NetworkImage(subCategory.image),
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    child: ClipOval(
                                                                                      child: Image.network(
                                                                                        subCategory.image,
                                                                                        fit: BoxFit.cover,
                                                                                        errorBuilder: (context, error, stackTrace) {
                                                                                          return const Center(
                                                                                            child: Icon(
                                                                                              CupertinoIcons.person,
                                                                                              size: 60,
                                                                                              color: Colors.grey,
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : Container(
                                                                                    width: 60,
                                                                                    height: 60,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(12),
                                                                                        topRight: Radius.circular(43),
                                                                                        bottomRight: Radius.circular(43),
                                                                                        bottomLeft: Radius.circular(12),
                                                                                      ),
                                                                                      border: Border.all(
                                                                                        color: Colors.white,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    child: const Icon(
                                                                                      Icons.person,
                                                                                      size: 40,
                                                                                      color: Colors.grey,
                                                                                    ),
                                                                                  ),
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                subCategory.isExpanded = !subCategory.isExpanded;
                                                                              });
                                                                            },
                                                                            tileColor: subCategory.isExpanded
                                                                                ? Colors.blue[50]
                                                                                : null,
                                                                            trailing:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text(
                                                                                  subCategory.isExpanded ? "Hide Services" : "Show Services",
                                                                                  style: const TextStyle(
                                                                                    color: Colors.grey,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                                Icon(
                                                                                  subCategory.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (subCategory
                                                                          .isExpanded) ...[
                                                                        const SizedBox(
                                                                            height:
                                                                                10), // Space before services
                                                                        Column(
                                                                          children: subCategory
                                                                              .services
                                                                              .map((service) {
                                                                            final isSelected =
                                                                                _selectedServices[service.serviceId] ?? false;
                                                                            final hasProducts =
                                                                                service.products.isNotEmpty;

                                                                            return GestureDetector(
                                                                              onTap: () {
                                                                                _toggleServiceSelection(service.serviceId);
                                                                              },
                                                                              child: Container(
                                                                                margin: const EdgeInsets.symmetric(vertical: 3),
                                                                                padding: const EdgeInsets.all(2),
                                                                                decoration: BoxDecoration(
                                                                                  color: CustomColors.backgroundLight,
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                  boxShadow: [
                                                                                    const BoxShadow(
                                                                                      color: Color(0x00000008),
                                                                                      offset: Offset(0, 5),
                                                                                      blurRadius: 10,
                                                                                      spreadRadius: 1,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                child: ListTile(
                                                                                  leading: Container(
                                                                                    width: 64, // Set width to 64 pixels
                                                                                    height: 68, // Set height to 68 pixels
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(12), // Circular radius for the top-left corner
                                                                                        topRight: Radius.circular(12), // Circular radius for the top-right corner
                                                                                        bottomLeft: Radius.circular(12), // Circular radius for the bottom-left corner
                                                                                        bottomRight: Radius.circular(12), // No rounding for bottom-right
                                                                                      ),
                                                                                      image: DecorationImage(
                                                                                        image: NetworkImage(service.image),
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(12), // Apply border radius to ClipRRect
                                                                                      child: Image.network(
                                                                                        service.image,
                                                                                        fit: BoxFit.cover,
                                                                                        errorBuilder: (context, error, stackTrace) {
                                                                                          return const Center(
                                                                                            child: Icon(
                                                                                              CupertinoIcons.person,
                                                                                              size: 40,
                                                                                              color: Colors.grey,
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  title: Text(
                                                                                    '${service.serviceName} | ${service.serviceMarathiName ?? ''}',
                                                                                    style: GoogleFonts.lato(
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: const Color(0xFF424752),
                                                                                    ),
                                                                                  ),
                                                                                  subtitle: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      if (service.serviceDescription.isNotEmpty)
                                                                                        Text(
                                                                                          service.serviceDescription,
                                                                                          maxLines: _expandedServiceId == service.serviceId && _isExpanded
                                                                                              ? null // Expand only if the serviceId matches and is expanded
                                                                                              : 1, // Limit to 2 lines if not expanded
                                                                                          style: TextStyle(
                                                                                            fontFamily: 'Lato',
                                                                                            fontSize: MediaQuery.of(context).size.width * 0.03,
                                                                                            color: CustomColors.backgroundDark,
                                                                                          ),
                                                                                        ),
                                                                                      if (service.serviceDescription.isNotEmpty)
                                                                                        GestureDetector(
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              // Toggle expansion for the specific serviceId
                                                                                              if (_expandedServiceId == service.serviceId) {
                                                                                                _isExpanded = !_isExpanded;
                                                                                              } else {
                                                                                                // If a different service is clicked, expand that one and set others to not expanded
                                                                                                _expandedServiceId = service.serviceId;
                                                                                                _isExpanded = true; // Show "Read Less" after expansion
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          child: Text(
                                                                                            _expandedServiceId == service.serviceId && _isExpanded ? '(Read Less)' : '(Read More)', // Toggle text based on expansion state
                                                                                            style: TextStyle(
                                                                                              fontFamily: 'Lato',
                                                                                              fontSize: MediaQuery.of(context).size.width * 0.03,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              color: CustomColors.backgroundtext,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      const SizedBox(height: 3),
                                                                                      Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            CupertinoIcons.clock,
                                                                                            size: MediaQuery.of(context).size.width * 0.04, // Responsive icon size
                                                                                            color: Colors.grey,
                                                                                          ),
                                                                                          Text(
                                                                                            '${(int.parse(service.serviceDuration) ~/ 60) > 0 ? '${int.parse(service.serviceDuration) ~/ 60} hr ' : ''}${int.parse(service.serviceDuration) % 60} min',
                                                                                            style: TextStyle(
                                                                                              fontFamily: 'Lato',
                                                                                              fontSize: MediaQuery.of(context).size.width * 0.03, // Responsive font size
                                                                                              color: Colors.grey,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            ' | ₹${service.price}',
                                                                                            style: GoogleFonts.lato(
                                                                                              fontSize: MediaQuery.of(context).size.width * 0.03, // Responsive font size
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: const Color(0xFF424752),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      const SizedBox(height: 5),
                                                                                      Text(
                                                                                        '${service.rewardPoints}', // Assuming discount is available in the service object
                                                                                        style: TextStyle(fontFamily: 'Lato', fontSize: MediaQuery.of(context).size.width * 0.03, fontWeight: FontWeight.bold, color: CustomColors.backgroundtext),
                                                                                      ),
                                                                                      if (hasProducts) // Display Suggested Product if available
                                                                                        GestureDetector(
                                                                                          onTap: () {
                                                                                            _showOfferedProductsDialog(service.products);
                                                                                          },
                                                                                          child: Text(
                                                                                            'Suggested Product',
                                                                                            style: TextStyle(
                                                                                              fontFamily: 'Lato',
                                                                                              fontSize: MediaQuery.of(context).size.width * 0.03, // Responsive font size
                                                                                              fontWeight: FontWeight.w500,
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                    ],
                                                                                  ),
                                                                                  trailing: Icon(
                                                                                    isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                                                                                    color: CustomColors.backgroundtext,
                                                                                    size: 25,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Aligns the button to the right
              children: [
                Container(
                  width:
                      135, // Set the width of the button container to 135 pixels
                  height:
                      40, // Set the height of the button container to 40 pixels
                  decoration: BoxDecoration(
                    color: CustomColors.backgroundtext,
                    borderRadius: BorderRadius.circular(6), // Set border radius
                    // Optional: To make the button semi-transparent, use the opacity value
                    // If you want to set the opacity, you can wrap the Container in an Opacity widget
                    // opacity: 0, // Uncomment if you want the button to be fully transparent
                  ),
                  child: TextButton(
                    onPressed: () async {
                      bool hasSelectedServices = await _storeSelectedServices();
                      if (hasSelectedServices) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SpecialServicesPage(),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecialServices(),
                          ),
                        );
                      } else {
                        // Optionally show a message or alert if no services are selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select at least one service before proceeding.',
                            ),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove any default padding
                      minimumSize: const Size(135,
                          40), // Set minimum size to match the Container size
                      backgroundColor: Colors
                          .transparent, // Make the button background transparent
                    ),
                    child: Text(
                      'Next Step',
                      style: GoogleFonts.lato(
                        fontSize: 14, // Adjust font size for the button text
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

  String getLimitedText(String text) {
    List<String> words = text.split(' ');
    if (words.length > 4) {
      return words.take(4).join(' ') + '...';
    } else {
      return text;
    }
  }
}
