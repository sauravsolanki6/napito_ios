import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'dart:convert';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class PackageSpecialServices extends StatefulWidget {
  @override
  _PackageSpecialServicesState createState() => _PackageSpecialServicesState();
}

class _PackageSpecialServicesState extends State<PackageSpecialServices> {
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
        storedServices =
            decodedData1; // Assuming you still want to store this data
      });

      decodedData1.forEach((key, service) {
        serviceIdsData1
            .add(service['serviceId'].toString()); // Collect service IDs
        if (service['isSpecial'] == "1") {
          ignoreServices.add(service['serviceId'].toString());
        }
      });
    }

    // Process the second stored data
    if (storedData2 != null) {
      final Map<String, dynamic> decodedData2 = jsonDecode(storedData2);

      setState(() {
        storedServices2 =
            decodedData2; // Store the second set of retrieved services
      });

      decodedData2.forEach((key, service) {
        serviceIdsData2
            .add(service['serviceId'].toString()); // Collect service IDs
        if (service['isSpecial'] == "1") {
          ignoreServices.add(service['serviceId'].toString());
        }
      });
    }

    // Check for common service IDs between data1 and data2
    commonServiceIds = serviceIdsData1
        .intersection(serviceIdsData2); // Update to assign to member variable
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
        storedServices3 = decodedData3; // Store the decoded data
      });

      // Access the 'services_array'
      List<dynamic> servicesArray = decodedData3['services_array'];

      // Iterate through the array
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
    } catch (e) {
      print('Error occurred: $e');
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
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookAppointmentPage(),
        //   ),
        // );
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
            onPressed: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BookAppointmentPage(),
              //   ),
              // );
              Navigator.pop(
                  context); // This will pop the current route off the navigator
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
                  Navigator.pop(context);
                  // Navigator.popUntil(context, (route) => route.isFirst);
                  // Navigate to the BookAppointmentPage
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => BookAppointmentPage(),
                  //   ),
                  // );
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

                  // Iterate through the selected services and format them for storage
                  for (var service in services) {
                    if (selectedServices.contains(service['service_id'])) {
                      combinedServices[service['service_id']] = {
                        'isSpecial': "1",
                        'serviceId': service['service_id'],
                        'categoryId': service[
                            'categoryId'], // Ensure this field is available
                        'serviceName':
                            service['service_name'], // Use the appropriate keys
                        'price': service['price'],
                        'serviceMarathiName': service['service_marathi_name'],
                        'isOfferApplied': "0", // Adjust as necessary
                        'appliedOfferId': "", // Adjust as necessary
                        'image': service['image'],
                        'duration':
                            service['service_duration'], // Adjust as necessary
                        'products':
                            [], // Add any other relevant fields as necessary
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

                    // Display stored services without checkboxes
                    ...storedServices.entries.map((entry) {
                      final service = entry.value;
                      final serviceId =
                          service['serviceId'].toString(); // Get service ID

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Stack(
                          // Use Stack to overlay blur effect
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
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
                                            '${service['serviceName']} || ${service['serviceMarathiName']}',
                                            style:
                                                latoStyle(18, FontWeight.bold),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Duration: ${service['duration']} mins',
                                            style: latoStyle(
                                                14, FontWeight.normal,
                                                fontStyle: FontStyle.italic),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '\₹${service['price']}',
                                            style:
                                                latoStyle(16, FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Check if the service ID is in commonServiceIds to apply blur effect
                            if (commonServiceIds.contains(serviceId))
                              Positioned.fill(
                                child: Stack(
                                  children: [
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 4.0,
                                        sigmaY: 4.0,
                                      ),
                                      child: Container(
                                        color: Colors.black.withOpacity(
                                            0), // Transparent overlay
                                      ),
                                    ),
                                    const Center(
                                      child: Text(
                                        'This is a duplicate Service package is considered',
                                        style: TextStyle(
                                          color: Colors
                                              .red, // Adjust the color to be visible
                                          fontSize:
                                              16, // Adjust the font size as needed
                                          fontWeight: FontWeight
                                              .bold, // Optional: make the text bold
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Display stored services from storedData2 without checkboxes
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 16),
                    //   child: Text(
                    //     'Stored Services',
                    //     style: latoStyle(20, FontWeight.bold),
                    //   ),
                    // ),
                    ...storedServices2.entries.map((entry) {
                      final service = entry.value;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              // Changed from Row to Column
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        service['image'],
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 80,
                                            width: 80,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons
                                                  .image_not_supported, // Use an appropriate icon here
                                              size: 40, // Size of the icon
                                              color: Colors
                                                  .grey, // Color of the icon
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${service['serviceName']} || ${service['serviceMarathiName']}',
                                            style:
                                                latoStyle(18, FontWeight.bold),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Duration: ${service['duration']} mins',
                                            style: latoStyle(
                                                14, FontWeight.normal,
                                                fontStyle: FontStyle.italic),
                                          ),
                                          // SizedBox(height: 5),
                                          // Text(
                                          //   '\₹${service['products'].isNotEmpty ? service['products'][0]['productPrice'] : '0.00'}',
                                          //   style:
                                          //       latoStyle(16, FontWeight.bold),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height:
                                        10), // Add space between the row and the text
                                Text(
                                  'This is a package service', // Added text here
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ), // Customize style as needed
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    Column(
                      children: (storedServices3['services_array'] ?? [])
                          .map<Widget>((service) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          service[
                                              'image'], // Ensure this key exists in your data
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[
                                                    200], // Background color for the placeholder
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons
                                                    .image_not_supported, // Icon to display on error
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
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
                                            Text(
                                              'Duration: ${service['service_duration']} mins',
                                              style: latoStyle(
                                                  14, FontWeight.normal,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '\₹${service['products'].isNotEmpty ? service['products'][0]['product_name'] : '0.00'}',
                                              style: latoStyle(
                                                  16, FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'This is a new package service',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Special Services',
                        style: latoStyle(20, FontWeight.bold),
                      ),
                    ),
                    // Display fetched services with round checkbox
                    // Inside the ListView where you display the special services
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
                                      color:
                                          const Color.fromARGB(29, 0, 87, 208),
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
                                                Text(
                                                  'Duration: ${service['service_duration']} mins',
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
