// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Book_appointment/services_api_controller.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shimmer/shimmer.dart';

// Define the models for the service and response

// ServiceDetailPage Widget
class ServiceDetailPage extends StatefulWidget {
  final String categoryId;
  final String categoryName; // Add this line
  ServiceDetailPage(
      {required this.categoryId,
      required this.categoryName}); // Update constructor

  @override
  _ServiceDetailPageState createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late Future<ServiceResponse> _serviceDetails;
  late List<Service> _services;
  List<Service> _filteredServices = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _serviceDetails = fetchServiceDetails();
    _searchController.addListener(_filterServices);
  }

  Future<ServiceResponse> fetchServiceDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
      'category_id': widget.categoryId,
    };

    // Print the request body
    print('Request body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('${Config.apiUrl}customer/store-services/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Print the response status and body
    print('Response status: ${response.statusCode}');
    print('Response body of service cat: ${response.body}');

    if (response.statusCode == 200) {
      final serviceResponse =
          ServiceResponse.fromJson(jsonDecode(response.body));
      setState(() {
        _services = serviceResponse.data;
        _filteredServices = _services;
      });
      return serviceResponse;
    } else {
      throw Exception('Failed to load service details');
    }
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        final serviceName = service.serviceName.toLowerCase();
        final serviceMarathiName = service.serviceMarathiName.toLowerCase();
        return serviceName.contains(query) ||
            serviceMarathiName.contains(query);
      }).toList();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _serviceDetails = fetchServiceDetails();
    });
  }

  void _toggleProductsVisibility(Service service) {
    setState(() {
      service.isProductsVisible = !service.isProductsVisible;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.backgroundLight,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Text(
                widget.categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.black,
                ),
                overflow: TextOverflow
                    .ellipsis, // This will add the ellipsis when the text overflows
                maxLines: 1, // Ensures only one line of text
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width *
                  0.05, // 5% margin from left
              right: MediaQuery.of(context).size.width *
                  0.05, // 5% margin from right
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) =>
                      _filterServices(), // Call _filterServices on input change
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 14.4 / 7,
                      color: const Color(0xFFC4C4C4),
                    ),
                    border: InputBorder.none,
                    icon: const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        CupertinoIcons.search,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear(); // Clear the text
                              _filterServices(); // Reset the filtered services
                            },
                            child: const Icon(
                              CupertinoIcons.clear_circled,
                              color: Colors.grey,
                              size: 22,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: MediaQuery.of(context).size.width *
                  0.01, // 5% margin from left
              right: MediaQuery.of(context).size.width *
                  0.01, // 5% margin from right
              bottom: 0,
              child: FutureBuilder<ServiceResponse>(
                future: _serviceDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        height: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            width: 100,
                                            height: 14,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 100,
                                        height: 14,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || _filteredServices.isEmpty) {
                    return Center(
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
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x00000008),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (service.products.isNotEmpty) {
                                setState(() {
                                  service.isProductsVisible =
                                      !service.isProductsVisible;
                                });
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 100,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(service.image),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            service.serviceName,
                                                        style: GoogleFonts.lato(
                                                          // Use Google Fonts here
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' || ',
                                                        style: TextStyle(
                                                          fontFamily: 'Lato',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: service
                                                            .serviceMarathiName,
                                                        style: GoogleFonts.lato(
                                                          // Use Google Fonts here
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (service
                                                  .products.isNotEmpty) ...[
                                                Icon(
                                                  service.isProductsVisible
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (service.serviceDescription
                                              .isNotEmpty) ...[
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Split the description into words
                                                List<String> words = service
                                                    .serviceDescription
                                                    .split(' ');
                                                bool hasMoreWords =
                                                    words.length > 10;
                                                String displayText;

                                                if (service.isExpanded) {
                                                  // Check service's own expanded state
                                                  displayText = service
                                                      .serviceDescription;
                                                } else {
                                                  displayText =
                                                      words.take(10).join(' ') +
                                                          (hasMoreWords
                                                              ? '...'
                                                              : '');
                                                }

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      displayText,
                                                      style: const TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                      maxLines:
                                                          service.isExpanded
                                                              ? null
                                                              : 1,
                                                      overflow: service
                                                              .isExpanded
                                                          ? TextOverflow.visible
                                                          : TextOverflow
                                                              .ellipsis,
                                                    ),
                                                    if (hasMoreWords &&
                                                        !service
                                                            .isExpanded) // Show Read more button
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            service.isExpanded =
                                                                true; // Expand text for this service
                                                          });
                                                        },
                                                        child: const Text(
                                                          "(Read more)",
                                                          style: TextStyle(
                                                              color: CustomColors
                                                                  .backgroundtext),
                                                        ),
                                                      ),
                                                    if (service
                                                        .isExpanded) // Show Read less button when expanded
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            service.isExpanded =
                                                                false; // Collapse text for this service
                                                          });
                                                        },
                                                        child: const Text(
                                                          "(Read less)",
                                                          style: TextStyle(
                                                              color: CustomColors
                                                                  .backgroundtext),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                            // const SizedBox(height: 8),
                                          ],
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Builder(
                                              builder: (context) {
                                                final screenWidth =
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width;

                                                return Row(
                                                  children: [
                                                    // Adjust font size based on the screen width

                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: Color(0xFFA1A1A1),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${service.serviceDuration} mins',
                                                      style: GoogleFonts.lato(
                                                        fontSize:
                                                            screenWidth < 350
                                                                ? 10
                                                                : 12,
                                                        color: const Color(
                                                            0xFFA1A1A1),
                                                      ),
                                                    ),
                                                    // const SizedBox(width: 10),
                                                    Text(
                                                      ' | ₹${service.price} | ',
                                                      style: GoogleFonts.lato(
                                                        fontSize:
                                                            screenWidth < 350
                                                                ? 15
                                                                : 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '${service.offerText}',
                                                      style: GoogleFonts.lato(
                                                        fontSize:
                                                            screenWidth < 350
                                                                ? 12
                                                                : 14,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (service.isProductsVisible &&
                                    service.products.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  ...service.products.map((product) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F0F0),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Color(0x00000008),
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image:
                                                    NetworkImage(product.image),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.productName,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '₹${product.price}',
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Service {
  final String serviceId;
  final String categoryId;
  final String subCategoryId;
  final String serviceName;
  final String serviceMarathiName;
  final String serviceDescription;
  final String categoryName;
  final String subCategoryName;
  final String categoryMarathiName;
  final String subCategoryMarathiName;
  final String serviceDuration;
  final String rewardPoints;
  final double price; // Change this to double
  final String offerText;
  final String image;
  final List<Product> products;
  bool isProductsVisible;
  bool isExpanded; // Add this line

  Service({
    required this.serviceId,
    required this.categoryId,
    required this.subCategoryId,
    required this.serviceName,
    required this.serviceMarathiName,
    required this.serviceDescription,
    required this.categoryName,
    required this.subCategoryName,
    required this.categoryMarathiName,
    required this.subCategoryMarathiName,
    required this.serviceDuration,
    required this.rewardPoints,
    required this.price,
    required this.offerText,
    required this.image,
    required this.products,
    this.isProductsVisible = false,
    this.isExpanded = false, // Initialize this
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List? ?? [];
    List<Product> productsList =
        productList.map((i) => Product.fromJson(i)).toList();

    return Service(
      serviceId: json['service_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      subCategoryId: json['sub_category_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceMarathiName: json['service_marathi_name'] ?? '',
      serviceDescription: json['service_description'] ?? '',
      categoryName: json['category_name'] ?? '',
      subCategoryName: json['sub_category_name'] ?? '',
      categoryMarathiName: json['category_marathi_name'] ?? '',
      subCategoryMarathiName: json['sub_category_marathi_name'] ?? '',
      serviceDuration: json['service_duration'] ?? '',
      rewardPoints: json['reward_points'] ?? '',
      price: (json['price'] as num).toDouble(), // Correct the type
      offerText: json['offer_text'] ?? '',
      image: json['image'] ?? '',
      products: productsList,
    );
  }
}

class ServiceResponse {
  final String status;
  final String message;
  final List<Service> data;

  ServiceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Service> serviceList = list.map((i) => Service.fromJson(i)).toList();

    return ServiceResponse(
      status: json['status'],
      message: json['message'],
      data: serviceList,
    );
  }
}
