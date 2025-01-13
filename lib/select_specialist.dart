import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:ms_salon_task/Payment/review_summary.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'homepage.dart'; // Import your homepage here

class SpecialistPage extends StatefulWidget {
  @override
  _SpecialistPageState createState() => _SpecialistPageState();
}

class _SpecialistPageState extends State<SpecialistPage> {
  List<Service> services = [];
  String? selectedSpecialist;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    // _fetchSpecialistSelection();
    // fetchStylistSelection(); // Call the API function
    // _printSavedJson(); // Print the saved JSON data
  }

  Future<void> _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve shared preferences data
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    // Check if customer ID is available
    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    // Retrieve selected service data from shared preferences
    // final String? selectedServiceDataJson1 =
    //     prefs.getString('selected_service_data');
    final String? selectedServiceDataJson2 =
        prefs.getString('selected_service_data1');
    List<String> serviceIds = [];

    // Parse the selected services from JSON
    // if (selectedServiceDataJson1 != null) {
    //   final Map<String, dynamic> services1 =
    //       jsonDecode(selectedServiceDataJson1);
    //   serviceIds.addAll(services1.values.map((service) {
    //     var serviceId = service['serviceId'];
    //     return serviceId.toString(); // Ensure serviceId is a string
    //   }));
    // }

    if (selectedServiceDataJson2 != null) {
      final Map<String, dynamic> services2 =
          jsonDecode(selectedServiceDataJson2);
      serviceIds.addAll(services2.values.map((service) {
        var serviceId = service['serviceId'];
        return serviceId.toString(); // Ensure serviceId is a string
      }));
    }

    // Retrieve and split the selected time slot
    final String? timeSlot = prefs.getString('selected_time_slot');
    if (timeSlot == null || !timeSlot.contains('-')) {
      throw Exception('Invalid time slot format');
    }

    final List<String> times = timeSlot.split('-');
    if (times.length != 2) {
      throw Exception('Invalid time slot format');
    }

    final String selectedSlotFrom = times[0].trim();
    final String selectedSlotTo = times[1].trim();

    // Retrieve the selected booking date
    final String? bookingDate = prefs.getString('selected_date');
    if (bookingDate == null || bookingDate.isEmpty) {
      throw Exception('No valid booking date found');
    }

    // Send a request to the API with the selected data
    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/service-stylists/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'selected_slot_from': selectedSlotFrom,
        'selected_slot_to': selectedSlotTo,
        'booking_date': bookingDate,
        'selected_services': serviceIds,
      }),
    );

    // Convert serviceId and stylistId to int safely using convertStringToInt
    int convertStringToInt(String value) {
      try {
        return int.parse(value);
      } catch (e) {
        print("Error converting string to int: $value");
        return 0; // Return default value if conversion fails
      }
    }

    // Check the response status
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> servicesData = responseData['data'];

      // Process the services and stylists
      setState(() {
        services = servicesData.map((serviceJson) {
          var service = Service.fromJson(serviceJson);

          // Convert 'stylist_id' to int
          var stylistIdString =
              serviceJson['selected_stylists']['stylist_id'].toString();
          int stylistId = convertStringToInt(stylistIdString);
          print('Converted Stylist ID: $stylistId');

          return service;
        }).toList();
      });
    } else {
      throw Exception('Failed to load specialists');
    }
  }

//the stylost showing in that
  // Future<void> _initializePreferences() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   final String? customerId1 = prefs.getString('customer_id');
  //   final String? customerId2 = prefs.getString('customer_id2');
  //   final String branchID = prefs.getString('branch_id') ?? '';
  //   final String salonID = prefs.getString('salon_id') ?? '';
  //   final String customerId = customerId1?.isNotEmpty == true
  //       ? customerId1!
  //       : customerId2?.isNotEmpty == true
  //           ? customerId2!
  //           : '';

  //   if (customerId.isEmpty) {
  //     throw Exception('No valid customer ID found');
  //   }

  //   final String? selectedServiceDataJson1 =
  //       prefs.getString('selected_service_data');
  //   final String? selectedServiceDataJson2 =
  //       prefs.getString('selected_service_data1');
  //   List<String> serviceIds = [];

  //   if (selectedServiceDataJson1 != null) {
  //     final Map<String, dynamic> services1 =
  //         jsonDecode(selectedServiceDataJson1);
  //     serviceIds.addAll(services1.values.map((service) {
  //       var serviceId = service['serviceId'];
  //       return serviceId.toString(); // Ensure serviceId is a string
  //     }));
  //   }

  //   if (selectedServiceDataJson2 != null) {
  //     final Map<String, dynamic> services2 =
  //         jsonDecode(selectedServiceDataJson2);
  //     serviceIds.addAll(services2.values.map((service) {
  //       var serviceId = service['serviceId'];
  //       return serviceId.toString(); // Ensure serviceId is a string
  //     }));
  //   }

  //   // Retrieve and parse 'selected_package_data_add_package' from SharedPreferences
  //   final String? packageDataJson =
  //       prefs.getString('selected_package_data_add_package');
  //   if (packageDataJson != null) {
  //     final Map<String, dynamic> packageData = jsonDecode(packageDataJson);
  //     final List<dynamic> servicesArray = packageData['services_array'];
  //     serviceIds.addAll(servicesArray.map((service) {
  //       var serviceId = service['service_id'];
  //       return serviceId.toString(); // Ensure serviceId is a string
  //     }));
  //   }

  //   if (serviceIds.isEmpty) {
  //     throw Exception('No valid services found');
  //   }

  //   final String? timeSlot = prefs.getString('selected_time_slot');
  //   if (timeSlot == null || !timeSlot.contains('-')) {
  //     throw Exception('Invalid time slot format');
  //   }

  //   final List<String> times = timeSlot.split('-');
  //   if (times.length != 2) {
  //     throw Exception('Invalid time slot format');
  //   }

  //   final String selectedSlotFrom = times[0].trim();
  //   final String selectedSlotTo = times[1].trim();

  //   final String? bookingDate = prefs.getString('selected_date');
  //   if (bookingDate == null || bookingDate.isEmpty) {
  //     throw Exception('No valid booking date found');
  //   }

  //   final response = await http.post(
  //     Uri.parse('${MyApp.apiUrl}customer/service-stylists/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       'salon_id': salonID,
  //       'branch_id': branchID,
  //       'customer_id': customerId,
  //       'selected_slot_from': selectedSlotFrom,
  //       'selected_slot_to': selectedSlotTo,
  //       'booking_date': bookingDate,
  //       'selected_services': serviceIds,
  //     }),
  //   );
  //   final Map<String, dynamic> requestBody = {
  //     'salon_id': salonID,
  //     'branch_id': branchID,
  //     'customer_id': customerId,
  //     'selected_slot_from': selectedSlotFrom,
  //     'selected_slot_to': selectedSlotTo,
  //     'booking_date': bookingDate,
  //     'selected_services': serviceIds,
  //   };
  //   print(
  //       'Request URL specialist: ${MyApp.apiUrl}customer/service-stylists/');
  //   print('Request Body specialists: ${jsonEncode(requestBody)}');

  //   print('Response status: ${response.statusCode}');
  //   print('Response body: ${response.body}');

  //   // Save response body to SharedPreferences
  //   if (response.statusCode == 200) {
  //     await prefs.setString(
  //         'response_body', response.body); // Save the response body as a string

  //     final Map<String, dynamic> responseData = jsonDecode(response.body);
  //     final List<dynamic> servicesData = responseData['data'];

  //     setState(() {
  //       services = servicesData.map((serviceJson) {
  //         var service = Service.fromJson(serviceJson);

  //         // Ensure 'selected_stylists' is treated as a Map and access properties correctly
  //         var selectedStylists = serviceJson['selected_stylists'];
  //         if (selectedStylists != null && selectedStylists is Map) {
  //           var stylistName = selectedStylists['stylist_name'];
  //           print('Selected Stylist: $stylistName');
  //         }

  //         // Handle 'available_stylists' as a list
  //         var availableStylists = serviceJson['available_stylists'];
  //         if (availableStylists != null && availableStylists is List) {
  //           availableStylists.forEach((stylist) {
  //             var stylistName = stylist['stylist_name'];
  //             print('Available Stylist: $stylistName');
  //           });
  //         }

  //         return service;
  //       }).toList();
  //     });
  //     await _saveStylistsToPreferences(); // Save stylist names to preferences
  //   } else {
  //     throw Exception('Failed to load data');
  //   }

  //   // Retrieve and print 'selected_package_data_add_package' from SharedPreferences
  //   final String? packageData =
  //       prefs.getString('selected_package_data_add_package');
  //   print('Selected Package Data: $packageData');
  // }

  // Future<void> _initializePreferences() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   final String? customerId1 = prefs.getString('customer_id');
  //   final String? customerId2 = prefs.getString('customer_id2');
  //   final String branchID = prefs.getString('branch_id') ?? '';
  //   final String salonID = prefs.getString('salon_id') ?? '';
  //   final String customerId = customerId1?.isNotEmpty == true
  //       ? customerId1!
  //       : customerId2?.isNotEmpty == true
  //           ? customerId2!
  //           : '';

  //   if (customerId.isEmpty) {
  //     throw Exception('No valid customer ID found');
  //   }

  //   final String? selectedServiceDataJson1 =
  //       prefs.getString('selected_service_data');
  //   final String? selectedServiceDataJson2 =
  //       prefs.getString('selected_service_data1');
  //   List<String> serviceIds = [];

  //   if (selectedServiceDataJson1 != null) {
  //     final Map<String, dynamic> services1 =
  //         jsonDecode(selectedServiceDataJson1);
  //     serviceIds.addAll(services1.values.map((service) {
  //       var serviceId = service['serviceId'];
  //       return serviceId.toString(); // Ensure serviceId is a string
  //     }));
  //   }

  //   if (selectedServiceDataJson2 != null) {
  //     final Map<String, dynamic> services2 =
  //         jsonDecode(selectedServiceDataJson2);
  //     serviceIds.addAll(services2.values.map((service) {
  //       var serviceId = service['serviceId'];
  //       return serviceId.toString(); // Ensure serviceId is a string
  //     }));
  //   }

  //   // Retrieve and parse 'selected_package_data_add_package' from SharedPreferences
  //   final String? packageDataJson =
  //       prefs.getString('selected_package_data_add_package');
  //   if (packageDataJson != null) {
  //     final Map<String, dynamic> packageData = jsonDecode(packageDataJson);
  //     final List<dynamic> servicesArray = packageData['services_array'];
  //     serviceIds.addAll(servicesArray.map((service) {
  //       var serviceId = service['service_id'];
  //       return serviceId.toString(); // Ensure serviceId is a string
  //     }));
  //   }

  //   if (serviceIds.isEmpty) {
  //     throw Exception('No valid services found');
  //   }

  //   final String? timeSlot = prefs.getString('selected_time_slot');
  //   if (timeSlot == null || !timeSlot.contains('-')) {
  //     throw Exception('Invalid time slot format');
  //   }

  //   final List<String> times = timeSlot.split('-');
  //   if (times.length != 2) {
  //     throw Exception('Invalid time slot format');
  //   }

  //   final String selectedSlotFrom = times[0].trim();
  //   final String selectedSlotTo = times[1].trim();

  //   final String? bookingDate = prefs.getString('selected_date');
  //   if (bookingDate == null || bookingDate.isEmpty) {
  //     throw Exception('No valid booking date found');
  //   }

  //   final response = await http.post(
  //     Uri.parse('${MyApp.apiUrl}customer/service-stylists/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       'salon_id': salonID,
  //       'branch_id': branchID,
  //       'customer_id': customerId,
  //       'selected_slot_from': selectedSlotFrom,
  //       'selected_slot_to': selectedSlotTo,
  //       'booking_date': bookingDate,
  //       'selected_services': serviceIds,
  //     }),
  //   );
  //   final Map<String, dynamic> requestBody = {
  //     'salon_id': salonID,
  //     'branch_id': branchID,
  //     'customer_id': customerId,
  //     'selected_slot_from': selectedSlotFrom,
  //     'selected_slot_to': selectedSlotTo,
  //     'booking_date': bookingDate,
  //     'selected_services': serviceIds,
  //   };
  //   final String url = '${MyApp.apiUrl}customer/service-stylists/';
  //   print('Request URL specialist: $url');
  //   print('Request Body specialists: ${jsonEncode(requestBody)}');

  //   print('Response status: ${response.statusCode}');
  //   print('Response body: ${response.body}');

  //   // Save response body to SharedPreferences
  //   if (response.statusCode == 200) {
  //     await prefs.setString(
  //         'response_body', response.body); // Save the response body as a string

  //     final Map<String, dynamic> responseData = jsonDecode(response.body);
  //     final List<dynamic> servicesData =
  //         responseData['data']['service_stylists_data'] as List<dynamic>? ?? [];

  //     setState(() {
  //       services = servicesData.map((serviceJson) {
  //         var service = Service.fromJson(serviceJson);
  //         // Ensure correct data is being processed
  //         var selectedStylists = serviceJson['selected_stylists'];
  //         if (selectedStylists != null && selectedStylists is Map) {
  //           // Handle selected_stylists properly
  //           var stylist = selectedStylists['stylist_name'];
  //           print('Selected Stylist: $stylist');
  //         }
  //         return service;
  //       }).toList();
  //     });
  //     await _saveStylistsToPreferences(); // Save stylist names to preferences
  //   } else {
  //     throw Exception('Failed to load data');
  //   }

  //   // Retrieve and print 'selected_package_data_add_package' from SharedPreferences
  //   final String? packageData =
  //       prefs.getString('selected_package_data_add_package');
  //   print('Selected Package Data: $packageData');
  // }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_date');
    await prefs.remove('selected_time_slot');
    await prefs.remove('selected_stylist_data_list');
  }

  Future<void> _saveStylistsToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Map to store stylist IDs separately
    Map<String, List<String>> stylistIdsMap = {};
    Map<String, List<String>> stylistsMap = {};

    for (var service in services) {
      List<String> selectedStylistIds = [];
      List<String> selectedStylists = service.availableStylists
          .where((stylist) => stylist.isSelected)
          .map((stylist) => stylist.stylistName)
          .toList();

      // Collect stylist IDs
      for (var stylist in service.availableStylists) {
        if (stylist.isSelected) {
          selectedStylistIds.add(stylist.stylistId);
        }
      }

      if (selectedStylistIds.isNotEmpty) {
        stylistIdsMap[service.serviceId] = selectedStylistIds;
        stylistsMap[service.serviceId] = selectedStylists;
      }
    }

    // Save stylist IDs and names separately
    await prefs.setString('selected_stylist_ids', jsonEncode(stylistIdsMap));
    await prefs.setString('selected_stylists', jsonEncode(stylistsMap));
  }

  Future<void> _updateStylistsPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Map to store stylist IDs separately
    Map<String, List<String>> stylistIdsMap = {};
    Map<String, List<String>> stylistsMap = {};

    for (var service in services) {
      List<String> selectedStylistIds = [];
      List<String> selectedStylists = service.availableStylists
          .where((stylist) => stylist.isSelected)
          .map((stylist) => stylist.stylistName)
          .toList();

      // Collect stylist IDs
      for (var stylist in service.availableStylists) {
        if (stylist.isSelected) {
          selectedStylistIds.add(stylist.stylistId);
        }
      }

      if (selectedStylistIds.isNotEmpty) {
        stylistIdsMap[service.serviceId] = selectedStylistIds;
        stylistsMap[service.serviceId] = selectedStylists;
      }
    }

    // Save stylist IDs and names separately
    await prefs.setString('selected_stylist_ids', jsonEncode(stylistIdsMap));
    await prefs.setString('selected_stylists', jsonEncode(stylistsMap));
  }

  // void _navigateToHome() async {
  //   await _clearPreferences(); // Clear date and time slot preferences
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => HomePage(
  //         title: '',
  //       ),
  //     ),
  //   );
  // }
  void _navigateToHome() async {
    // await _clearPreferences(); //
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stylist_service_data_stored');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SDateTime(),
      ),
    );
    // Navigator.of(context).pop();
  }

  void _showStylistsDialog(Service service) async {
    List<Stylist> tempStylists = List.from(service.availableStylists);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.all(0),
              title: Text('Select Stylist',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Container(
                constraints: BoxConstraints(maxHeight: 400),
                width: 300, // Fixed width for consistency
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: tempStylists.map((stylist) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                // Deselect all stylists
                                tempStylists
                                    .forEach((s) => s.isSelected = false);
                                // Select the tapped stylist
                                stylist.isSelected = true;
                                selectedSpecialist = stylist.stylistName;

                                // Store selected stylist info in shared preferences
                                _storeStylistSelection(stylist, service);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(stylist.profilePhoto),
                                  radius: 30,
                                ),
                                title: Text(stylist.stylistName),
                                subtitle: Text(stylist.stylistDesignation),
                                trailing: Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    value: stylist.isSelected,
                                    onChanged: (bool? newValue) {
                                      setDialogState(() {
                                        // Deselect all stylists
                                        tempStylists.forEach(
                                            (s) => s.isSelected = false);
                                        // Select the tapped stylist
                                        stylist.isSelected = newValue ?? false;
                                        selectedSpecialist = stylist.isSelected
                                            ? stylist.stylistName
                                            : null;

                                        // Store selected stylist info in shared preferences
                                        _storeStylistSelection(
                                            stylist, service);
                                      });
                                    },
                                    side: BorderSide(
                                        color: CustomColors.backgroundtext,
                                        width: 2),
                                    checkColor: Colors.white,
                                    activeColor: CustomColors.backgroundtext,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            // Save the selected stylist and service data in shared preferences as a JSON
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            // Create a map of selected stylist and service data
                            Map<String, String?> stylistServiceData = {
                              'selected_stylist':
                                  selectedSpecialist ?? 'No Stylist',
                              'selected_service':
                                  service.serviceName ?? 'No Service',
                            };

                            // Retrieve existing data from shared preferences (if any)
                            String? existingData =
                                prefs.getString('stylist_service_data_stored');
                            List<dynamic> stylistServiceList = [];

                            if (existingData != null) {
                              stylistServiceList = jsonDecode(existingData);
                            }

                            // Remove any existing data for the same service to avoid duplication
                            stylistServiceList.removeWhere((data) =>
                                data['selected_service'] ==
                                service.serviceName);

                            // Add the new data to the list (don't overwrite)
                            stylistServiceList.add(stylistServiceData);

                            // Store the updated list back in shared preferences as JSON
                            await prefs.setString('stylist_service_data_stored',
                                jsonEncode(stylistServiceList));

                            // Print the stored data for confirmation
                            print(
                                'Stored Data: ${jsonEncode(stylistServiceList)}');

                            // Update the original service with the modified stylist list
                            setState(() {
                              service.availableStylists = tempStylists;
                            });

                            _updateStylistsPreferences(); // Update preferences with new stylist data
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: CustomColors.backgroundtext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _storeStylistSelection(Stylist stylist, Service service) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Create a map of selected stylist's data
    Map<String, String> selectedStylistData = {
      'service_id': service.serviceId,
      'stylist_id': stylist.stylistId,
      'stylist_shift_id': stylist.stylistShiftId,
      'stylist_shift_type': stylist.stylistShiftType,
    };

    // Retrieve existing stylist data from SharedPreferences
    String? existingData = prefs.getString('selected_stylist_data_list');
    List<dynamic> stylistDataList = [];

    // If there is existing data, decode it into a list, else start with an empty list
    if (existingData != null) {
      stylistDataList = jsonDecode(existingData);
    }

    // Add the new stylist data to the list
    stylistDataList.add(selectedStylistData);

    // Store the updated list back in SharedPreferences as JSON
    await prefs.setString(
        'selected_stylist_data_list', jsonEncode(stylistDataList));

    // Print the updated list for debugging
    print('Updated Stylist Data Stored: ${jsonEncode(stylistDataList)}');

    // Clear the 'stylist_selection_response' shared preference
    await prefs.remove('stylist_selection_response');
    print('Cleared stylist_selection_response preference');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.05; // Adds 5% padding on left and right

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('stylist_service_data_stored');
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookAppointmentPage(),
        //   ),
        // );
        // Navigate to SDateTime when back button is pressed

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SDateTime(),
          ),
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          title: Text(
            'Select a Specialist',
            style: GoogleFonts.lato(), // Apply Google Fonts Lato
          ),
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // You can use any icon you want
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SDateTime(),
                ),
              );
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('stylist_service_data_stored');
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: 16.0),
          child: RefreshIndicator(
            onRefresh: _refreshServices,
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final selectedStylists = service.availableStylists
                    .where((stylist) => stylist.isSelected)
                    .map((stylist) => stylist.stylistName)
                    .join(', ');

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4, // Slightly increased elevation for emphasis
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    service.image,
                                    width: width *
                                        0.25, // Image width is 25% of screen
                                    height: width * 0.25,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.error,
                                          color: CustomColors.backgroundtext,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        8), // Space between image and button
                                SizedBox(
                                  width: width *
                                      0.25, // Button width matches image width
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showStylistsDialog(service);
                                    },
                                    child: Text(
                                      selectedStylists.isNotEmpty
                                          ? 'Edit Stylist'
                                          : 'Select Stylist',
                                      style: GoogleFonts.lato(),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          CustomColors.backgroundtext,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 12.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.serviceName,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0, // Slightly larger text
                                      ),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Marathi Name: ${service.serviceMarathiName}',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'From: ${service.formattedServiceFrom}',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'To: ${service.formattedServiceTo}',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  if (selectedStylists.isNotEmpty) ...[
                                    SizedBox(height: 12),
                                    Divider(), // Adds visual separation
                                    SizedBox(height: 8),
                                    Text(
                                      'Selected Stylists: $selectedStylists',
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: CustomColors.backgroundtext,
                                          fontSize:
                                              14.0, // Emphasized stylist info
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: CustomColors.backgroundPrimary,
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: 8.0, horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _navigateToHome,
                  child: Text(
                    'Back',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w500, // Set font weight to 500
                      color: CustomColors.backgroundtext,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CustomColors.backgroundtext, // Text color
                    backgroundColor: CustomColors
                        .backgroundPrimary, // Button background color
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      side: BorderSide(
                        color: CustomColors.backgroundtext, // Border color
                        width: 1.0, // Border thickness
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 135, // Set width to 135 pixels
                  height: 40, // Set height to 40 pixels
                  // margin: EdgeInsets.only(top: 1326, left: 258), // Set the top and left margins
                  child: ElevatedButton(
                    onPressed: _areAllServicesStylistsSelected()
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewSummary(),
                              ),
                            );
                          }
                        : null, // Disable the button if conditions are not met
                    child: Text(
                      'Next Step',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w500, // Set font weight to 500
                        color: Colors.white,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, // Text color
                      backgroundColor: _areAllServicesStylistsSelected()
                          ? CustomColors
                              .backgroundtext // Button background color if condition is true
                          : Colors
                              .grey, // Button background color if condition is false
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            6), // Set border radius to 6 pixels
                      ),
                      padding: EdgeInsets.zero, // Remove default padding
                      elevation: 0, // Remove elevation for flat look
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

  bool _areAllServicesStylistsSelected() {
    for (var service in services) {
      if (service.availableStylists.every((stylist) => !stylist.isSelected)) {
        // If there is any service with no selected stylist, return false
        return false;
      }
    }
    // All services have at least one selected stylist
    return true;
  }

// Define the refresh method
  Future<void> _refreshServices() async {
    _initializePreferences();

    await Future.delayed(Duration(seconds: 2));
  }
}

class Service {
  final String serviceId;
  final String serviceName;
  final String serviceMarathiName;
  final String image;
  final String serviceFrom;
  final String serviceTo;
  List<Stylist> availableStylists;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceMarathiName,
    required this.image,
    required this.serviceFrom,
    required this.serviceTo,
    required List<Stylist> availableStylists,
  }) : availableStylists = List.from(availableStylists);

  // Function to format date and time strings
  String formatDateTimeString(String dateTimeString) {
    try {
      final DateTime dateTime =
          DateTime.parse(dateTimeString); // Parse date-time string
      final DateFormat formatter =
          DateFormat('dd-MM-yyyy hh:mm a'); // Define 12-hour format with AM/PM
      return formatter.format(dateTime); // Format and return
    } catch (e) {
      return dateTimeString; // Return original string in case of error
    }
  }

  // Provide formatted date and time
  String get formattedServiceFrom => formatDateTimeString(serviceFrom);
  String get formattedServiceTo => formatDateTimeString(serviceTo);

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      serviceMarathiName: json['service_marathi_name'] as String,
      image: json['image'] as String,
      serviceFrom: json['service_from'] as String,
      serviceTo: json['service_to'] as String,
      availableStylists: (json['available_stylists'] as List<dynamic>)
          .map((e) => Stylist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Stylist {
  final String stylistId;
  final String stylistShiftId;
  final String stylistShiftType;
  final String stylistName;
  final String stylistDesignation;
  final String profilePhoto;
  bool isSelected;

  Stylist({
    required this.stylistId,
    required this.stylistShiftId,
    required this.stylistShiftType,
    required this.stylistName,
    required this.stylistDesignation,
    required this.profilePhoto,
    this.isSelected = false,
  });

  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      stylistId: json['stylist_id'] as String,
      stylistShiftId: json['stylist_shift_id'] as String,
      stylistShiftType: json['stylist_shift_type'] as String,
      stylistName: json['stylist_name'] as String,
      stylistDesignation: json['stylist_designation'] as String,
      profilePhoto: json['profile_photo'] as String,
      isSelected: (json['is_selected'] as String) == '1',
    );
  }
}



  // Future<void> fetchStylistSelection() async {
  //   try {
  //     // Retrieve SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();

  //     // Retrieve customer and salon information
  //     final String? customerId1 = prefs.getString('customer_id');
  //     final String? customerId2 = prefs.getString('customer_id2');
  //     final String branchID = prefs.getString('branch_id') ?? '';
  //     final String salonID = prefs.getString('salon_id') ?? '';
  //     final String customerId = customerId1?.isNotEmpty == true
  //         ? customerId1!
  //         : customerId2?.isNotEmpty == true
  //             ? customerId2!
  //             : '';

  //     if (customerId.isEmpty) {
  //       throw Exception('No valid customer ID found');
  //     }

  //     // Retrieve selected services
  //     final String? selectedServiceDataJson1 =
  //         prefs.getString('selected_service_data');
  //     final String? selectedServiceDataJson2 =
  //         prefs.getString('selected_service_data1');
  //     List<String> serviceIds = [];

  //     if (selectedServiceDataJson1 != null) {
  //       final Map<String, dynamic> services1 =
  //           jsonDecode(selectedServiceDataJson1);
  //       serviceIds.addAll(
  //           services1.values.map((service) => service['serviceId'] as String));
  //     }
  //     if (selectedServiceDataJson2 != null) {
  //       final Map<String, dynamic> services2 =
  //           jsonDecode(selectedServiceDataJson2);
  //       serviceIds.addAll(
  //           services2.values.map((service) => service['serviceId'] as String));
  //     }

  //     // Retrieve and parse 'selected_package_data_add_package' from SharedPreferences
  //     final String? packageDataJson =
  //         prefs.getString('selected_package_data_add_package');
  //     if (packageDataJson != null) {
  //       final Map<String, dynamic> packageData = jsonDecode(packageDataJson);
  //       final List<dynamic> servicesArray = packageData['services_array'];
  //       serviceIds.addAll(
  //           servicesArray.map((service) => service['service_id'] as String));
  //     }

  //     if (serviceIds.isEmpty) {
  //       throw Exception('No valid services found');
  //     }

  //     // Validate selected time slot
  //     final String? timeSlot = prefs.getString('selected_time_slot');
  //     if (timeSlot == null || !timeSlot.contains('-')) {
  //       throw Exception('Invalid time slot format');
  //     }

  //     final List<String> times = timeSlot.split('-');
  //     if (times.length != 2) {
  //       throw Exception('Invalid time slot format');
  //     }

  //     final String selectedSlotFrom = times[0].trim();
  //     final String selectedSlotTo = times[1].trim();

  //     // Validate booking date
  //     final String? bookingDate = prefs.getString('selected_date');
  //     if (bookingDate == null || bookingDate.isEmpty) {
  //       throw Exception('No valid booking date found');
  //     }

  //     // Prepare request body
  //     final Map<String, dynamic> requestBody = {
  //       'salon_id': salonID,
  //       'branch_id': branchID,
  //       'customer_id': customerId,
  //       'selected_slot_from': selectedSlotFrom,
  //       'selected_slot_to': selectedSlotTo,
  //       'booking_date': bookingDate,
  //       'selected_services': serviceIds,
  //     };

  //     // Make the API call
  //     final response = await http.post(
  //       Uri.parse('${MyApp.apiUrl}/customer/store-stylist-selection/'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(requestBody),
  //     );

  //     // Check response
  //     if (response.statusCode == 200) {
  //       // Successfully received response
  //       final responseData = json.decode(response.body);

  //       // Print the entire response to debug
  //       print('Response data: $responseData');

  //       // Safely access the data
  //       if (responseData['data'] != null &&
  //           responseData['data']['is_stylist_selection_page'] != null) {
  //         String isStylistSelectionPage =
  //             responseData['data']['is_stylist_selection_page'].toString();

  //         // Print the value for debugging
  //         print('is_stylist_selection_page: $isStylistSelectionPage');

  //         // Check the value of is_stylist_selection_page
  //         if (isStylistSelectionPage == "1") {
  //           // Stay on the page if is_stylist_selection_page is 1
  //           print('Navigating to SpecialistPage');
  //           // Add any additional logic for SpecialistPage here if needed
  //         } else {
  //           // Navigate to ReviewSummary if is_stylist_selection_page is 0
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => ReviewSummary(),
  //             ),
  //           );
  //         }
  //       } else {
  //         print(
  //             'Data or is_stylist_selection_page key is missing in the response.');
  //       }
  //     } else {
  //       // Handle error response
  //       print('Error: ${response.statusCode}, ${response.body}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error fetching data. Please try again.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An error occurred. Please try again.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _fetchSpecialistSelection() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();

  //     final String? customerId1 = prefs.getString('customer_id');
  //     final String? customerId2 = prefs.getString('customer_id2');
  //     final String branchID = prefs.getString('branch_id') ?? '';
  //     final String salonID = prefs.getString('salon_id') ?? '';
  //     final String customerId = customerId1?.isNotEmpty == true
  //         ? customerId1!
  //         : customerId2?.isNotEmpty == true
  //             ? customerId2!
  //             : '';

  //     if (customerId.isEmpty) {
  //       throw Exception('No valid customer ID found');
  //     }

  //     // API request body
  //     final Map<String, dynamic> requestBody = {
  //       "salon_id": salonID,
  //       "branch_id": branchID,
  //       "customer_id": customerId,
  //     };

  //     final response = await http.post(
  //       Uri.parse('${MyApp.apiUrl}/customer/store-stylist-selection/'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       // Successfully received response
  //       print('Response data: ${response.body}');
  //     } else {
  //       // Handle error response
  //       print('Error: ${response.statusCode}, ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //   }
  // }
