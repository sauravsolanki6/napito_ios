import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages1.dart';
import 'package:ms_salon_task/offers%20and%20membership/package_buy_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'store_package_controller.dart';

class StorePackagePage extends StatefulWidget {
  @override
  _StorePackagePageState createState() => _StorePackagePageState();
}

class _StorePackagePageState extends State<StorePackagePage> {
  late Future<List<Package>> _packagesFuture;
  Map<String, bool> _expandedStates = {};
  Map<String, bool> _selectedPackages = {};
  String? _selectedPackageId;

  final StorePackageController _controller = StorePackageController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _packagesFuture = _initializeData();
  }

  Future<List<Package>> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve values from SharedPreferences
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');
    final branchId = prefs.getString('branch_id') ?? '';
    final salonId = prefs.getString('salon_id') ?? '';

    // Print the retrieved values
    print('Customer ID 1: $customerId1');
    print('Customer ID 2: $customerId2');
    print('Branch ID: $branchId');
    print('Salon ID: $salonId');

    // Determine the customer ID to use
    final customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    // Print the final selected customer ID
    print('Selected Customer ID: $customerId');

    // Fetch and return the packages
    return _controller.fetchPackages(salonId, branchId, customerId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _packagesFuture = _initializeData();
    });
  }

  void _toggleExpansion(String packageId) {
    setState(() {
      _expandedStates[packageId] = !(_expandedStates[packageId] ?? false);
    });

    print('Package ID: $packageId');
  }

  void _toggleSelection(String packageId, bool isSelected) async {
    setState(() {
      // Deselect all packages first
      _selectedPackages.updateAll((key, value) => false);

      // Then select the new package
      _selectedPackages[packageId] = isSelected;
      if (isSelected) {
        _selectedPackageId = packageId; // Set the selected package ID

        // Find the selected package details
        final selectedPackage = _packagesFuture.then((packages) =>
            packages.firstWhere((package) => package.packageId == packageId));

        selectedPackage.then((package) async {
          // Print the package details
          print('Selected Package Details:');
          print('ID: ${package.packageId}');
          print('Name: ${package.packageName}');
          print('Price: ${package.price}');
          print('Description: ${package.description}');
          print('Services:');
          for (var service in package.services) {
            print(' - ${service.serviceName} (${service.duration} mins)');
          }

          // Save package details in Shared Preferences
          final prefs = await SharedPreferences.getInstance();
          final packageDetails = {
            'gstRate': package.gstRate,
            'gstAmount': package.gstAmount,
            'isGstApplicable': package.isGstApplicable,
            'id': package.packageId,
            'name': package.packageName,
            'nameMarathi': package.packageNameMarathi,
            'price': package.price,
            'originalPrice': package.originalPrice,
            'discountText': package.discountText,
            'discountedPrice': package.discountedPrice,
            'description': package.description,
            'image': package.image,
            'durationText': package.durationText,
            'services': package.services
                .map((service) => {
                      'serviceId': service
                          .serviceId, // Assuming you have a serviceId in ServiceInPackage
                      'serviceName': service.serviceName,
                      'serviceMarathiName': service.serviceMarathiName,
                      'image': service.image,
                      'products': service.products
                          .map((product) => {
                                'productId': product.productId,
                                'productName': product.productName,
                                'productImage': product.image,
                                // Include any other product details you need
                              })
                          .toList(),
                    })
                .toList(),
          };

          // Save the package details
          try {
            await prefs.setString(
                'selectedPackageforbuy', json.encode(packageDetails));
            print(
                'Package details saved in Shared Preferences: ${packageDetails}');

            // Verify if saved correctly by reading it back
            final savedPackageDetails =
                prefs.getString('selectedPackageforbuy');
            if (savedPackageDetails != null) {
              final decodedDetails = json.decode(savedPackageDetails);
              print('Saved Package Details Confirmed: $decodedDetails');
            } else {
              print('No package details found in Shared Preferences.');
            }
          } catch (e) {
            print('Error saving package details: $e');
          }
        });
      } else {
        _selectedPackageId = null; // Deselect if it's unchecked
      }
    });
  }

  Future<void> _buyNow() async {
    if (_selectedPackageId == null) {
      print('No package selected');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Retrieve customer IDs from SharedPreferences
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchId = prefs.getString('branch_id') ?? '';
    final String salonId = prefs.getString('salon_id') ?? '';

    // Determine the valid customer ID
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      print('No valid customer ID found');
      return;
    }

    // Call the method to buy the package
    final responseMessage = await _controller.buyPackage(
        salonId, branchId, customerId, _selectedPackageId!);

    // Show the response message in a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(responseMessage),
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate to CustomerPackages1 page after a successful purchase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CustomerPackages1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth * 0.05; // 5% of screen width
    final pagePadding = screenWidth * 0.05; // 5% padding around the page

    return WillPopScope(
      onWillPop: () async {
        // This will navigate back to the first occurrence of `HomePage` in the stack
        // Navigator.of(context).pop((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerPackages1()),
          //  builder: (context) => StorePackagePage()),
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: CustomColors.backgroundLight,
          title: Text(
            'Buy Packages',
            style: GoogleFonts.lato(
                // You can adjust the font size and weight as needed
                // fontSize: 20,
                // fontWeight: FontWeight.bold,
                ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: CustomColors
                    .backgroundtext), // Customize the color if needed
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerPackages1()),
                //  builder: (context) => StorePackagePage()),
              );
              // Navigator.pop(
              //     context); // This will take the user back to the previous screen
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: pagePadding), // Apply padding to the whole page
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            child: FutureBuilder<List<Package>>(
              future: _packagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5, // Number of shimmer placeholders
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          height: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
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
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  final packages = snapshot.data!;

                  return ListView.builder(
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      final isExpanded =
                          _expandedStates[package.packageId] ?? false;
                      final isSelected =
                          _selectedPackages[package.packageId] ?? false;

                      return GestureDetector(
                        onTap: () => _toggleExpansion(package.packageId),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          // elevation: 2,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: horizontalMargin /
                                            2), // Center alignment
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Image.network(
                                        package.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Icon(Icons
                                                .image_not_supported_outlined),
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(8.0),
                                      title: Text(
                                        // package.packageName,
                                        '${package.packageName} \nDiscounted Price : ₹${package.discountedPrice}',
                                        style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                            fontSize:
                                                16, // Adjust the font size as needed
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Actual Price: ₹${package.originalPrice}\nDuration: ${package.durationText}',
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            fontSize:
                                                14, // Adjust the font size as needed
                                            fontWeight: FontWeight.w400,
                                            color: Colors
                                                .black54, // Optional: change color for better visibility
                                          ),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              _toggleSelection(
                                                  package.packageId,
                                                  value ?? false);
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: CustomColors.backgroundtext,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.description,
                                        style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                            fontSize:
                                                16, // Adjust the font size as needed
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text('Services:'),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            package.services.map((service) {
                                          return ListTile(
                                            contentPadding: EdgeInsets.all(0),
                                            leading: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: horizontalMargin /
                                                      2), // Center alignment
                                              child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Image.network(
                                                  service.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Icon(Icons.error),
                                                  loadingBuilder: (context,
                                                      child, progress) {
                                                    if (progress == null) {
                                                      return child;
                                                    } else {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              service.serviceName,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      16, // Adjust the font size as needed
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            subtitle: Text(
                                              service.serviceMarathiName,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      14, // Adjust the font size as needed
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors
                                                      .black54, // Optional: change color for better visibility
                                                ),
                                              ),
                                            ),
                                            trailing: Text(
                                              '${service.duration} mins',
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      14, // Adjust the font size as needed
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors
                                                      .black, // Optional: change color for better visibility
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
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
        ),
        bottomNavigationBar: _selectedPackageId != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  // onPressed: _buyNow,
                  onPressed: () {
                    // Navigate to PackageBuyPayment page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PackageDetailsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: CustomColors.backgroundtext, // Text color
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Buy Now',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
