import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Book_appointment/special_services.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/review_summary.dart';
import 'package:ms_salon_task/main.dart';
import 'package:ms_salon_task/select_specialist.dart';
import 'package:ms_salon_task/services/special_services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:shimmer/shimmer.dart';
import '../firebase_crash/Crashannalytics.dart';
import 'api_service.dart'; // Import the ApiService
import 'package:http/http.dart' as http;

class SDateTime extends StatefulWidget {
  @override
  _SelectDateTimeState createState() => _SelectDateTimeState();
}

class _SelectDateTimeState extends State<SDateTime> {
  TextEditingController _dateController = TextEditingController();
  String _selectedTimeSlot = '';
  String _selectedTimeSlotTo = '';
  String _selectedTime = '';
  final ApiService _apiService = ApiService();
  DateTime? _minDate;
  String selectedStylistId = '';
  bool isStylistSelectionPage = false; // Default value

  DateTime? _maxDate;
  Timer? _debounceTimer;
  List<Map<String, dynamic>> selectedStylists = [];
  String? selectedMonth;
  List<Map<String, dynamic>> stylists = [];
  String _noStylistsMessage = '';
  List<dynamic> stylistsData = [];
  String profilePath = '';
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
        "booking_date": formattedDate,
        "selected_services": serviceIds,
      };

      log('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse("${MyApp.apiUrl}customer/booking-stylists/"),
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
      print("Selected Stylist ID: $selectedStylistId");
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selected_stylist_id', selectedStylistId);
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
  final Duration _debounceDuration =
      Duration(milliseconds: 300); // Adjust as needed
  int _selectedMonthIndex = 0;

  List<String> dates = List.generate(31, (index) => '${index + 1}');
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Map<String, List<dynamic>> _timeSlots = {
    'morning_slots': [],
    'afternoon_slots': [],
    'evening_slots': []
  };
  bool _isLoading = true;
  bool _hasMoreSlots = true;
  int _offset = 0;
  String _formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String _newFormatDate = '';
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
    fetchStylists(_formattedDate);
    _fetchBookingRules();
    _loadSelectedTimeSlot();
    _fetchBookingDates();
    _initializePage();
    DateTime now = DateTime.now();
    selectedMonth = DateFormat('MMMM').format(DateTime.now());
    selectedYear = now.year;
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - (50 + 8),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
            : ''; // Fallback to empty string if both are null or empty

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
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

    final String? packageDataJson =
        prefs.getString('selected_package_data_add_package');
    if (packageDataJson != null) {
      final Map<String, dynamic> packageData = jsonDecode(packageDataJson);
      final List<dynamic> servicesArray = packageData['services_array'];
      serviceIds.addAll(
          servicesArray.map((service) => service['service_id'] as String));
    }

    if (serviceIds.isEmpty) {
      throw Exception('No valid services found');
    }

    serviceIds = serviceIds.toSet().toList();

    final Map<String, dynamic> requestBody = {
      "salon_id": salonID,
      "branch_id": branchID,
      "customer_id": customerId,
      "selected_slot_from": selectedSlotFrom,
      "selected_slot_to": selectedSlotTo,
      "booking_date": bookingDate,
      "selected_services": serviceIds,
      "stylist_id": selectedStylistId,
    };

    final String apiUrl = '${MyApp.apiUrl}customer/booking-stylists-review/';

    // Print request body for debugging
    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Print the response body for debugging
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody is Map<String, dynamic>) {
            final stylistData = responseBody['data'];

            // Ensure stylistData is a list
            if (stylistData is List) {
              List<Map<String, dynamic>> updatedStylistData = [];
              List<Map<String, String>> stylistServiceList = [];

              for (var item in stylistData) {
                if (item is Map<String, dynamic>) {
                  updatedStylistData.add({
                    'service_id': item['service_id'],
                    'stylist_id': item['selected_stylist_id'],
                    'stylist_shift_id': item['selected_stylist_shift_id'],
                    'stylist_shift_type': item['selected_stylist_shift_type'],
                  });

                  stylistServiceList.add({
                    'selected_stylist':
                        item['selected_stylist_name'] ?? 'Unknown Stylist',
                    'selected_service':
                        item['service_name'] ?? 'Unknown Service',
                  });
                }
              }

              // Store the updated stylist data in shared preferences
              await prefs.setString(
                  'selected_stylist_data_list', jsonEncode(updatedStylistData));

              // Store the stylist and service data in shared preferences
              await prefs.setString('stylist_service_data_stored',
                  jsonEncode(stylistServiceList));

              // Store the response body in shared preferences
              await prefs.setString('response_body', response.body);

              print('Stored Data: ${jsonEncode(stylistServiceList)}');

              // Navigate to ReviewSummary page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewSummary(),
                ),
              );
            } else {
              throw Exception('Response data is not a list as expected');
            }
          } else {
            throw Exception('Response body is not a valid map');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error decoding response: $e')),
          );
        }
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

  void _scrollRight() {
    // Scroll right by the width of a date item (50 + 8 for margins)
    _scrollController.animateTo(
      _scrollController.offset + (50 + 8),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchBookingDates() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
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
        if (responseData['status'] == 'true' && responseData['data'] != null) {
          if (!mounted) return; // Check if the widget is mounted
          try {
            setState(() {
              bookingDates =
                  List<Map<String, dynamic>>.from(responseData['data']);
            });
          } catch (e) {
            print('Error in setState: $e');
          }
          print('Parsed Booking Dates: $bookingDates');
        } else {
          print('Failed to fetch booking dates: ${responseData['message']}');
          _showErrorMessage(
              responseData['message']); // Show error message to the user
        }
      } else {
        print('Failed to fetch booking dates: ${response.statusCode}');
        _showErrorMessage(
            'Failed to fetch booking dates. Please try again later.');
      }
    } catch (e, stackTrace) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchBookingDates",
        // userId: customerID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in BookingDates: $e');
      print('Stack Trace: $stackTrace');
      print('Error fetching booking dates: $e');
      _showErrorMessage(
          'Error fetching booking dates: $e'); // Show the error to the user
      // Re-throw the exception to ensure higher-level error handling
      throw Exception('Failed to fetch BookingDates: $e');
    }
  }

// Function to show the error message to the user
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

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

    // Fetch booking dates (Uncomment this to fetch the booking dates when the page initializes)
    await _fetchBookingDates();
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

  void _fetchBookingDatesForSelectedMonth(String month) {
    if (bookingDates.isNotEmpty) {
      // Select the first date available after fetching
      DateTime selectedDate = DateTime.parse(bookingDates[0]['date']);
      _onDateSelected(selectedDate);
      setState(() {
        _selectedMonthIndex = 0; // Optionally set to the first date
      });
    }
  }

  Future<void> _handleStoreStylistSelection(BuildContext context) async {
    try {
      // Retrieve SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Retrieve customer and salon information
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

      // Retrieve selected services
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

      // Retrieve and parse 'selected_package_data_add_package' from SharedPreferences
      final String? packageDataJson =
          prefs.getString('selected_package_data_add_package');
      if (packageDataJson != null) {
        final Map<String, dynamic> packageData = jsonDecode(packageDataJson);
        final List<dynamic> servicesArray = packageData['services_array'];
        serviceIds.addAll(
            servicesArray.map((service) => service['service_id'] as String));
      }

      if (serviceIds.isEmpty) {
        throw Exception('No valid services found');
      }

      // Remove duplicate service IDs by converting the list to a Set and back to a list
      serviceIds = serviceIds.toSet().toList();

      // Validate selected time slot
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

      // Validate booking date
      final String? bookingDate = prefs.getString('selected_date');
      if (bookingDate == null || bookingDate.isEmpty) {
        throw Exception('No valid booking date found');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'selected_slot_from': selectedSlotFrom,
        'selected_slot_to': selectedSlotTo,
        'booking_date': bookingDate,
        'selected_services': serviceIds,
      };

      // Print URL and request body for debugging
      // print('Request URL: ${MyApp.apiUrl}/customer/store-stylist-selection/');
      print('Request Body: ${jsonEncode(requestBody)}');

      // Make the API call
      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}/customer/store-stylist-selection/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Print response status and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        // Successfully received response
        final responseData = json.decode(response.body);

        print('Response data: $responseData');
        log("******************* ${jsonEncode(responseData)}***********************");
        // Store the entire response data in SharedPreferences
        await prefs.setString('response_body', jsonEncode(responseData));
        await prefs.setString(
            'stylist_selection_response', jsonEncode(responseData));
        if (responseData['data'] != null &&
            responseData['data']['service_stylists_data'] != null) {
          // Parse the service stylists data
          List<dynamic> serviceStylistsData =
              responseData['data']['service_stylists_data'];

          // Initialize a list to store each service and stylist entry in the desired format
          List<Map<String, String>> stylistList = [];

          for (var service in serviceStylistsData) {
            String serviceId = service['service_name'] ??
                'Unknown'; // Use service ID instead of service name
            var selectedStylists = service['selected_stylists'];

            // Ensure selectedStylists is valid
            if (selectedStylists != null) {
              String stylistName =
                  selectedStylists['stylist_name'] ?? 'Stylist';

              // Add each service-stylist entry to the list
              stylistList.add({
                'selected_stylist': stylistName,
                'selected_service': serviceId,
              });
            }
          }

          // Convert the list to JSON format and print it
          String stylistDataJson = jsonEncode(stylistList);
          print('Stored Data: $stylistDataJson');

          // Optionally save the JSON data to SharedPreferences
          await prefs.setString('stylist_service_data_stored', stylistDataJson);
        }

        if (responseData['data'] != null &&
            responseData['data']['service_stylists_data'] != null) {
          // Parse and save stylist data
          List<dynamic> serviceStylistsData =
              responseData['data']['service_stylists_data'];

          // Initialize a map to store the stylist IDs and names
          Map<String, List<String>> stylistMap = {};

          for (var service in serviceStylistsData) {
            String serviceId = service['service_id'];
            var selectedStylists = service['selected_stylists'];

            // Extract stylist name and ID if available
            if (selectedStylists != null &&
                selectedStylists['stylist_name'] != null) {
              String stylistName = selectedStylists['stylist_name'];

              // Save the stylist name in the map under the service ID
              stylistMap[serviceId] = [stylistName];
            }
          }

          // Convert the map to JSON format and save it in SharedPreferences
          String stylistDataJson = jsonEncode(stylistMap);
          await prefs.setString('selected_stylists', stylistDataJson);

          // Debugging: Print the saved stylist data
          print('Saved stylist data: $stylistDataJson');

          // Continue with your navigation logic
          if (responseData['data']['is_stylist_selection_page'] != null) {
            String isStylistSelectionPage =
                responseData['data']['is_stylist_selection_page'].toString();

            if (isStylistSelectionPage == "1") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecialistPage(),
                ),
              );
            } else {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SpecialistPage(),
              //   ),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewSummary(),
                ),
              );
            }
          } else {
            print(
                'Data or is_stylist_selection_page key is missing in the response.');
          }
        } else {
          print('Service stylists data is missing in the response.');
        }
      } else {
        // Handle error response
        print('Error: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please try again. or Select a diffrent slot'),
          backgroundColor: Colors.red,
        ),
      );
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

    // Call fetchStylists() with the selected formatted date
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
        // Navigate to SDateTime when back button is pressed
        // Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SpecialServices(),
          ),
        );
        return false; // Prevent default back navigation
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
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           SpecialServices()), // Adjust the destination as needed
                  // );
                },
              ),
              Text(
                'Select Date and Time',
                style: GoogleFonts.lato(
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
                    offset: _offset, selectedStylistId: selectedStylistId);
                // Fetch more time slots when scrolled to bottom
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
                                            8), // Space between icon and text
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
                                          await SharedPreferences.getInstance();
                                      final String branchID =
                                          prefs.getString('branch_id') ?? '';
                                      final String salonID =
                                          prefs.getString('salon_id') ?? '';

                                      if (branchID.isEmpty || salonID.isEmpty) {
                                        print('Branch ID or Salon ID is empty');
                                        return;
                                      }

                                      final String twoDigitMonth =
                                          monthMapping[selectedMonth] ?? '';
                                      final Map<String, dynamic> requestBody = {
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
                                        if (responseData['status'] == 'true') {
                                          setState(() {
                                            bookingDates =
                                                List<Map<String, dynamic>>.from(
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
                                      print('Error fetching booking dates: $e');
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
                                      color: CustomColors.backgroundtext),
                                  onPressed: _scrollLeft,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              SizedBox(width: 8),
                              _isLoading
                                  ? Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6, // 20% of screen width
                                        height:
                                            MediaQuery.of(context).size.width *
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
                                        borderRadius: BorderRadius.circular(5),
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
                                                        DateTime selectedDate =
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
                                                      .symmetric(horizontal: 4),
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
                                                                  ? Colors.black
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
                                                                  ? Colors.black
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
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      color: CustomColors.backgroundtext),
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
                                            height: 160,
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
                                                              color:
                                                                  CupertinoColors
                                                                      .systemRed,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      title: Text(
                                                        stylist['name']!,
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: CupertinoColors
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
                                                        toggleSelection(stylists
                                                            .indexOf(stylist));
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
                                              color: CupertinoColors.systemBlue,
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
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        CupertinoColors.label,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  stylist['designation_name']!,
                                                  style: GoogleFonts.lato(
                                                    fontSize: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width *
                                                        0.04, // Dynamic font size
                                                    fontWeight: FontWeight.w400,
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
                                                    size: MediaQuery.of(context)
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
                        color: CustomColors.backgroundtext, // Blue border color
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
                    if (_hasMoreSlots && !_isLoading)
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
              Container(
                width: 135, // Set width to 135 pixels
                height: 40, // Set height to 40 pixels
                // margin: EdgeInsets.only(top: 1326, left: 258), // Set the top and left margins
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecialServices(),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CustomColors.backgroundtext, // Text color
                    backgroundColor: CustomColors
                        .backgroundPrimary, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          6), // Set border radius to 6 pixels
                      side: BorderSide(
                          color: CustomColors.backgroundtext), // Border color
                    ),
                    padding: EdgeInsets.zero, // Remove default padding
                    elevation: 0, // Remove elevation for a flat look
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.lato(
                      fontSize: 14, // Adjust font size for the button text
                      color: CustomColors.backgroundtext,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                width: 135, // Set width to 135 pixels
                height: 40, // Set height to 40 pixels
                child: ElevatedButton(
                  onPressed: () async {
                    // Check if no time slot is selected
                    if (_selectedTimeSlot.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors
                                    .red, // Set the background color to red
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/napito.jpg', // Replace with your image asset path
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                                  const SizedBox(
                                      width:
                                          8.0), // Space between image and text
                                  const Text(
                                    'Please Select a Time Slot ',
                                    style: TextStyle(
                                        color: Colors
                                            .white), // Set the text color to white
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }

                    // Check if no stylist is selected
                    else if (!stylists
                        .any((stylist) => stylist['selected'] == true)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors
                                    .red, // Set the background color to red
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/napito.jpg', // Replace with your image asset path
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                                  const SizedBox(
                                      width:
                                          8.0), // Space between image and text
                                  const Text(
                                    'Please Select a Stylist',
                                    style: TextStyle(
                                        color: Colors
                                            .white), // Set the text color to white
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      await bookStylist(context);
                      // Proceed if both time slot and stylist are selected
                      // await _handleStoreStylistSelection(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        CustomColors.backgroundtext, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          6), // Button shape with 6px radius
                    ),
                    elevation: 0, // Remove elevation for flat look
                    padding: EdgeInsets.zero, // Remove default padding
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
