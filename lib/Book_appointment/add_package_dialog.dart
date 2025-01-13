import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Book_appointment/package_special_services.dart';
import 'package:ms_salon_task/Book_appointment/special_services.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'package:ms_salon_task/services/special_services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class PackageSelectionPage extends StatefulWidget {
  final VoidCallback onConfirm;

  PackageSelectionPage({required this.onConfirm});

  @override
  _PackageSelectionPageState createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  String? selectedPackageId;
  Map<String, dynamic> selectedPackageData = {};
  Map<String, Set<String>> selectedServices = {};
  Map<String, Set<String>> selectedProducts = {};

  late Future<List<dynamic>> packagesFuture;
  final Map<String, bool> _expandedPackages = {};

  @override
  void initState() {
    super.initState();
    packagesFuture = fetchPackages();
  }

  Future<List<dynamic>> fetchPackages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String _branchID = prefs.getString('branch_id') ?? '';
    final String _salonID = prefs.getString('salon_id') ?? '';

    final String _customerID = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (_customerID.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    final String apiUrl = '${MyApp.apiUrl}customer/store-packages/';
    final Map<String, String> requestBody = {
      'salon_id': _salonID,
      'branch_id': _branchID,
      'customer_id': _customerID,
    };
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'] as List<dynamic>;
      } else {
        throw Exception('Failed to load packages');
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty || branchID.isEmpty || salonID.isEmpty) {
        print('Missing required parameters.');
      }
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);
      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchPackages",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchPackages: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
      print('Error: $e');
      return [];
    }
  }

  Future<void> _refreshPackages() async {
    setState(() {
      packagesFuture = fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalMargin = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          title: Text(
            'Buy Package',
            style: GoogleFonts.lato(
              color: Colors.black, // Set the color of the text
            ),
          ),
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0, // Removes the shadow
        ),
        body: RefreshIndicator(
          onRefresh: _refreshPackages,
          child: FutureBuilder<List<dynamic>>(
            future: packagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  itemCount: 5, // Number of skeletons to show
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        // elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                          leading: CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Colors.grey[300],
                          ),
                          title: Container(
                            width: double.infinity,
                            height: 16.0,
                            color: Colors.grey[300],
                          ),
                          subtitle: Container(
                            width: double.infinity,
                            height: 14.0,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Failed to load packages: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red)),
                ));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No packages available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54)),
                ));
              } else {
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  children: snapshot.data!.map<Widget>((package) {
                    bool isPackageSelected =
                        selectedPackageId == package['package_id'];
                    bool isExpanded =
                        _expandedPackages[package['package_id']] ?? false;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: CustomColors.backgroundLight,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              setState(() {
                                if (selectedPackageId ==
                                    package['package_id']) {
                                  selectedPackageId = null;
                                  selectedPackageData = {};
                                  selectedServices.clear();
                                  selectedProducts.clear();
                                } else {
                                  selectedPackageId = package['package_id'];
                                  selectedPackageData = package;
                                  selectedServices.clear();
                                  selectedProducts.clear();

                                  for (var service
                                      in package['services_array']) {
                                    selectedServices[package['package_id']] = {
                                      service['service_id']
                                    };

                                    for (var product in service['products']) {
                                      if (selectedProducts[
                                              service['service_id']] ==
                                          null) {
                                        selectedProducts[
                                            service['service_id']] = {};
                                      }
                                      selectedProducts[service['service_id']]!
                                          .add(product['product_id']);
                                    }
                                  }
                                }
                              });
                            },
                            leading: ClipOval(
                              child: package['image'] != null &&
                                      package['image'].isNotEmpty
                                  ? Image.network(
                                      package['image'],
                                      width: 60.0,
                                      height: 60.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      size: 60.0,
                                      color: Colors.grey,
                                    ),
                            ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Custom round box for selection
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedPackageId ==
                                          package['package_id']) {
                                        selectedPackageId = null;
                                        selectedPackageData = {};
                                        selectedServices.clear();
                                        selectedProducts.clear();
                                      } else {
                                        selectedPackageId =
                                            package['package_id'];
                                        selectedPackageData = package;
                                        selectedServices.clear();
                                        selectedProducts.clear();

                                        for (var service
                                            in package['services_array']) {
                                          selectedServices[
                                              package['package_id']] = {
                                            service['service_id']
                                          };

                                          for (var product
                                              in service['products']) {
                                            if (selectedProducts[
                                                    service['service_id']] ==
                                                null) {
                                              selectedProducts[
                                                  service['service_id']] = {};
                                            }
                                            selectedProducts[
                                                    service['service_id']]!
                                                .add(product['product_id']);
                                          }
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: BoxDecoration(
                                      color: selectedPackageId ==
                                              package['package_id']
                                          ? Color(
                                              0xFF0056D0) // Fill color when selected
                                          : Colors
                                              .transparent, // Transparent when not selected
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: CustomColors
                                            .backgroundtext, // Border color
                                        width: 2.0,
                                      ),
                                    ),
                                    child: selectedPackageId ==
                                            package['package_id']
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16.0,
                                          )
                                        : null, // Show check icon when selected
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    package['package_name'],
                                    style: GoogleFonts.lato(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '₹${package['price']}',
                                  style: GoogleFonts.lato(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.backgroundtext,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onPressed: () {
                                setState(() {
                                  _expandedPackages[package['package_id']] =
                                      !isExpanded;
                                });
                              },
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: isExpanded
                                ? package['services_array'].length * 80.0
                                : 0,
                            child: ListView(
                              shrinkWrap: true,
                              children: package['services_array']
                                  .map<Widget>((service) {
                                return ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  title: Text(
                                    service['service_name'],
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  subtitle: Text(
                                    '(${service['service_duration']} mins)',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.grey),
                                  ),
                                  leading: ClipOval(
                                    child: service['image'] != null &&
                                            service['image'].isNotEmpty
                                        ? Image.network(
                                            service['image'],
                                            width: 50.0,
                                            height: 50.0,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                size: 50.0,
                                                color: Colors.grey,
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.image,
                                            size: 50.0,
                                            color: Colors.grey,
                                          ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 135, // Width in logical pixels
                  height: 40, // Height in logical pixels
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: CustomColors.backgroundtext, // Border color
                        width: 1.0, // Border width
                      ),
                      padding:
                          EdgeInsets.zero, // No padding to fit the container
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6.0), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.backgroundtext, // Text color
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 0), // Gap between buttons
                Spacer(),
                Container(
                  width: 135, // Width in logical pixels
                  height: 40, // Height in logical pixels
                  child: ElevatedButton(
                    onPressed: selectedPackageId != null &&
                            selectedPackageData.isNotEmpty
                        ? () async {
                            Navigator.of(context).pop();

                            final selectedPackage = {
                              'package_id': selectedPackageData['package_id'],
                              'package_name':
                                  selectedPackageData['package_name'],
                              'price': selectedPackageData['price'],
                              'services_array':
                                  selectedPackageData['services_array']
                                      .map((service) {
                                return {
                                  ...service,
                                  'products':
                                      service['products'].where((product) {
                                    return selectedProducts[
                                                service['service_id']]
                                            ?.contains(product['product_id']) ??
                                        false;
                                  }).toList(),
                                };
                              }).toList(),
                            };

                            print(
                                'Selected Package Data: ${jsonEncode(selectedPackage)}');
                            print('Selected Package ID: $selectedPackageId');
                            print(
                                'Selected Service IDs: ${selectedServices[selectedPackageId]?.join(', ')}');
                            print(
                                'Selected Product IDs: ${selectedProducts.values.expand((x) => x).join(', ')}');

                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString(
                                'selected_package_data_add_package',
                                jsonEncode(selectedPackage));
                            // await prefs.setString('selected_service_data1',
                            //     jsonEncode(selectedPackage));
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => SpecialServicesPage(),
                            //   ),
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PackageSpecialServices(),
                              ),
                            );
                          }
                        : null, // Disable the button if no package is selected
                    style: ElevatedButton.styleFrom(
                      foregroundColor: CustomColors.backgroundtext,
                      backgroundColor:
                          CustomColors.backgroundtext, // Text color
                      // side: BorderSide(
                      //   color: CustomColors.backgroundtext, // Border color
                      //   width: 2.0, // Border width
                      // ),
                      padding:
                          EdgeInsets.zero, // No padding to fit the container
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6.0), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Next Step',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: selectedPackageId != null &&
                                selectedPackageData.isNotEmpty
                            ? CustomColors
                                .backgroundLight // Text color for elevated button
                            : Colors
                                .grey, // Change text color to grey if disabled
                      ),
                    ),
                  ),
                ),
//                 Container(
//                   width: 135, // Width in logical pixels
//                   height: 40, // Height in logical pixels
//                   child: ElevatedButton(
//                     onPressed: selectedPackageId != null &&
//                             selectedPackageData.isNotEmpty
//                         ? () async {
//                             // Navigator.of(context).pop();

//                             final selectedPackage = {
//                               'package_id': selectedPackageData['package_id'],
//                               'package_name':
//                                   selectedPackageData['package_name'],
//                               'price': selectedPackageData['price'],
//                               'services_array':
//                                   selectedPackageData['services_array']
//                                       .map((service) {
//                                 return {
//                                   ...service,
//                                   'products':
//                                       service['products'].where((product) {
//                                     return selectedProducts[
//                                                 service['service_id']]
//                                             ?.contains(product['product_id']) ??
//                                         false;
//                                   }).toList(),
//                                 };
//                               }).toList(),
//                             };

//                             print(
//                                 'Selected Package Data: ${jsonEncode(selectedPackage)}');

//                             final SharedPreferences prefs =
//                                 await SharedPreferences.getInstance();

// // Retrieve existing data from shared preferences
//                             final existingDataString =
//                                 prefs.getString('selected_service_data1');
//                             List<dynamic> existingData =
//                                 existingDataString != null
//                                     ? jsonDecode(existingDataString) is List
//                                         ? jsonDecode(existingDataString)
//                                         : [
//                                             jsonDecode(existingDataString)
//                                           ] // Ensure it's a list
//                                     : [];

// // Append the new data to the existing list
//                             existingData.add(selectedPackage);

// // Save the updated list back to shared preferences
//                             await prefs.setString('selected_service_data1',
//                                 jsonEncode(existingData));

//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => SpecialServices(),
//                               ),
//                             );
//                           }
//                         : null, // Disable the button if no package is selected
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: CustomColors.backgroundtext,
//                       backgroundColor:
//                           CustomColors.backgroundtext, // Text color
//                       padding:
//                           EdgeInsets.zero, // No padding to fit the container
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(6.0), // Rounded corners
//                       ),
//                     ),
//                     child: Text(
//                       'Next Step',
//                       style: TextStyle(
//                         fontSize: 15.0,
//                         fontWeight: FontWeight.w500,
//                         color: selectedPackageId != null &&
//                                 selectedPackageData.isNotEmpty
//                             ? CustomColors.backgroundLight
//                             : Colors
//                                 .grey, // Change text color to grey if disabled
//                       ),
//                     ),
//                   ),
//                 ),
              ],
            ),
          ),
        ));
  }
}
