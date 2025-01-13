import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/main.dart';
import 'package:ms_salon_task/offers%20and%20membership/store_packages.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// Color Theme
const Color primaryColor = CustomColors.backgroundtext;
const Color backgroundColor = Colors.white;
const Color cardColor = Colors.white;
const Color textColorPrimary = Colors.black;
const Color textColorSecondary = Colors.grey;

// Model for Service
class Service {
  final String serviceName;
  final String image;
  final List<Product> products;

  Service({
    required this.serviceName,
    required this.image,
    required this.products,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List? ?? [];
    List<Product> products =
        productList.map((i) => Product.fromJson(i)).toList();

    return Service(
      serviceName: json['service_name'] ?? '',
      image: json['image'] ?? '',
      products: products,
    );
  }
}

// Model for Product
class Product {
  final String productName;
  final String image;

  Product({
    required this.productName,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class CustomerPackagesPage extends StatefulWidget {
  @override
  _CustomerPackagesPageState createState() => _CustomerPackagesPageState();
}

class _CustomerPackagesPageState extends State<CustomerPackagesPage> {
  List<Package> _packages = [];
  Map<int, String?> _selectedProduct = {};
  Map<int, bool> _serviceVisibility = {}; // To manage service visibility

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

    final url = '${MyApp.apiUrl}customer/packages/';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerID,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          List<dynamic> packagesJson = data['data'] as List? ?? [];
          setState(() {
            _packages =
                packagesJson.map((json) => Package.fromJson(json)).toList();
            _serviceVisibility = {
              for (var i = 0; i < _packages.length; i++) i: false
            }; // Initialize service visibility
          });
        } else {
          print('Failed to load data. Message: ${data['message']}');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _refreshData() async {
    await _fetchData();
  }

  void _toggleServicesVisibility(int packageIndex) {
    setState(() {
      _serviceVisibility[packageIndex] =
          !(_serviceVisibility[packageIndex] ?? false);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Packages', style: TextStyle(color: Colors.black)),
        backgroundColor: CustomColors.backgroundLight,
        iconTheme: IconThemeData(color: primaryColor),
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: _onBuyPackagesPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor, // Set the text color to white
              padding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            child: Text(
              'BUY PACKAGES',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8), // Add some spacing between button and edge
        ],
      ),
      backgroundColor: CustomColors.backgroundPrimary,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _packages.isEmpty
            ? _buildNoPackagesMessage() // Show message if no packages are available
            : ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  return Card(
                    elevation: 4.0,
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        package.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8.0)),
                                child: Image.network(
                                  package.image,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image,
                                          color: Colors.grey[600]),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 120,
                                color: Colors.grey[200],
                                child:
                                    Icon(Icons.image, color: Colors.grey[600]),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            package.packageName,
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            package.description ?? '',
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Display package start and end dates with minimal highlight
                        if (package.packageStart != null &&
                            package.packageEnd != null)
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[50], // Light blue background
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'Valid from ${package.packageStart} to ${package.packageEnd}',
                              style: TextStyle(
                                color:
                                    Colors.blue[900], // Darker blue text color
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: () => _toggleServicesVisibility(index),
                          child: Text(
                            _serviceVisibility[index]!
                                ? 'Hide Services'
                                : 'Show Services',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                        if (_serviceVisibility[index] ?? false)
                          Column(
                            children: package.services.map((service) {
                              return ExpansionTile(
                                title: Text(service.serviceName,
                                    style: TextStyle(color: primaryColor)),
                                leading: service.image.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(service.image),
                                      )
                                    : CircleAvatar(
                                        child: Icon(Icons.star_border,
                                            color: primaryColor)),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      hint: Text('Show Products',
                                          style: TextStyle(
                                              color: textColorPrimary)),
                                      value: _selectedProduct[
                                          package.services.indexOf(service)],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedProduct[package.services
                                              .indexOf(service)] = newValue;
                                        });
                                      },
                                      items: service.products.map((product) {
                                        return DropdownMenuItem<String>(
                                          value: product.productName,
                                          child: Text(product.productName),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNoPackagesMessage() {
    return Center(
      child: Text(
        'No packages Available',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: textColorSecondary,
        ),
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: textColorSecondary,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4.0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Model for Package
// Model for Package
class Package {
  final String packageName;
  final String description;
  final String image;
  final List<Service> services;
  final String? packageStart; // Add this field
  final String? packageEnd; // Add this field

  Package({
    required this.packageName,
    required this.description,
    required this.image,
    required this.services,
    this.packageStart, // Initialize in constructor
    this.packageEnd, // Initialize in constructor
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    var serviceList = json['services'] as List? ?? [];
    List<Service> services =
        serviceList.map((i) => Service.fromJson(i)).toList();

    return Package(
      packageName: json['package_name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      services: services,
      packageStart: json['package_start'], // Parse from JSON
      packageEnd: json['package_end'], // Parse from JSON
    );
  }
}
