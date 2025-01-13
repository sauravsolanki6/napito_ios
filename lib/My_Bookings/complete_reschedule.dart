import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_calender.dart';
import 'package:ms_salon_task/Payment/review_summary.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompleteReschedule extends StatefulWidget {
  @override
  _CompleteRescheduleState createState() => _CompleteRescheduleState();
}

class _CompleteRescheduleState extends State<CompleteReschedule> {
  List<Service> services = [];
  String? selectedSpecialist;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    // _printSavedJson(); // Print the saved JSON data
  }

  Future<void> rescheduleAppointment() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? salonID = prefs.getString('salon_id');
      final String? branchID = prefs.getString('branch_id');
      final String? customerId1 = prefs.getString('customer_id');
      final String? customerId2 = prefs.getString('customer_id2');
      final String? timeSlot = prefs.getString('selected_time_slot');

      final String customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty ||
          salonID == null ||
          branchID == null ||
          timeSlot == null) {
        throw Exception('Missing required data');
      }

      // Extract time slot details
      final List<String> times = timeSlot.split('-');
      if (times.length != 2) {
        throw Exception('Invalid time slot format');
      }

      final String selectedSlotFrom = times[0].trim();
      final String selectedSlotTo = times[1].trim();

      // Retrieve and parse 'selected_booking_json' from SharedPreferences
      final String? bookingJson = prefs.getString('selected_booking_json');
      print('selected_booking_json $bookingJson');
      if (bookingJson == null) {
        throw Exception('No booking data found in SharedPreferences');
      }

      final Map<String, dynamic> bookingData = jsonDecode(bookingJson);

      // Extract booking_id and services data
      final String bookingId = bookingData['booking_id'] ?? '';
      final List<dynamic> servicesData = bookingData['services'] ?? [];

      // Retrieve and parse 'response_body' from SharedPreferences
      final String? responseBody = prefs.getString('response_body');
      if (responseBody == null) {
        throw Exception('No response data found in SharedPreferences');
      }

      // final Map<String, dynamic> responseData = jsonDecode(responseBody);
      // final List<dynamic> servicesResponseData =
      //     responseData['data']['service_stylists_data'] as List<dynamic>? ?? [];
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      final List<dynamic> servicesResponseData = responseData['data'] ?? [];
      // Prepare reschedule details
      final List<Map<String, dynamic>> rescheduleDetails =
          servicesResponseData.expand((serviceJson) {
        final service = serviceJson as Map<String, dynamic>;
        final List<dynamic> stylists = service['available_stylists'] ?? [];
        final String serviceFrom = service['service_from'] ?? '';
        final String serviceTo = service['service_to'] ?? '';
        final String? rescheduleDetailsJson =
            prefs.getString('reschedule_details_with_stylist');
        if (rescheduleDetailsJson == null) {
          throw Exception('No reschedule details found in SharedPreferences');
        }

        return stylists
            .where((stylistJson) =>
                (stylistJson as Map<String, dynamic>)['is_selected'] == '1')
            .map((stylistJson) {
          final stylist = stylistJson as Map<String, dynamic>;
          // Find the corresponding service_details_id from the bookingData
          final serviceId = service['service_id'];
          final Map<String, dynamic> serviceDetails = servicesData.firstWhere(
              (s) => s['service_id'].toString() == serviceId.toString(),
              orElse: () => {}); // Return an empty map if no match is found

          if (serviceDetails.isEmpty) {
            throw Exception('No matching service details found');
          }

          return {
            'booking_details_id': serviceDetails['service_details_id'] ?? '',
            'service_id': serviceId,
            'stylist_id': int.parse(
                stylist['stylist_id'] ?? '0'), // Ensured integer conversion
            'stylist_shift_id': stylist['stylist_shift_id'],
            'stylist_shift_type': stylist['stylist_shift_type'],
            'service_from': serviceFrom, // Use times from the response
            'service_to': serviceTo, // Use times from the response
          };
        }).toList();
      }).toList(); // Flatten the list
      final String? rescheduleDetailsJson =
          prefs.getString('reschedule_details_with_stylist');
      if (rescheduleDetailsJson == null) {
        throw Exception('No reschedule details found in SharedPreferences');
      }
      final List<dynamic> rescheduleDetailsWithStylist =
          jsonDecode(rescheduleDetailsJson);

      // Construct the request body
      final Map<String, dynamic> requestBody = {
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'booking_id': bookingId, // Use the booking_id from bookingData
        'booking_date': bookingData[
            'booking_date'], // Use the booking_date from bookingData
        'slot_from': selectedSlotFrom,
        'slot_to': selectedSlotTo,
        'reschedule_details': rescheduleDetailsWithStylist,
      };

      // Print the request body before making the API call
      print('Request Body (Before API Call): ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/reschedule-appointment/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body of reshedule: ${response.body}');

      if (response.statusCode == 200) {
        // Call _submitReschedule to show the success dialog
        _submitReschedule();
      } else {
        throw Exception('Failed to reschedule appointment');
      }
    } catch (error, stackTrace) {
      print('Error occurred: $error');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> _rescheduleAppointment() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Fetch required data from SharedPreferences
      final String? salonID = prefs.getString('salon_id');
      final String? branchID = prefs.getString('branch_id');
      final String? customerId1 = prefs.getString('customer_id');
      final String? customerId2 = prefs.getString('customer_id2');
      final String? timeSlot = prefs.getString('selected_date');
      final String? stylistServiceData =
          prefs.getString('stylist_service_data_stored');
      final String? bookingID = prefs.getString('selected_booking_id');
      final String? bookingJson = prefs.getString('selected_booking_json');

      // Determine customer ID
      final String customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      // Validate required data
      if (customerId.isEmpty ||
          salonID == null ||
          branchID == null ||
          timeSlot == null ||
          stylistServiceData == null ||
          bookingID == null ||
          bookingJson == null) {
        throw Exception('Missing required data');
      }

      // Parse the booking JSON to get services and booking details
      final Map<String, dynamic> bookingData = jsonDecode(bookingJson);
      final List<dynamic> services = bookingData['services'];

      // Parse stylist service data
      final List<dynamic> stylistData = jsonDecode(stylistServiceData);
      if (stylistData.isEmpty) {
        throw Exception('Stylist data is empty');
      }

      // Prepare request body
      final requestBody = {
        "salon_id": salonID,
        "branch_id": branchID,
        "customer_id": customerId,
        "booking_id": bookingID,
        "booking_date": timeSlot,
        "slot_from": stylistData[0]['service_from'],
        "reschedule_details": stylistData.map((data) {
          final serviceDetails = services.firstWhere(
              (service) => service['service_id'] == data['service_id'],
              orElse: () => {});

          return {
            "booking_details_id": serviceDetails['service_details_id'] ?? '',
            "service_id": data['service_id'],
            "stylist_id": data['selected_stylist'][0]['id'],
            "stylist_shift_id": data['selected_stylist'][0]['shiftId'],
            "stylist_shift_type": data['selected_stylist'][0]['shiftType'],
            "service_from": data['service_from'],
            "service_to": data['service_to'],
          };
        }).toList()
      };

      // Print request body for debugging
      print('Request Body: ${jsonEncode(requestBody)}');

      // Call the API
      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/reschedule-appointment/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // Print the API response for debugging
      print('API Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Check if the request was successful (HTTP 200)
      if (response.statusCode == 200) {
        // Call the _submitReschedule method if the request was successful
        _submitReschedule();
      } else {
        print(
            'Failed to reschedule appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _submitReschedule() {
    // Perform submission logic here, if needed
    // setState(() {
    //   _isSubmitted = true;
    // });

    // Show dialog after submission
    showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing dialog on tap outside
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              width: 280,
              height: 450,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/reschedule.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/rescheduling1.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rescheduling Success!!',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF353B43),
                      height: 21.6 / 18,
                      letterSpacing: 0.02,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Appointment successfully changed. You will receive a notification.',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF353B43),
                      height: 14.4 / 12,
                      letterSpacing: 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Spacer between buttons

                  // View Appointment Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40), // Adjust margins as needed
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to MyBookingsPage on button press
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => UpcomingPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            CustomColors.backgroundtext, // Background color
                        shadowColor: const Color(0x0A000000), // Shadow color
                        elevation: 5, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 8), // Adjust padding as needed
                      ),
                      child: const Text(
                        'View Appointment',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15, // Adjust font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Spacer between buttons
                ],
              ),
            ),
          );
        });
  }

  Future<void> _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve booking JSON from SharedPreferences
    final String? bookingJson = prefs.getString('selected_booking_json');
    if (bookingJson == null) {
      throw Exception('No booking data found in SharedPreferences');
    }

    final Map<String, dynamic> bookingData = jsonDecode(bookingJson);

    // Extract required data
    final String bookingId = bookingData['booking_id'] ?? '';
    final List<dynamic> servicesData = bookingData['services'] ?? [];

    // Prepare reschedule details with the correct booking_details_id from the services data
    final List<Map<String, dynamic>> rescheduleDetails =
        servicesData.map((service) {
      return {
        'booking_details_id':
            service['service_details_id'] ?? '', // Ensure this ID is correct
        'service_id': service['service_id'] ?? '',
      };
    }).toList();

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

    final String? selectedServiceDataJson1 =
        prefs.getString('selected_service_data');
    final String? selectedServiceDataJson2 =
        prefs.getString('selected_service_data1');
    List<String> serviceIds = [];
    if (selectedServiceDataJson1 != null) {
      final Map<String, dynamic> services1 =
          jsonDecode(selectedServiceDataJson1);
      serviceIds.addAll(
          services1.values.map((service) => service['serviceId'] as String));
    }
    if (selectedServiceDataJson2 != null) {
      final Map<String, dynamic> services2 =
          jsonDecode(selectedServiceDataJson2);
      serviceIds.addAll(
          services2.values.map((service) => service['serviceId'] as String));
    }

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

    final String? bookingDate = prefs.getString('selected_date');
    if (bookingDate == null || bookingDate.isEmpty) {
      throw Exception('No valid booking date found');
    }

    // Construct the request body
    final Map<String, dynamic> requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
      'booking_date': bookingDate,
      'slot_from': selectedSlotFrom,
      'slot_to': selectedSlotTo,
      'booking_id': bookingId,
      'reschedule_details': rescheduleDetails,
    };

    // Debug: Log the requestBody
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/reschedule-service-stylists/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body of stylist: ${response.body}');
    print('Booking Data: $bookingData');
    print('Selected Service Data 1: $selectedServiceDataJson1');
    print('Selected Service Data 2: $selectedServiceDataJson2');
    print('Service IDs: $serviceIds');

    // Save response body to SharedPreferences
    if (response.statusCode == 200) {
      await prefs.setString(
          'response_body', response.body); // Save the response body as a string

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> servicesData = responseData['data'];
      setState(() {
        services = servicesData
            .map((serviceJson) => Service.fromJson(serviceJson))
            .toList();
      });
      await _saveStylistsToPreferences(); // Save stylist names to preferences

      // Extract details from the response body to store in SharedPreferences
      List<Map<String, dynamic>> rescheduleDetailsWithStylist = [];
      for (int i = 0; i < servicesData.length; i++) {
        final service = servicesData[i];
        final serviceId = service['service_id'];
        final stylistData = service['available_stylists']?.first;
        final stylistId = stylistData?['stylist_id'];
        final stylistShiftId = stylistData?['stylist_shift_id'];
        final stylistShiftType = stylistData?['stylist_shift_type'];
        final serviceFrom = service['service_from'];
        final serviceTo = service['service_to'];

        // Manually add the booking_details_id from request
        final String bookingDetailsId =
            rescheduleDetails[i]['booking_details_id'] ?? '';

        rescheduleDetailsWithStylist.add({
          'booking_details_id':
              bookingDetailsId, // Add the booking_details_id from request
          'service_id': serviceId,
          'stylist_id': stylistId ?? '',
          'stylist_shift_id': stylistShiftId ?? '',
          'stylist_shift_type': stylistShiftType ?? '',
          'service_from': serviceFrom ?? '',
          'service_to': serviceTo ?? '',
        });
      }

      // Save reschedule details with stylist to SharedPreferences
      await prefs.setString('reschedule_details_with_stylist',
          jsonEncode(rescheduleDetailsWithStylist));

      // Debug: Log the saved reschedule details
      print(
          'Reschedule Details with Stylist: ${jsonEncode(rescheduleDetailsWithStylist)}');
    } else {
      throw Exception('Failed to load data');
    }

    // Retrieve and print 'selected_package_data_add_package' from SharedPreferences
    final String? packageData =
        prefs.getString('selected_package_data_add_package');
    print('Selected Package Data: $packageData');
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_date');
    await prefs.remove('selected_time_slot');
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stylist_service_data_stored');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RescheduleCalender(),
      ),
    );
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
                width: 300,
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
                                tempStylists
                                    .forEach((s) => s.isSelected = false);
                                stylist.isSelected = true;
                                selectedSpecialist = stylist.stylistName;
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
                                        tempStylists.forEach(
                                            (s) => s.isSelected = false);
                                        stylist.isSelected = newValue ?? false;
                                        selectedSpecialist = stylist.isSelected
                                            ? stylist.stylistName
                                            : null;
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
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            // Create a map of selected stylist and service data
                            Map<String, dynamic> stylistServiceData = {
                              'service_id': service.serviceId,
                              'service_from': service.serviceFrom,
                              'service_to': service.serviceTo,
                              'selected_stylist': tempStylists
                                  .where((s) => s.isSelected)
                                  .map((s) => {
                                        'id': s.stylistId,
                                        'shiftId': s.stylistShiftId,
                                        'shiftType': s.stylistShiftType,
                                        'name': s.stylistName,
                                        'designation': s.stylistDesignation,
                                        'profilePhoto': s.profilePhoto,
                                      })
                                  .toList(),
                              'selected_service':
                                  service.serviceName ?? 'No Service',
                            };

                            // Retrieve existing data from shared preferences
                            String? existingData =
                                prefs.getString('stylist_service_data_stored');
                            List<dynamic> stylistServiceList = [];

                            if (existingData != null) {
                              stylistServiceList = jsonDecode(existingData);
                            }

                            // Append the new data to the list
                            stylistServiceList.add(stylistServiceData);

                            // Store the updated list back in shared preferences
                            await prefs.setString('stylist_service_data_stored',
                                jsonEncode(stylistServiceList));
                            print(
                                'selected stylist data is $stylistServiceList');
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

  @override
  Widget build(BuildContext context) {
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
            builder: (context) => RescheduleCalender(),
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
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('stylist_service_data_stored');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RescheduleCalender(),
                ),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(8.0)),
                          child: Image.network(
                            service.image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
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
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            service.serviceName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marathi Name: ${service.serviceMarathiName}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'From: ${service.formattedServiceFrom}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'To: ${service.formattedServiceTo}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              if (selectedStylists.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Selected Stylists: $selectedStylists',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.backgroundtext,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            _showStylistsDialog(service);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _showStylistsDialog(service);
                          },
                          child: Text('Edit Stylist'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: CustomColors.backgroundtext,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
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
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _navigateToHome,
                  child: Text('Back'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: CustomColors.backgroundtext,
                    minimumSize: Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _areAllServicesStylistsSelected()
                      ? () async {
                          try {
                            // Show loading indicator or disable the button if necessary
                            // For example, you could show a CircularProgressIndicator while processing

                            // Call the reschedule appointment function
                            await _rescheduleAppointment();

                            // Navigate to ReviewSummary after successful rescheduling
                          } catch (e) {
                            // Handle any exceptions or errors here
                            print('Error rescheduling appointment: $e');
                            // Optionally, show an error message to the user
                          }
                        }
                      : null,
                  child: Text('Reschedule'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _areAllServicesStylistsSelected()
                        ? CustomColors.backgroundtext
                        : Colors.grey,
                    minimumSize: Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
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
