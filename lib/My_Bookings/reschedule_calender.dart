import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/My_Bookings/complete_reschedule.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_service.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_services.dart';
import 'package:ms_salon_task/Payment/review_summary.dart';
import 'package:ms_salon_task/main.dart';
// import 'package:ms_salon_task/select_specialist.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class RescheduleCalender extends StatefulWidget {
  @override
  _RescheduleCalenderState createState() => _RescheduleCalenderState();
}

class _RescheduleCalenderState extends State<RescheduleCalender> {
  TextEditingController _dateController = TextEditingController();
  String _selectedTimeSlot = '';
  List<Map<String, dynamic>> selectedStylists = [];
  String _selectedTimeSlotTo = '';
  String _selectedTime = '';
  List<dynamic> stylistsData = [];
  String globalBookingDetailsIds = '';

  final ApiService2 _apiService = ApiService2();
  DateTime? _minDate;
  String selectedStylistId = '';
  DateTime? _maxDate;
  String profilePath = '';
  Timer? _debounceTimer;
  List<Map<String, dynamic>> stylists = [];
  String _noStylistsMessage = '';
  bool isStylistSelectionPage = false; // Default value
  String _formattedDate = '';
  String _newFormatDate = '';
  final Duration _debounceDuration =
      Duration(milliseconds: 300); // Adjust as needed

  Map<String, List<dynamic>> _timeSlots = {
    'morning_slots': [],
    'afternoon_slots': [],
    'evening_slots': []
  }; // Store time slots categorized by periods
  bool _isLoading = true; // Manage loading state
  bool _hasMoreSlots = true; // To check if there are more slots to load
  int _offset = 0; // Pagination offset

  String? selectedMonth;
  final List<String> allMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  Map<String, String> monthMapping = {
    'January': '01',
    'February': '02',
    'March': '03',
    'April': '04',
    'May': '05',
    'June': '06',
    'July': '07',
    'August': '08',
    'September': '09',
    'October': '10',
    'November': '11',
    'December': '12',
  };
  int? selectedYear;
  int _selectedMonthIndex = 0;

  List<String> dates = List.generate(31, (index) => '${index + 1}');
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Track selected time slot

  List<Map<String, dynamic>> bookingDates = [];
  ScrollController _scrollController = ScrollController();
  List<String> getNextFourMonths() {
    DateTime now = DateTime.now();
    List<String> nextFourMonths = [];

    for (int i = 0; i < 4; i++) {
      int monthIndex = (now.month - 1 + i) % 12; // Wrap around for December
      nextFourMonths.add(allMonths[monthIndex]);
    }

    return nextFourMonths;
  }

  @override
  void initState() {
    super.initState();
    _fetchBookingRules();
    fetchStylists(_formattedDate);
    _loadSelectedTimeSlot();
    _fetchBookingDates();
    _initializePage();
    DateTime now = DateTime.now();
    selectedMonth = DateFormat('MMMM').format(DateTime.now());
    selectedYear = now.year;
  }

  Future<void> bookStylist(BuildContext context) async {
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

    if (customerId.isEmpty) throw Exception('No valid customer ID found');

    final String? timeSlot = prefs.getString('selected_time_slot');
    if (timeSlot == null || !timeSlot.contains('-'))
      throw Exception('Invalid time slot format');

    final List<String> times = timeSlot.split('-');
    if (times.length != 2) throw Exception('Invalid time slot format');

    final String selectedSlotFrom = times[0].trim();
    final String selectedSlotTo = times[1].trim();
    final String? bookingDate = prefs.getString('selected_date');
    if (bookingDate == null || bookingDate.isEmpty)
      throw Exception('No valid booking date found');

    final String? bookingJsonString = prefs.getString('selected_booking_json');
    if (bookingJsonString == null)
      throw Exception('No booking JSON found in SharedPreferences');

    final Map<String, dynamic> bookingJson = jsonDecode(bookingJsonString);
    final String bookingId = bookingJson['booking_id'] ?? '';
    final List<dynamic> services = bookingJson['services'] ?? [];

    // Clear the global string before storing new IDs
    globalBookingDetailsIds = '';

    final List<Map<String, String>> rescheduleDetails = services.map((service) {
      final bookingDetailsId = service['service_details_id']?.toString() ?? '';

      // Concatenate booking_details_id values into the global string
      if (globalBookingDetailsIds.isNotEmpty) {
        globalBookingDetailsIds += ','; // Add a delimiter if not the first ID
      }
      globalBookingDetailsIds += bookingDetailsId;

      return {
        'booking_details_id': bookingDetailsId,
        'service_id': service['service_id']?.toString() ?? ''
      };
    }).toList();

    final Map<String, dynamic> requestBody = {
      "salon_id": salonID,
      "branch_id": branchID,
      "customer_id": customerId,
      "selected_slot_from": selectedSlotFrom,
      "selected_slot_to": selectedSlotTo,
      "booking_id": bookingId,
      "booking_date": bookingDate,
      "reschedule_details": rescheduleDetails,
      "stylist_id": selectedStylistId,
    };

    // Print request body
    print('Request Body for Book Stylist: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/reschedule-stylists-review/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Print response body
      print('Response Body: ${response.body}');
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'true') {
        // Store the new data
        final stylistData = responseBody['data'];
        List<Map<String, dynamic>> updatedStylistData = [];
        List<Map<String, String>> stylistServiceList = [];

        for (var item in stylistData) {
          updatedStylistData.add({
            'service_id': item['service_id'],
            'stylist_id': item['selected_stylist_id'],
            'stylist_shift_id': item['selected_stylist_shift_id'],
            'stylist_shift_type': item['selected_stylist_shift_type'],
          });
          stylistServiceList.add({
            'selected_stylist':
                item['selected_stylist_name'] ?? 'Unknown Stylist',
            'selected_service': item['service_name'] ?? 'Unknown Service',
          });
        }

        // Save data to SharedPreferences
        await prefs.setString(
            'selected_stylist_data_list', jsonEncode(updatedStylistData));
        await prefs.setString(
            'stylist_service_data_stored', jsonEncode(stylistServiceList));

        // Call _rescheduleAppointment with the new data
        _rescheduleAppointment(context, updatedStylistData, stylistServiceList);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book stylist. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollLeft() {
    // Scroll left by the width of a date item (50 + 8 for margins)
    _scrollController.animateTo(
      _scrollController.offset - (50 + 8),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    // Scroll right by the width of a date item (50 + 8 for margins)
    _scrollController.animateTo(
      _scrollController.offset + (50 + 8),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void fetchStylists(String formattedDate) async {
    try {
      setState(() {
        _isLoading = true;
      });

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
      final String? bookingDate = prefs.getString('selected_date');
      if (bookingDate == null || bookingDate.isEmpty) {
        throw Exception('No valid booking date found');
      }
      final String? bookingJsonString =
          prefs.getString('selected_booking_json');
      if (bookingJsonString == null) {
        throw Exception('No booking JSON found in SharedPreferences');
      }
      final Map<String, dynamic> bookingJson = jsonDecode(bookingJsonString);
      final String bookingId = bookingJson['booking_id'] ?? '';

      // Extract reschedule details from the booking JSON
      final List<dynamic> services = bookingJson['services'] ?? [];
      final List<Map<String, String>> rescheduleDetails =
          services.map((service) {
        return {
          'booking_details_id': service['service_details_id']?.toString() ?? '',
          'service_id': service['service_id']?.toString() ?? ''
        };
      }).toList();

      final String? selectedServiceDataJson1 =
          prefs.getString('selected_service_data');
      final String? selectedServiceDataJson2 =
          prefs.getString('selected_service_data1');

      List<String> serviceIds = [];
      int totalDuration = 0;

      if (selectedServiceDataJson1 != null) {
        final Map<String, dynamic> services1 =
            jsonDecode(selectedServiceDataJson1);
        serviceIds.addAll(
            services1.values.map((service) => service['serviceId'] as String));

        services1.forEach((key, service) {
          totalDuration += int.parse(service['duration']);
        });
      }

      if (selectedServiceDataJson2 != null) {
        final Map<String, dynamic> services2 =
            jsonDecode(selectedServiceDataJson2);
        serviceIds.addAll(
            services2.values.map((service) => service['serviceId'] as String));

        services2.forEach((key, service) {
          totalDuration += int.parse(service['duration']);
        });
      }

      final requestBody = {
        "salon_id": salonID,
        "branch_id": branchID,
        "customer_id": customerId,
        "booking_date": bookingDate,
        "reschedule_details": rescheduleDetails,
      };

      log('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse("${MyApp.apiUrl}customer/reschedule-stylists/"),
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
        },
      );

      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'true') {
          profilePath = data['profile_path'];
          stylistsData = data['data'];

          // Store the value of 'is_stylist_selection_page' globally
          isStylistSelectionPage = data['is_stylist_selection_page'] == '1';

          setState(() {
            stylists = stylistsData.map((stylist) {
              return {
                'id': stylist['id'],
                'name': stylist['full_name'],
                'designation_name': stylist['designation_name'],
                'image': '${profilePath}${stylist['profile_photo']}',
                'selected': false,
              };
            }).toList();

            if (stylists.isNotEmpty) {
              stylists[0]['selected'] = true;
            }
          });

          setState(() {
            _isLoading = true; // Start loading time slots
          });

          await _fetchTimeSlots(
              offset: _offset, selectedStylistId: stylists[0]['id']);

          setState(() {
            _isLoading = false; // Stop loading after fetching time slots
          });
        } else {
          setState(() {
            stylists = [];
            _noStylistsMessage = "No stylists available. Please contact salon.";
          });
        }
      } else {
        print('Failed to load stylists');
      }
    } catch (e) {
      print('Error fetching stylists: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData2() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      if (_dateController.text.isNotEmpty) {
        // Reset the time slots
        setState(() {
          _timeSlots = {
            'morning_slots': [],
            'afternoon_slots': [],
            'evening_slots': []
          };
          _offset = 0; // Reset offset
          _hasMoreSlots = true; // Ensure more slots can be fetched
        });
        await _fetchTimeSlots(
            offset: _offset, selectedStylistId: selectedStylistId);
      }
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void toggleSelection(int index) async {
    setState(() {
      _isLoading = true; // Start the loading state
    });

    try {
      // Clear all previous selections if any, and set the selected one
      for (var stylist in stylists) {
        stylist['selected'] = false;
      }
      selectedStylists.clear();

      // Ensure the clicked stylist is selected
      stylists[index]['selected'] = true;

      // Add the selected stylist to the selectedStylists list
      selectedStylists.add({
        'id': stylists[index]['id'],
        'full_name': stylists[index]['name'],
        'mobile_no': stylistsData[index]['mobile_no'],
        'gender': stylistsData[index]['gender'],
        'dob': stylistsData[index]['dob'],
        'profile_photo': '${profilePath}${stylists[index]['image']}',
        'description': stylistsData[index]['description'],
        'designation_name': stylistsData[index]['designation_name'],
      });

      // Update selectedStylistId without adding extra quotes
      selectedStylistId = stylists[index]['id'].toString();

      // Print the selected stylist ID
      print("Selected Stylist ID: $selectedStylistId");

      // Print the combined selected stylist data as JSON
      Map<String, dynamic> combinedStylists = {};
      selectedStylists.forEach((stylist) {
        combinedStylists[stylist['full_name']] = stylist;
      });
      print("Combined Selected Stylists JSON:");
      print(json
          .encode(combinedStylists)); // Print the selected stylist data as JSON

      // Call _fetchTimeSlots with the selectedStylistId
      await _fetchTimeSlots(
          offset: _offset, selectedStylistId: selectedStylistId);

      // Call _refreshData after updating stylist selection
      await _refreshData2();
    } catch (e) {
      print("Error during fetch time slots: $e");
    } finally {
      setState(() {
        _isLoading =
            false; // Set loading to false after the operation completes
      });
    }
  }

  Future<void> _fetchBookingDates() async {
    try {
      print('Fetching booking dates...');
      const String url = '${MyApp.apiUrl}customer/booking-dates/';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      if (branchID.isEmpty || salonID.isEmpty) {
        print('Branch ID or Salon ID is empty');
        return;
      }

      final Map<String, dynamic> requestBody = {
        'salon_id': salonID,
        'limit': '35',
        'offset': '0',
        'branch_id': branchID,
        'month': '', // Add month value if needed
        'year': '', // Add year value if needed
      };

      print('Request URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body of Booking Date: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            bookingDates =
                List<Map<String, dynamic>>.from(responseData['data']);
          });
          print('Parsed Booking Dates: $bookingDates');
        } else {
          print('Failed to fetch booking dates: ${responseData['message']}');
        }
      } else {
        print('Failed to fetch booking dates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching booking dates: $e');
    }
  }

  Future<void> _rescheduleAppointment(
      BuildContext context,
      List<Map<String, dynamic>> updatedStylistData,
      List<Map<String, String>> stylistServiceList) async {
    final prefs = await SharedPreferences.getInstance();
    final String? salonID = prefs.getString('salon_id');
    final String? branchID = prefs.getString('branch_id');
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String? timeSlot = prefs.getString('selected_time_slot');
    final String? bookingDate = prefs.getString('selected_date');

    if (bookingDate == null || bookingDate.isEmpty) {
      throw Exception('No valid booking date found');
    }

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
    final String? bookingJsonString = prefs.getString('selected_booking_json');
    if (bookingJsonString == null)
      throw Exception('No booking JSON found in SharedPreferences');

    final Map<String, dynamic> bookingJson = jsonDecode(bookingJsonString);
    final String bookingId = bookingJson['booking_id'] ?? '';
    final String selectedSlotFrom = times[0].trim();
    final String selectedSlotTo = times[1].trim();

    // Construct the reschedule details using the updated data from bookStylist
    final List<Map<String, dynamic>> rescheduleDetails =
        updatedStylistData.map((stylistData) {
      return {
        'booking_details_id': globalBookingDetailsIds,
        'service_id': stylistData['service_id'],
        'stylist_id': stylistData['stylist_id'],
        'stylist_shift_id': stylistData['stylist_shift_id'],
        'stylist_shift_type': stylistData['stylist_shift_type'],
        'service_from': selectedSlotFrom,
        'service_to': selectedSlotTo,
      };
    }).toList();

    final Map<String, dynamic> requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
      'booking_id': bookingId, // Use the correct booking ID if needed
      'booking_date': bookingDate,
      'slot_from': selectedSlotFrom,
      'slot_to': selectedSlotTo,
      'reschedule_details': rescheduleDetails,
    };

    // Print request body
    print(
        'Request Body for Reschedule Appointment: ${jsonEncode(requestBody)}');

    bool? shouldReschedule = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Confirm Reschedule',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomColors.backgroundtext,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Do you really want to reschedule the appointment?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RescheduleCalender(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'No',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Close dialog
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Prevent user from dismissing loader
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: CustomColors.backgroundtext,
                      ),
                    );
                  },
                );
                await Future.delayed(
                    Duration(seconds: 2)); // Simulate operation
                Navigator.of(context).pop(); // Close loader after operation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.backgroundtext,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReschedule == true) {
      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/reschedule-appointment/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      // Print response body
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _submitReschedule(); // Show success dialog
      } else {
        throw Exception('Failed to reschedule appointment');
      }
    } else {
      print('Reschedule was cancelled by the user.');
    }
  }

  Future<void> _rescheduleAppointmentOld() async {
    final prefs = await SharedPreferences.getInstance();

    final String? salonID = prefs.getString('salon_id');
    final String? branchID = prefs.getString('branch_id');
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String? timeSlot = prefs.getString('selected_time_slot');
    final String? bookingDate = prefs.getString('selected_date');
    if (bookingDate == null || bookingDate.isEmpty) {
      throw Exception('No valid booking date found');
    }
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

    final Map<String, dynamic> responseData = jsonDecode(responseBody);
    final List<dynamic> servicesResponseData =
        responseData['data']?['service_stylists_data'] ?? [];

    // Prepare reschedule details
    final List<Map<String, dynamic>> rescheduleDetails =
        servicesResponseData.expand((serviceJson) {
      final service = serviceJson as Map<String, dynamic>;
      final Map<String, dynamic>? stylist = service['selected_stylists'];

      final String serviceFrom = service['service_from'] ?? '';
      final String serviceTo = service['service_to'] ?? '';

      if (stylist == null) {
        // Handle the case where no stylist is required
        final serviceId = service['service_id'];
        final serviceDetails = servicesData.firstWhere(
            (s) => s['service_id'] == serviceId,
            orElse: () => {}) as Map<String, dynamic>;

        return [
          {
            'booking_details_id': serviceDetails['service_details_id'] ?? '',
            'service_id': serviceId,
            'stylist_id': null, // No stylist assigned
            'stylist_shift_id': null,
            'stylist_shift_type': null,
            'service_from': serviceFrom,
            'service_to': serviceTo,
          }
        ];
      }

      // Handle the case where a stylist is selected
      final serviceId = service['service_id'];
      final serviceDetails = servicesData.firstWhere(
          (s) => s['service_id'] == serviceId,
          orElse: () => {}) as Map<String, dynamic>;

      return [
        {
          'booking_details_id': serviceDetails['service_details_id'] ?? '',
          'service_id': serviceId,
          'stylist_id': stylist['stylist_id'],
          'stylist_shift_id': stylist['stylist_shift_id'],
          'stylist_shift_type': stylist['stylist_shift_type'],
          'service_from': serviceFrom, // Use times from the response
          'service_to': serviceTo, // Use times from the response
        }
      ];
    }).toList(); // Flatten the list

    // Construct the request body
    final Map<String, dynamic> requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
      'booking_id': bookingId, // Use the booking_id from bookingData
      'booking_date': bookingDate,
      // 'booking_date':
      //     bookingData['booking_date'], // Use the booking_date from bookingData
      'slot_from': selectedSlotFrom,
      'slot_to': selectedSlotTo,
      'reschedule_details': rescheduleDetails,
    };

    bool? shouldReschedule = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Reschedule'),
          content: Text('Do you really want to reschedule the appointment?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RescheduleCalender(),
                  ),
                );
                // Navigator.of(context).pop(false); // Return false if No
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(true); // Return true if Yes

                // Show a loader after confirmation
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: CupertinoActivityIndicator(), // Show loader
                    );
                  },
                );

                // Simulate some operation like rescheduling
                await Future.delayed(Duration(seconds: 2)); // Simulating delay

                Navigator.of(context)
                    .pop(); // Close the loader dialog after operation completes
              },
            ),
          ],
        );
      },
    );

    if (shouldReschedule == true) {
      // Print the request body
      print('Reschedule Appointment Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/reschedule-appointment/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Print the response status and body
      print('Response status: ${response.statusCode}');
      print('Response body of submit reschedule: ${response.body}');

      if (response.statusCode == 200) {
        // Call _submitReschedule to show the success dialog
        _submitReschedule();
      } else {
        throw Exception('Failed to reschedule appointment');
      }
    } else {
      print('Reschedule was cancelled by the user.');
    }
  }

  // Future<void> _rescheduleAppointment() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   final String? salonID = prefs.getString('salon_id');
  //   final String? branchID = prefs.getString('branch_id');
  //   final String? customerId1 = prefs.getString('customer_id');
  //   final String? customerId2 = prefs.getString('customer_id2');
  //   final String? timeSlot = prefs.getString('selected_time_slot');

  //   final String customerId = customerId1?.isNotEmpty == true
  //       ? customerId1!
  //       : customerId2?.isNotEmpty == true
  //           ? customerId2!
  //           : '';

  //   if (customerId.isEmpty ||
  //       salonID == null ||
  //       branchID == null ||
  //       timeSlot == null) {
  //     throw Exception('Missing required data');
  //   }

  //   // Extract time slot details
  //   final List<String> times = timeSlot.split('-');
  //   if (times.length != 2) {
  //     throw Exception('Invalid time slot format');
  //   }

  //   final String selectedSlotFrom = times[0].trim();
  //   final String selectedSlotTo = times[1].trim();

  //   // Retrieve and parse 'selected_booking_json' from SharedPreferences
  //   final String? bookingJson = prefs.getString('selected_booking_json');
  //   if (bookingJson == null) {
  //     throw Exception('No booking data found in SharedPreferences');
  //   }

  //   final Map<String, dynamic> bookingData = jsonDecode(bookingJson);

  //   // Extract booking_id and services data
  //   final String bookingId = bookingData['booking_id'] ?? '';
  //   final List<dynamic> servicesData = bookingData['services'] ?? [];

  //   // Retrieve and parse 'response_body' from SharedPreferences
  //   final String? responseBody = prefs.getString('response_body');
  //   if (responseBody == null) {
  //     throw Exception('No response data found in SharedPreferences');
  //   }

  //   final Map<String, dynamic> responseData = jsonDecode(responseBody);
  //   final List<dynamic> servicesResponseData =
  //       responseData['data']?['service_stylists_data'] ?? [];

  //   // Prepare reschedule details
  //   final List<Map<String, dynamic>> rescheduleDetails =
  //       servicesResponseData.expand((serviceJson) {
  //     final service = serviceJson as Map<String, dynamic>;
  //     final Map<String, dynamic>? stylist = service['selected_stylists'];

  //     final String serviceFrom = service['service_from'] ?? '';
  //     final String serviceTo = service['service_to'] ?? '';

  //     if (stylist == null) {
  //       // Handle the case where no stylist is required
  //       final serviceId = service['service_id'];
  //       final serviceDetails = servicesData.firstWhere(
  //           (s) => s['service_id'] == serviceId,
  //           orElse: () => {}) as Map<String, dynamic>;

  //       return [
  //         {
  //           'booking_details_id': serviceDetails['service_details_id'] ?? '',
  //           'service_id': serviceId,
  //           'stylist_id': null, // No stylist assigned
  //           'stylist_shift_id': null,
  //           'stylist_shift_type': null,
  //           'service_from': serviceFrom,
  //           'service_to': serviceTo,
  //         }
  //       ];
  //     }

  //     // Handle the case where a stylist is selected
  //     final serviceId = service['service_id'];
  //     final serviceDetails = servicesData.firstWhere(
  //         (s) => s['service_id'] == serviceId,
  //         orElse: () => {}) as Map<String, dynamic>;

  //     return [
  //       {
  //         'booking_details_id': serviceDetails['service_details_id'] ?? '',
  //         'service_id': serviceId,
  //         'stylist_id': stylist['stylist_id'],
  //         'stylist_shift_id': stylist['stylist_shift_id'],
  //         'stylist_shift_type': stylist['stylist_shift_type'],
  //         'service_from': serviceFrom, // Use times from the response
  //         'service_to': serviceTo, // Use times from the response
  //       }
  //     ];
  //   }).toList(); // Flatten the list

  //   // Construct the request body
  //   final Map<String, dynamic> requestBody = {
  //     'salon_id': salonID,
  //     'branch_id': branchID,
  //     'customer_id': customerId,
  //     'booking_id': bookingId, // Use the booking_id from bookingData
  //     'booking_date':
  //         bookingData['booking_date'], // Use the booking_date from bookingData
  //     'slot_from': selectedSlotFrom,
  //     'slot_to': selectedSlotTo,
  //     'reschedule_details': rescheduleDetails,
  //   };

  //   // Print the request body
  //   print('Reschedule Appointment Request Body: ${jsonEncode(requestBody)}');

  //   final response = await http.post(
  //     Uri.parse('${MyApp.apiUrl}customer/reschedule-appointment/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(requestBody),
  //   );

  //   // Print the response status and body
  //   print('Response status: ${response.statusCode}');
  //   print('Response body of submit reschedule: ${response.body}');

  //   if (response.statusCode == 200) {
  //     // Call _submitReschedule to show the success dialog
  //     _submitReschedule();
  //   } else {
  //     throw Exception('Failed to reschedule appointment');
  //   }
  // }

  void _submitReschedule() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog on tap outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Handle back button press
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    UpcomingPage(), // Navigate to homepage (UpcomingPage)
              ),
            );
            return false; // Prevent default back button behavior
          },
          child: AlertDialog(
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
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => UpcomingPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.backgroundtext,
                        shadowColor: const Color(0x0A000000),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                      ),
                      child: const Text(
                        'View Appointment',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15,
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
          ),
        );
      },
    );
  }

  // Future<void> _initializePage() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Get the stored date from SharedPreferences
  //   final storedDate = prefs.getString('selected_date');

  //   final today = DateTime.now();
  //   final formattedToday = DateFormat('dd-MM-yyyy').format(today);

  //   // Check if there's a stored date
  //   if (storedDate != null) {
  //     _dateController.text = storedDate; // Use the stored date
  //   } else {
  //     _dateController.text = formattedToday; // Use today's date
  //     // Save today's date to SharedPreferences
  //     await prefs.setString('selected_date', formattedToday);
  //   }

  //   // Fetch time slots for the current or stored date
  //   await _fetchTimeSlots(offset: _offset);
  // }
  Future<void> _initializePage() async {
    final prefs = await SharedPreferences.getInstance();

    // Get today's date
    final today = DateTime.now();

    // Keep the previous formatted date as 'dd-MM-yyyy'
    final formattedToday = DateFormat('dd-MM-yyyy').format(today);

    // Format today's date as "Thursday, 22 Jan 2022"
    final readableFormattedToday =
        DateFormat('EEEE, dd MMM yyyy').format(today);

    // Set today's date in the text field and SharedPreferences (update even if already stored)
    _dateController.text = formattedToday;

    // Save the 'dd-MM-yyyy' formatted date in the new variable
    _formattedDate = formattedToday;
    _newFormatDate = readableFormattedToday;
    // Save today's date in SharedPreferences (overwrite any stored date)
    await prefs.setString('selected_date', formattedToday);

    // Fetch time slots for today's date
    await _fetchTimeSlots(
        offset: _offset, selectedStylistId: selectedStylistId);
  }

  Future<void> _loadSelectedTimeSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTimeSlot = prefs.getString('selected_time_slot');
    if (storedTimeSlot != null) {
      final parts = storedTimeSlot.split('|');
      if (parts.length == 2) {
        setState(() {
          _selectedTimeSlot = parts[0]; // From time
          _selectedTimeSlotTo = parts[1]; // To time
        });
      } else {
        print('Stored time slot format is invalid.');
      }
    }
  }

  Future<void> _saveSelectedTimeSlot(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    // Combine from and to times with a delimiter
    final timeSlot = '$from-$to';
    await prefs.setString('selected_time_slot', timeSlot);
    print('Saved time slot to SharedPreferences: $timeSlot');
  }

  Future<void> _fetchBookingRules() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await _apiService.fetchBookingRules();
      print('Raw Response: $response');

      if (response != null && response is Map<String, dynamic>) {
        final daysBeforeBookingString =
            response['days_before_booking'] as String?;
        print('days_before_booking value: $daysBeforeBookingString');

        if (daysBeforeBookingString != null) {
          final daysBeforeBooking = int.tryParse(daysBeforeBookingString) ?? 0;
          final now = DateTime.now();
          setState(() {
            _minDate = now;
            _maxDate = now.add(Duration(days: daysBeforeBooking));
          });
        } else {
          print('days_before_booking is missing or null.');
        }
      } else {
        print('Invalid response format.');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTimeSlots(
      {int offset = 0, required String selectedStylistId}) async {
    if (_dateController.text.isNotEmpty) {
      final formattedDate = _dateController.text;

      // Cancel any previous debounce timer
      _debounceTimer?.cancel();

      _debounceTimer = Timer(_debounceDuration, () async {
        try {
          // Fetch time slots with the current offset and selected stylist ID
          final newSlots = await _apiService.fetchTimeSlots(
              formattedDate, offset, selectedStylistId);

          setState(() {
            bool slotsAvailable = false; // Track if any slots are available

            // Append new slots to the existing ones
            if (newSlots['morning_slots'] != null &&
                newSlots['morning_slots'].isNotEmpty) {
              _timeSlots['morning_slots']?.addAll(newSlots['morning_slots']);
              slotsAvailable = true;
            }
            if (newSlots['afternoon_slots'] != null &&
                newSlots['afternoon_slots'].isNotEmpty) {
              _timeSlots['afternoon_slots']
                  ?.addAll(newSlots['afternoon_slots']);
              slotsAvailable = true;
            }
            if (newSlots['evening_slots'] != null &&
                newSlots['evening_slots'].isNotEmpty) {
              _timeSlots['evening_slots']?.addAll(newSlots['evening_slots']);
              slotsAvailable = true;
            }

            // Update _hasMoreSlots based on the availability of slots
            _hasMoreSlots = slotsAvailable;

            // Print a message based on availability
            if (slotsAvailable) {
              print('Slots are available. You can keep loading more slots.');
              // Update offset for the next load
              _offset += 14; // Increment offset regardless of available slots
            } else {
              print('No more slots available to load.');
            }
          });
        } catch (e) {
          print('Error fetching time slots: $e');
        }
      });
    }
  }

  Future<void> _onDateSelected(DateTime date) async {
    // Format the date as 'dd-MM-yyyy'
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);

    // Format the date as 'Thursday, 22 Jan 2022'
    final readableFormattedDate = DateFormat('EEEE, dd MMM yyyy').format(date);

    setState(() {
      _dateController.text = formattedDate;
      _formattedDate = formattedDate; // Update the formatted date variable
      _offset = 0; // Reset offset when date is changed
      _isLoading = true;
      _newFormatDate = readableFormattedDate;
      // Reset the time slots for the new date
      _timeSlots = {
        'morning_slots': [],
        'afternoon_slots': [],
        'evening_slots': []
      };
    });

    // Fetch time slots for the selected date
    await _fetchTimeSlots(
        offset: _offset, selectedStylistId: selectedStylistId);

    setState(() {
      _isLoading = false;
    });

    // Save both the 'dd-MM-yyyy' formatted date and readable formatted date to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selected_date', formattedDate); // Save 'dd-MM-yyyy' format
    await prefs.setString('readable_selected_date',
        readableFormattedDate); // Save readable format

    print('Saved date to SharedPreferences: $formattedDate');
    print('Saved readable date to SharedPreferences: $readableFormattedDate');
    fetchStylists(formattedDate);
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Fetch booking rules again
      await _fetchBookingRules();

      // If a date is already selected, fetch time slots again
      if (_dateController.text.isNotEmpty) {
        // Reset the time slots
        setState(() {
          _timeSlots = {
            'morning_slots': [],
            'afternoon_slots': [],
            'evening_slots': []
          };
          _offset = 0; // Reset offset
          _hasMoreSlots = true; // Ensure more slots can be fetched
        });
        await _fetchTimeSlots(
            offset: _offset, selectedStylistId: selectedStylistId);
      }
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Widget _buildTimeSlot(
  //     String from, String to, bool isVacant, bool isSelected) {
  //   return GestureDetector(
  //     onTap: isVacant
  //         ? () {
  //             setState(() {
  //               // Toggle selection
  //               if (_selectedTimeSlot == from) {
  //                 _selectedTimeSlot = ''; // Deselect if already selected
  //                 _selectedTimeSlotTo = ''; // Clear selected time
  //               } else {
  //                 _selectedTimeSlot = from; // Select the new time slot
  //                 _selectedTimeSlotTo = to; // Store both "from" and "to" times
  //               }

  //               // Save the selected time slot
  //               _saveSelectedTimeSlot(_selectedTimeSlot, _selectedTimeSlotTo);
  //             });
  //           }
  //         : null, // Disable the tap gesture if not vacant
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
  //       margin: EdgeInsets.symmetric(vertical: 5),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: isSelected ? CustomColors.backgroundtext : Colors.transparent,
  //           width: 2,
  //         ),
  //         borderRadius: BorderRadius.circular(5),
  //         color: isVacant
  //             ? (isSelected ? CustomColors.backgroundtext : Colors.green)
  //             : Colors.red,
  //         boxShadow: [
  //           if (!isSelected && isVacant)
  //             BoxShadow(
  //               color: Colors.grey.withOpacity(0.2),
  //               spreadRadius: 1,
  //               blurRadius: 4,
  //               offset: Offset(0, 2), // changes position of shadow
  //             ),
  //         ],
  //       ),
  //       child: Text(
  //         from, // Display only the "from" time
  //         style: TextStyle(
  //           fontFamily: 'Lato',
  //           fontSize: 12,
  //           fontWeight: FontWeight.w600,
  //           color: isVacant
  //               ? (isSelected ? Colors.white : Colors.white)
  //               : Colors.white,
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }
  Widget _buildTimeSlot(
      String from, String to, bool isVacant, bool isSelected) {
    return GestureDetector(
      onTap: isVacant
          ? () {
              setState(() {
                // Toggle selection
                if (_selectedTimeSlot == from) {
                  _selectedTimeSlot = ''; // Deselect if already selected
                  _selectedTimeSlotTo = ''; // Clear selected time
                } else {
                  _selectedTimeSlot = from; // Select the new time slot
                  _selectedTimeSlotTo = to; // Store both "from" and "to" times
                }

                // Save the selected time slot
                _saveSelectedTimeSlot(_selectedTimeSlot, _selectedTimeSlotTo);
              });
            }
          : null, // Disable the tap gesture if not vacant
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected && isVacant
                ? Colors.transparent
                : (isVacant
                    ? CustomColors.backgroundtext
                    : Colors
                        .transparent), // Blue border for vacant, transparent for red
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
          color: isVacant
              ? (isSelected
                  ? Colors.green
                  : Colors
                      .white) // Green when selected, white when not selected for vacant
              : Colors.red, // Red background for non-vacant
          // boxShadow: [
          //   if (!isSelected && isVacant)
          //     BoxShadow(
          //       color: Colors.grey.withOpacity(0.2),
          //       spreadRadius: 1,
          //       blurRadius: 4,
          //       offset: Offset(0, 2), // Position of the shadow
          //     ),
          // ],
        ),
        child: Text(
          from, // Display only the "from" time
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isVacant
                ? (isSelected
                    ? Colors.white
                    : CustomColors
                        .backgroundtext) // White when selected, blue when not selected for vacant
                : Colors.white, // White text for non-vacant (red)
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTimeSlots(String period, List<dynamic> slots) {
    bool hasMorningSlots = _timeSlots['morning_slots']?.isNotEmpty ?? false;
    bool hasAfternoonSlots = _timeSlots['afternoon_slots']?.isNotEmpty ?? false;
    bool hasEveningSlots = _timeSlots['evening_slots']?.isNotEmpty ?? false;

    bool useGridForEvening = period == 'Evening Slots' &&
        (!hasMorningSlots && !hasAfternoonSlots || slots.length == 1);

    // Remove duplicate slots based on 'from' and 'to' times
    Set<String> uniqueSlotsSet = {};
    List<dynamic> uniqueSlots = [];

    for (var slot in slots) {
      final from = slot['from'] as String;
      final to = slot['to'] as String;
      final slotKey = '$from-$to';

      if (!uniqueSlotsSet.contains(slotKey)) {
        uniqueSlotsSet.add(slotKey);
        uniqueSlots.add(slot);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          period,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        if (uniqueSlots.isNotEmpty)
          useGridForEvening
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevent scrolling within the grid
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2, // Aspect ratio for the grid items
                    ),
                    itemCount: uniqueSlots.length,
                    itemBuilder: (context, index) {
                      final slot = uniqueSlots[index];
                      final from = slot['from'] as String;
                      final to = slot['to'] as String;
                      final isVacant = slot['is_vacent'] == '1';
                      final isSelected = from == _selectedTimeSlot;

                      return _buildTimeSlot(from, to, isVacant, isSelected);
                    },
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: uniqueSlots.map<Widget>((slot) {
                      final from = slot['from'] as String;
                      final to = slot['to'] as String;
                      final isVacant = slot['is_vacent'] == '1';
                      final isSelected = from == _selectedTimeSlot;

                      return _buildTimeSlot(from, to, isVacant, isSelected);
                    }).toList(),
                  ),
                )
        else
          SizedBox.shrink(), // If there are no slots, show nothing
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> nextFourMonths = getNextFourMonths();
    return WillPopScope(
        onWillPop: () async {
          // This will navigate back to the first occurrence of `HomePage` in the stack
          // Navigator.of(context).pop((route) => route.isFirst);
          // Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpcomingPage()),
            //  builder: (context) => StorePackagePage()),
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
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpcomingPage(),
                      ),
                    );
                  },
                ),
                Text(
                  'Select Date and Time',
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading &&
                    _hasMoreSlots &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _fetchTimeSlots(
                      offset: _offset,
                      selectedStylistId:
                          selectedStylistId); // Fetch more time slots when scrolled to bottom
                  return true;
                }
                return false;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // GestureDetector(
                        //   onTap: () async {
                        //     if (_minDate != null && _maxDate != null) {
                        //       final DateTime initialDate =
                        //           DateTime.now().isBefore(_minDate!)
                        //               ? _minDate!
                        //               : DateTime.now();
                        //       final DateTime? picked = await showDatePicker(
                        //         context: context,
                        //         initialDate: initialDate,
                        //         firstDate: _minDate!,
                        //         lastDate: _maxDate!,
                        //       );
                        //       if (picked != null) {
                        //         _onDateSelected(picked);
                        //       }
                        //     } else {
                        //       print(
                        //           'Unable to select date. Please wait until the booking rules are loaded.');
                        //     }
                        //   },
                        //   child: Container(
                        //     padding: EdgeInsets.symmetric(
                        //         vertical: 12, horizontal: 16),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(8),
                        //       border: Border.all(
                        //         color: Colors.grey[300]!,
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text(
                        //           _dateController.text.isEmpty
                        //               ? 'Booking Date'
                        //               : _dateController.text,
                        //           style: TextStyle(
                        //             fontFamily: 'Lato',
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.w600,
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         Icon(Icons.calendar_today_outlined,
                        //             color: Colors.black),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        SizedBox(height: 10),
                        //new data
                        // SizedBox(height: 15),
                        //new data
                        Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Side: Text Widget
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_outlined,
                                          color: CustomColors
                                              .backgroundtext), // Calendar Icon
                                      const SizedBox(
                                          width:
                                              8), // Space between icon and textCustomColors.backgroundtext
                                      Text(
                                        'Selected Date',
                                        style: GoogleFonts.lato(
                                          fontSize: 18, // Adjust font size
                                          fontWeight: FontWeight.w600,
                                          color: const Color(
                                              0xFF1D2024), // Text color
                                          height: 1.2, // Adjust line height
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right Side: Container with PopupMenuButton
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: CustomColors.backgroundtext,
                                        width: 0.5),
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Color(0x0A000000),
                                        offset: Offset(10, -2),
                                        blurRadius: 75,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                  ),
                                  child: PopupMenuButton<String>(
                                    onSelected: (String value) async {
                                      setState(() {
                                        selectedMonth =
                                            value; // Update the selected month
                                        print(
                                            'Selected Month: $selectedMonth, Year: $selectedYear');
                                      });

                                      // Fetch booking dates based on the selected month and year
                                      final monthMapping = {
                                        'January': '01',
                                        'February': '02',
                                        'March': '03',
                                        'April': '04',
                                        'May': '05',
                                        'June': '06',
                                        'July': '07',
                                        'August': '08',
                                        'September': '09',
                                        'October': '10',
                                        'November': '11',
                                        'December': '12',
                                      };

                                      try {
                                        print('Fetching booking dates...');
                                        const String url =
                                            '${MyApp.apiUrl}customer/booking-dates/';
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        final String branchID =
                                            prefs.getString('branch_id') ?? '';
                                        final String salonID =
                                            prefs.getString('salon_id') ?? '';

                                        if (branchID.isEmpty ||
                                            salonID.isEmpty) {
                                          print(
                                              'Branch ID or Salon ID is empty');
                                          return;
                                        }

                                        final String twoDigitMonth =
                                            monthMapping[selectedMonth] ?? '';
                                        final Map<String, dynamic> requestBody =
                                            {
                                          'salon_id': salonID,
                                          'limit': '35',
                                          'offset': '0',
                                          'branch_id': branchID,
                                          'month': twoDigitMonth,
                                          'year': selectedYear.toString(),
                                        };

                                        print(
                                            'Request Body: ${jsonEncode(requestBody)}');

                                        final response = await http.post(
                                          Uri.parse(url),
                                          headers: {
                                            'Content-Type': 'application/json',
                                          },
                                          body: jsonEncode(requestBody),
                                        );

                                        print(
                                            'Response Status Code: ${response.statusCode}');
                                        print(
                                            'Response Body of Booking Date: ${response.body}');

                                        if (response.statusCode == 200) {
                                          final responseData =
                                              jsonDecode(response.body);
                                          if (responseData['status'] ==
                                              'true') {
                                            setState(() {
                                              bookingDates = List<
                                                      Map<String,
                                                          dynamic>>.from(
                                                  responseData['data']);
                                            });
                                            print(
                                                'Parsed Booking Dates: $bookingDates');
                                          } else {
                                            print(
                                                'Failed to fetch booking dates: ${responseData['message']}');
                                          }
                                        } else {
                                          print(
                                              'Failed to fetch booking dates: ${response.statusCode}');
                                        }
                                      } catch (e) {
                                        print(
                                            'Error fetching booking dates: $e');
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return nextFourMonths.map((String month) {
                                        return PopupMenuItem<String>(
                                          value: month,
                                          child: Row(
                                            children: [
                                              Text(month),
                                              const SizedBox(width: 8),
                                              Text(
                                                selectedYear.toString(),
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: CustomColors
                                                        .backgroundtext),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$selectedMonth $selectedYear',
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: CustomColors.backgroundtext,
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down,
                                            color: CustomColors.backgroundtext),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // SizedBox(height: 10),
                    Container(
                      // color: Colors.black,
                      width: double
                          .infinity, // Ensure the container takes the full available width
                      height:
                          120, // You can adjust this height to match your desired layout
                      child: Stack(
                        children: [
                          // Positioned widget with Row inside it
                          Positioned(
                            top: 30,
                            left: 0,
                            child: Row(
                              children: [
                                Container(
                                  width: 40, // Adjust size as needed
                                  height: 40, // Adjust size as needed
                                  decoration: BoxDecoration(
                                    shape: BoxShape
                                        .circle, // Make the shape circular
                                    color: CustomColors.backgroundPrimary,
                                    border: Border.all(
                                      color: CustomColors
                                          .backgroundtext, // Border color
                                      width: 1, // Border width
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_sharp,
                                      color: CustomColors.backgroundtext,
                                    ),
                                    onPressed: _scrollLeft,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                SizedBox(width: 8),
                                _isLoading
                                    ? Center(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6, // 20% of screen width
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,

                                          child:
                                              CupertinoActivityIndicator(), // Show loader
                                        ),
                                      )
                                    : Container(
                                        width: 271.62,
                                        height: 70.62,
                                        decoration: BoxDecoration(
                                          color: CustomColors.backgroundPrimary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: SingleChildScrollView(
                                            controller:
                                                _scrollController, // Set the ScrollController here
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: List.generate(
                                                  bookingDates.length, (index) {
                                                final bookingDate =
                                                    bookingDates[index];
                                                final isAllowed = bookingDate[
                                                        'is_booking_allowed'] ==
                                                    1;
                                                return GestureDetector(
                                                  onTap: isAllowed
                                                      ? () {
                                                          DateTime
                                                              selectedDate =
                                                              DateTime.parse(
                                                                  bookingDate[
                                                                      'date']);
                                                          _onDateSelected(
                                                              selectedDate);
                                                          setState(() {
                                                            _selectedMonthIndex =
                                                                index;
                                                          });
                                                        }
                                                      : null,
                                                  child: Container(
                                                    width: 50,
                                                    height: 50,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      color: _selectedMonthIndex ==
                                                              index
                                                          ? CustomColors
                                                              .backgroundtext // Highlight color for selected date
                                                          : isAllowed
                                                              ? CustomColors
                                                                  .backgroundPrimary
                                                              : Colors
                                                                  .grey, // Grey out unavailable dates
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          bookingDate['day'],
                                                          style: TextStyle(
                                                            color: _selectedMonthIndex ==
                                                                    index
                                                                ? CustomColors
                                                                    .backgroundPrimary
                                                                : isAllowed
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white, // White for disabled dates
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          bookingDate['date']
                                                              .split('-')[2],
                                                          style: TextStyle(
                                                            color: _selectedMonthIndex ==
                                                                    index
                                                                ? CustomColors
                                                                    .backgroundPrimary
                                                                : isAllowed
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white, // White for disabled dates
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      ),
                                SizedBox(width: 8),
                                Container(
                                  width: 40, // Adjust size as needed
                                  height: 40, // Adjust size as needed
                                  decoration: BoxDecoration(
                                    shape: BoxShape
                                        .circle, // Make the shape circular
                                    color: CustomColors.backgroundPrimary,
                                    border: Border.all(
                                      color: CustomColors
                                          .backgroundtext, // Border color
                                      width: 1, // Border width
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: CustomColors.backgroundtext,
                                    ),
                                    onPressed: _scrollRight,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isStylistSelectionPage)
                      Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    // SizedBox(height: 20), // Increased space
                    if (isStylistSelectionPage)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Select Specialist',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.label,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              // Show the dialog with all stylists when "View All" is clicked
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return CupertinoAlertDialog(
                                        title: Text(
                                          'All Stylists',
                                          style: GoogleFonts.lato(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: CupertinoColors.label,
                                          ),
                                        ),
                                        content: Column(
                                          children: [
                                            Divider(
                                              color: CupertinoColors.separator,
                                              thickness: 1,
                                              indent: 0,
                                              endIndent: 0,
                                            ),
                                            SizedBox(
                                              height: 150,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ...stylists.map((stylist) {
                                                      return CupertinoListTile(
                                                        leading: ClipOval(
                                                          child: Image.network(
                                                            stylist['image']!,
                                                            width: 70,
                                                            height: 70,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    progress) {
                                                              if (progress ==
                                                                  null)
                                                                return child;
                                                              return const CupertinoActivityIndicator();
                                                            },
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Icon(
                                                                CupertinoIcons
                                                                    .exclamationmark_triangle,
                                                                color: CupertinoColors
                                                                    .systemRed,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        title: Text(
                                                          stylist['name']!,
                                                          style:
                                                              GoogleFonts.lato(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .label,
                                                          ),
                                                        ),
                                                        trailing:
                                                            stylist['selected']
                                                                ? Icon(
                                                                    CupertinoIcons
                                                                        .checkmark_alt,
                                                                    color: CupertinoColors
                                                                        .activeBlue,
                                                                  )
                                                                : null,
                                                        onTap: () {
                                                          toggleSelection(
                                                              stylists.indexOf(
                                                                  stylist));
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog after selecting
                                                        },
                                                      );
                                                    }).toList(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Close',
                                              style: TextStyle(
                                                color:
                                                    CupertinoColors.systemBlue,
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
                            },
                            child: Text(
                              'View All',
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (isStylistSelectionPage)
                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.17, // Adjust height based on screen height
                        child: CupertinoScrollbar(
                          child: Stack(
                            children: [
                              // Only show the ListView if not loading and if stylists are available
                              if (!_isLoading && stylists.isNotEmpty)
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stylists.length,
                                  itemBuilder: (context, index) {
                                    final stylist = stylists[index];
                                    return GestureDetector(
                                      onTap: () => toggleSelection(index),
                                      child: CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () => toggleSelection(index),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25, // Adjust width to 25% of screen width
                                          margin: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02), // Adjust margin
                                          child: Stack(
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ClipOval(
                                                    child: Image.network(
                                                      stylist['image']!,
                                                      width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.2, // Adjust width dynamically
                                                      height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.2, // Adjust height dynamically
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child, progress) {
                                                        if (progress == null) {
                                                          return child; // Image has finished loading
                                                        }
                                                        return const SizedBox(
                                                          width: 70,
                                                          height: 70,
                                                          child: Center(
                                                            child:
                                                                CupertinoActivityIndicator(),
                                                          ),
                                                        ); // Show loading indicator
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const SizedBox(
                                                          width: 70,
                                                          height: 70,
                                                          child: Center(
                                                            child: Icon(
                                                              CupertinoIcons
                                                                  .exclamationmark_triangle,
                                                              color:
                                                                  CupertinoColors
                                                                      .systemRed,
                                                              size: 40,
                                                            ),
                                                          ),
                                                        ); // Show error icon
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    stylist['name']!,
                                                    style: GoogleFonts.lato(
                                                      fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.04, // Dynamic font size
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          CupertinoColors.label,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    stylist[
                                                        'designation_name']!,
                                                    style: GoogleFonts.lato(
                                                      fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.04, // Dynamic font size
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFF424752),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              if (stylist['selected'])
                                                Positioned(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.0, // Adjust position based on screen height
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02, // Adjust position based on screen width
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: CupertinoColors
                                                          .systemBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                        color: CustomColors
                                                            .backgroundtext,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      CupertinoIcons
                                                          .checkmark_alt,
                                                      color: CustomColors
                                                          .backgroundtext,
                                                      size: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.04, // Adjust icon size based on screen width
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              // Show the loading spinner if _isLoading is true
                              if (_isLoading)
                                Center(
                                  child: CupertinoActivityIndicator(radius: 20),
                                ),
                              // Show the "No stylists available" message if no stylists are found
                              if (!_isLoading &&
                                  stylists.isEmpty &&
                                  _noStylistsMessage.isNotEmpty)
                                Center(
                                  child: Text(
                                    _noStylistsMessage,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    // SizedBox(height: 15),
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),

                    SizedBox(height: 10),
                    Text(
                      'Available Time Slots',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              CustomColors.backgroundtext, // Blue border color
                          width: 1, // Border width
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_newFormatDate',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.backgroundtext,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isLoading)
                      Center(
                          child:
                              CupertinoActivityIndicator()) // Show loading indicator while fetching data
                    else if (_timeSlots.values
                        .any((slots) => slots.isNotEmpty)) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((_timeSlots['morning_slots'] ?? []).isNotEmpty)
                            Expanded(
                              child: _buildTimeSlots(
                                  'Morning', _timeSlots['morning_slots'] ?? []),
                            ),
                          if ((_timeSlots['afternoon_slots'] ?? []).isNotEmpty)
                            Expanded(
                              child: _buildTimeSlots('Afternoon',
                                  _timeSlots['afternoon_slots'] ?? []),
                            ),
                          if ((_timeSlots['evening_slots'] ?? []).isNotEmpty)
                            Expanded(
                              child: _buildTimeSlots(
                                  'Evening', _timeSlots['evening_slots'] ?? []),
                            ),
                        ],
                      ),
                      if (_hasMoreSlots)
                        Center(
                            child:
                                CupertinoActivityIndicator()), // Show loading indicator while fetching more slots
                      if (!_hasMoreSlots)
                        Center(
                          child: Text(
                            'No more slots available',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ] else ...[
                      Center(child: CupertinoActivityIndicator()),
                    ],
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: CustomColors.backgroundPrimary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpcomingPage(),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CustomColors.backgroundtext, // Text color
                    backgroundColor:
                        CustomColors.backgroundPrimary, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Button shape
                      side: BorderSide(
                        color: CustomColors.backgroundtext, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print(
                        "ElevatedButton pressed!"); // Debug log to check if the button is clicked

                    if (_selectedTimeSlot.isEmpty) {
                      // Show error SnackBar if no time slot is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Please select a time slot before proceeding.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      print(
                          "No time slot selected."); // Debug log for no time slot case
                    } else {
                      try {
                        print(
                            "Starting booking process..."); // Debug log to indicate process start

                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Prevent closing the dialog by tapping outside
                          builder: (BuildContext context) {
                            return Center(
                              child:
                                  CupertinoActivityIndicator(), // Show loader
                            );
                          },
                        );

                        await bookStylist(context); // Call the booking function
                        print(
                            "bookStylist function completed."); // Debug log after booking call

                        // Simulate a delay of 3 seconds (can be replaced with actual operation delay)
                        await Future.delayed(Duration(seconds: 3));

                        print(
                            "Finished delay after booking process."); // Debug log after delay
                      } catch (e) {
                        print("Error occurred: $e"); // Debug log for exception
                        // Handle exceptions (e.g., show a SnackBar with the error message)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('An error occurred: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        CustomColors.backgroundtext, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Button shape
                    ),
                  ),
                  child: Text(
                    'Reschedule',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
