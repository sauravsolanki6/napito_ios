import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'dart:convert';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SpecialServices extends StatefulWidget {
  @override
  _SpecialServicesState createState() => _SpecialServicesState();
}

class _SpecialServicesState extends State<SpecialServices> {
  List<dynamic> services = []; // Fetched special services
  Map<String, dynamic> storedServices = {}; // Retrieved stored services
  bool isLoading = true; // To track loading state
  Set<String> selectedServices = Set<String>(); // Track selected services
  Map<String, dynamic> storedServices2 =
      {}; // To store second set of retrieved services
  Map<String, dynamic> storedServices3 =
      {}; // To store second set of retrieved services
  Set<String> commonServiceIds = {};
  @override
  void initState() {
    super.initState();
    fetchSpecialServices();
  }

  Future<void> fetchSpecialServices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';

    // Retrieve and print the stored service data
    final String? storedData1 = prefs.getString('selected_service_data1');
    final String? storedData2 = prefs.getString('selected_service_data');
    final String? storedData3 =
        prefs.getString('selected_package_data_add_package');
    print('Stored Data 1: $storedData1');
    print('Stored Data 2: $storedData2');
    print('Stored Data 3: $storedData3');
    List<String> ignoreServices = [];
    Set<String> serviceIdsData1 = {};
    Set<String> serviceIdsData2 = {};

    // Process the first stored data
    if (storedData1 != null) {
      final Map<String, dynamic> decodedData1 = jsonDecode(storedData1);

      setState(() {
        storedServices = decodedData1;
      });

      decodedData1.forEach((key, service) {
        serviceIdsData1.add(service['serviceId'].toString());
        if (service['isSpecial'] == "1") {
          ignoreServices.add(service['serviceId'].toString());
        }
      });
    }

    // Process the second stored data
    if (storedData2 != null) {
      final Map<String, dynamic> decodedData2 = jsonDecode(storedData2);

      setState(() {
        storedServices2 = decodedData2;
      });

      decodedData2.forEach((key, service) {
        serviceIdsData2.add(service['serviceId'].toString());
        // Add serviceId to ignoreServices based on criteria
        if (service['isSpecial'] == "1" ||
            service['is_service_available'] == "1") {
          ignoreServices.add(service['serviceId'].toString());
        }
      });
    }

    // Check for common service IDs between data1 and data2
    commonServiceIds = serviceIdsData1.intersection(serviceIdsData2);
    if (commonServiceIds.isNotEmpty) {
      print(
          'Common Service IDs between Data1 and Data2: ${commonServiceIds.join(', ')}');
    } else {
      print('No common Service IDs found between Data1 and Data2.');
    }

    // Process the third stored data
    if (storedData3 != null) {
      final Map<String, dynamic> decodedData3 = jsonDecode(storedData3);

      setState(() {
        storedServices3 = decodedData3;
      });

      List<dynamic> servicesArray = decodedData3['services_array'];
      for (var service in servicesArray) {
        if (service['is_special'] == "1") {
          ignoreServices.add(service['service_id'].toString());
        }
      }
    }

    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    final String url = '${Config.apiUrl}customer/store-special-services/';
    final Map<String, dynamic> body = {
      "salon_id": salonID,
      "branch_id": branchID,
      "customer_id": customerId,
      "ignore_services": ignoreServices,
    };

    print('Request URL: $url');
    print('Request Body: ${jsonEncode(body)}');
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          services = data;
          isLoading = false;
        });
      } else {
        print('Failed to load special services: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchSpecialServices",
        userId: customerId,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchPackages: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      throw Exception('Failed to fetch packages: $e');
    }
  }

  // Helper function to style text with Lato font
  TextStyle latoStyle(double fontSize, FontWeight fontWeight,
      {FontStyle fontStyle = FontStyle.normal}) {
    return GoogleFonts.lato(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookAppointmentPage(),
          ),
        );
        // Navigate to SDateTime when back button is pressed
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookAppointmentPage(),
        //   ),
        // );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          title: Text(
            'Special Services',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: CustomColors.backgroundLight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // Back button icon
            onPressed: () async {
              // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookAppointmentPage(),
                ),
              );
              // Navigator.of(context).maybePop();
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BookAppointmentPage(),
              //   ),
              // );
              // Navigator.pop(
              //     context); // This will pop the current route off the navigator
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: CustomColors.backgroundLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  // final prefs = await SharedPreferences.getInstance();
                  // Clear the preference
                  // await prefs.remove('selected_package_data_add_package');
                  // Navigator.pop(context);
                  // Navigator.popUntil(context, (route) => route.isFirst);
                  // Navigate to the BookAppointmentPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookAppointmentPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.backgroundtext,
                  backgroundColor: CustomColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: CustomColors.backgroundtext,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(135, 40),
                ),
                child: Text(
                  'Back',
                  style: latoStyle(15, FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create a map to hold the combined services
                  Map<String, dynamic> combinedServices =
                      Map.from(storedServices);

                  // Remove common services from storedServices
                  for (var commonId in commonServiceIds) {
                    combinedServices.remove(commonId);
                  }

                  // Add common services from storedServices2
                  for (var commonId in commonServiceIds) {
                    if (storedServices2.containsKey(commonId)) {
                      combinedServices[commonId] = storedServices2[commonId];
                    }
                  }

                  // Add all services from storedServices2 to combinedServices
                  combinedServices.addAll(storedServices2);

                  // Add selected services from `services` list to combinedServices
                  for (var service in services) {
                    if (selectedServices.contains(service['service_id'])) {
                      combinedServices[service['service_id']] = {
                        'isSpecial': "1",
                        'serviceId': service['service_id'],
                        'categoryId': service['categoryId'],
                        'serviceName': service['service_name'],
                        'price': service['price'],
                        'serviceMarathiName': service['service_marathi_name'],
                        'isOfferApplied': "0",
                        'appliedOfferId': "",
                        'image': service['image'],
                        'duration': service['service_duration'],
                        'products': [],
                      };
                    }
                  }

                  // Save the combined services to SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  String jsonData = jsonEncode(combinedServices);
                  await prefs.setString('selected_service_data1', jsonData);

                  // Print the updated stored data
                  print('Updated Selected Service Data JSON: $jsonData');

                  // Navigate to the next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SDateTime(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.backgroundtext,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(135, 40),
                ),
                child: Text(
                  'Next Step',
                  style: latoStyle(15, FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5, // Number of skeleton items to show
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              )
            : RefreshIndicator(
                onRefresh:
                    fetchSpecialServices, // Call the fetch method on refresh
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Header for Selected Services
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 16),
                    //   child: Text(
                    //     'Selected Services',
                    //     style: latoStyle(20, FontWeight.bold),
                    //   ),
                    // ),

                    // Display stored services without checkboxes //coomment from here
                    // ...storedServices.entries.map((entry) {
                    //   final service = entry.value;
                    //   final serviceId = service['serviceId'].toString();

                    //   return Container(
                    //     margin: EdgeInsets.symmetric(vertical: 8),
                    //     child: Stack(
                    //       children: [
                    //         // Service content container
                    //         Container(
                    //           decoration: BoxDecoration(
                    //             color: Colors.white,
                    //             border: Border.all(color: Colors.grey),
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //           child: Padding(
                    //             padding: const EdgeInsets.all(10),
                    //             child: Row(
                    //               children: [
                    //                 ClipRRect(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                   child: Image.network(
                    //                     service['image'],
                    //                     height: 80,
                    //                     width: 80,
                    //                     fit: BoxFit.cover,
                    //                   ),
                    //                 ),
                    //                 SizedBox(width: 10),
                    //                 Expanded(
                    //                   child: Column(
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.start,
                    //                     children: [
                    //                       Text(
                    //                         '${service['serviceName']} || ${service['serviceMarathiName']}',
                    //                         style:
                    //                             latoStyle(18, FontWeight.bold),
                    //                       ),
                    //                       SizedBox(height: 5),
                    //                       Text(
                    //                         'Duration: ${_formatDuration(service['duration'])}',
                    //                         style: latoStyle(
                    //                             14, FontWeight.normal,
                    //                             fontStyle: FontStyle.italic),
                    //                       ),
                    //                       SizedBox(height: 5),
                    //                       Text(
                    //                         '\₹${service['price']}',
                    //                         style:
                    //                             latoStyle(16, FontWeight.bold),
                    //                       ),
                    //                       SizedBox(height: 10),
                    //                       if (service['products'] != null &&
                    //                           service['products'].isNotEmpty)
                    //                         ...service['products']
                    //                             .map<Widget>((product) {
                    //                           return Text(
                    //                             '${product['productName']} - \₹${product['productPrice']}',
                    //                             style: latoStyle(
                    //                                 14, FontWeight.normal),
                    //                           );
                    //                         }).toList(),
                    //                       if (service['products'] == null ||
                    //                           service['products'].isEmpty)
                    //                         Text(
                    //                           'No products available',
                    //                           style: latoStyle(
                    //                               14, FontWeight.normal),
                    //                         ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),

                    //         // Conditional blur overlay if service is in commonServiceIds
                    //         // if (commonServiceIds.contains(serviceId))
                    //         if (commonServiceIds.contains(serviceId))
                    //           Positioned.fill(
                    //             child: ClipRRect(
                    //               borderRadius: BorderRadius.circular(10),
                    //               child: BackdropFilter(
                    //                 filter: ImageFilter.blur(
                    //                     sigmaX: 5.0, sigmaY: 5.0),
                    //                 child: Container(
                    //                   color: Colors.white.withOpacity(
                    //                       0.2), // Slight overlay color
                    //                   child: Center(
                    //                     child: Text(
                    //                       'You cannot select the same service more than once.',
                    //                       style: TextStyle(
                    //                         color: Colors.red,
                    //                         fontSize: 18,
                    //                         fontWeight: FontWeight.bold,
                    //                       ),
                    //                       textAlign: TextAlign.center,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //       ],
                    //     ),
                    //   );
                    // }),
                    // // Display stored services from storedData2 without checkboxes
                    // // Padding(
                    // //   padding: const EdgeInsets.symmetric(vertical: 16),
                    // //   child: Text(
                    // //     'Stored Services',
                    // //     style: latoStyle(20, FontWeight.bold),
                    // //   ),
                    // // ),
                    // ...storedServices2.entries.map((entry) {
                    //   final service = entry.value;
                    //   return Container(
                    //     margin: EdgeInsets.symmetric(vertical: 8),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         border: Border.all(color: Colors.grey),
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(10),
                    //         child: Column(
                    //           // Changed from Row to Column
                    //           children: [
                    //             Row(
                    //               children: [
                    //                 ClipRRect(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                   child: Image.network(
                    //                     service['image'],
                    //                     height: 80,
                    //                     width: 80,
                    //                     fit: BoxFit.cover,
                    //                     errorBuilder:
                    //                         (context, error, stackTrace) {
                    //                       return Container(
                    //                         height: 80,
                    //                         width: 80,
                    //                         alignment: Alignment.center,
                    //                         child: Icon(
                    //                           Icons
                    //                               .image_not_supported, // Use an appropriate icon here
                    //                           size: 40, // Size of the icon
                    //                           color: Colors
                    //                               .grey, // Color of the icon
                    //                         ),
                    //                       );
                    //                     },
                    //                   ),
                    //                 ),
                    //                 SizedBox(width: 10),
                    //                 Expanded(
                    //                   child: Column(
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.start,
                    //                     children: [
                    //                       Text(
                    //                         '${service['serviceName']} || ${service['serviceMarathiName']}',
                    //                         style:
                    //                             latoStyle(18, FontWeight.bold),
                    //                       ),
                    //                       SizedBox(height: 5),
                    //                       // Display the formatted duration
                    //                       Text(
                    //                         'Duration: ${_formatDuration(service['duration'])}',
                    //                         style: latoStyle(
                    //                             14, FontWeight.normal,
                    //                             fontStyle: FontStyle.italic),
                    //                       ),
                    //                       // Uncomment if you want to display the price of the first product if available
                    //                       // SizedBox(height: 5),
                    //                       // Text(
                    //                       //   '\₹${service['products'].isNotEmpty ? service['products'][0]['productPrice'] : '0.00'}',
                    //                       //   style: latoStyle(16, FontWeight.bold),
                    //                       // ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //             SizedBox(
                    //                 height:
                    //                     10), // Add space between the row and the text
                    //             Text(
                    //               'This is a package service', // Added text here
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //               ), // Customize style as needed
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   );
                    // }).toList(),
                    // Column(
                    //   children: (storedServices3['services_array'] ?? [])
                    //       .map<Widget>((service) {
                    //     return Container(
                    //       margin: EdgeInsets.symmetric(vertical: 8),
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.white,
                    //           border: Border.all(color: Colors.grey),
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(10),
                    //           child: Column(
                    //             children: [
                    //               Row(
                    //                 children: [
                    //                   ClipRRect(
                    //                     borderRadius: BorderRadius.circular(10),
                    //                     child: Image.network(
                    //                       service[
                    //                           'image'], // Ensure this key exists in your data
                    //                       height: 80,
                    //                       width: 80,
                    //                       fit: BoxFit.cover,
                    //                       errorBuilder:
                    //                           (context, error, stackTrace) {
                    //                         return Container(
                    //                           height: 80,
                    //                           width: 80,
                    //                           decoration: BoxDecoration(
                    //                             color: Colors.grey[
                    //                                 200], // Background color for the placeholder
                    //                             borderRadius:
                    //                                 BorderRadius.circular(10),
                    //                           ),
                    //                           child: Icon(
                    //                             Icons
                    //                                 .image_not_supported, // Icon to display on error
                    //                             color: Colors.grey,
                    //                           ),
                    //                         );
                    //                       },
                    //                     ),
                    //                   ),
                    //                   SizedBox(width: 10),
                    //                   Expanded(
                    //                     child: Column(
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.start,
                    //                       children: [
                    //                         Text(
                    //                           '${service['service_name']} || ${service['service_marathi_name']}',
                    //                           style: latoStyle(
                    //                               18, FontWeight.bold),
                    //                         ),
                    //                         SizedBox(height: 5),
                    //                         // Display the formatted duration
                    //                         Text(
                    //                           'Duration: ${_formatDuration(service['service_duration'])}',
                    //                           style: latoStyle(
                    //                               14, FontWeight.normal,
                    //                               fontStyle: FontStyle.italic),
                    //                         ),
                    //                         SizedBox(height: 5),
                    //                         // Display the product price if available
                    //                         Text(
                    //                           '\₹${service['products'].isNotEmpty ? service['products'][0]['product_name'] : '0.00'}',
                    //                           style: latoStyle(
                    //                               16, FontWeight.bold),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               SizedBox(height: 10),
                    //               Text(
                    //                 'This is a new package service',
                    //                 style: TextStyle(
                    //                     fontSize: 14,
                    //                     fontWeight: FontWeight.w500),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 16),
                    //   child: Text(
                    //     'Special Services',
                    //     style: latoStyle(20, FontWeight.bold),
                    //   ),
                    // ),
                    // Display fetched services with round checkbox
                    // Inside the ListView where you display the special services
                    services.isEmpty
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
                        : Column(
                            children: services.map((service) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Toggle the selection when the card is tapped
                                      if (selectedServices
                                          .contains(service['service_id'])) {
                                        selectedServices
                                            .remove(service['service_id']);
                                      } else {
                                        selectedServices
                                            .add(service['service_id']);
                                      }
                                      // Print selected services as JSON
                                      printSelectedServices();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          29, 248, 122, 243),
                                      border: Border.all(
                                          color: CustomColors.backgroundtext),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              service['image'],
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${service['service_name']} || ${service['service_marathi_name']}',
                                                  style: latoStyle(
                                                      18, FontWeight.bold),
                                                ),
                                                SizedBox(height: 5),
                                                // Display the formatted duration
                                                Text(
                                                  'Duration: ${_formatDuration(service['service_duration'])}',
                                                  style: latoStyle(
                                                      14, FontWeight.normal,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '\₹${service['price']}',
                                                  style: latoStyle(
                                                      16, FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Round Checkbox for special services selection
                                          Checkbox(
                                            value: selectedServices.contains(
                                                service['service_id']),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedServices.add(
                                                      service['service_id']);
                                                } else {
                                                  selectedServices.remove(
                                                      service['service_id']);
                                                }
                                                // Print selected services as JSON
                                                printSelectedServices();
                                              });
                                            },
                                            shape: CircleBorder(),
                                            activeColor:
                                                CustomColors.backgroundtext,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  void printSelectedServices() {
    // Create a list of selected services data
    List<Map<String, dynamic>> selectedServicesData = services
        .where((service) => selectedServices.contains(service['service_id']))
        .map((service) => {
              'service_id': service['service_id'],
              'service_name': service['service_name'],
              'service_marathi_name': service['service_marathi_name'],
              'duration': service['service_duration'],
              'price': service['price'],
              'image': service['image'],
            })
        .toList();

    // Convert the list to JSON
    String jsonData = jsonEncode(selectedServicesData);
    print('Selected Services JSON: $jsonData');
  }
}

String _formatDuration(dynamic duration) {
  // Convert the duration to an integer (assuming it's a string or dynamic)
  int durationInMinutes = int.tryParse(duration.toString()) ?? 0;

  final hours = durationInMinutes ~/ 60;
  final minutes = durationInMinutes % 60;

  if (hours > 0) {
    return '$hours hr ${minutes} mins';
  } else {
    return '$minutes mins';
  }
}
