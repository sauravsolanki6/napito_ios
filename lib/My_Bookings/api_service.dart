import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ApiService {
  final String baseUrl = '${MyApp.apiUrl}customer/booking-rules/';
  final String timeSlotsUrl = '${MyApp.apiUrl}customer/timeslots/';

  Future<Map<String, dynamic>> fetchBookingRules() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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

    // Prepare request details
    final url = Uri.parse(baseUrl);
    final Map<String, dynamic> requestBody = {
      'customer_id': customerId,
      'branch_id': branchID,
      'salon_id': salonID,
    };

    // Print request
    print('Request URL: $url');
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Print response
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'true') {
        return jsonResponse['data'];
      } else {
        throw Exception('Failed to load booking rules');
      }
    } else {
      throw Exception('Failed to load booking rules');
    }
  }

  // Future<Map<String, dynamic>> fetchTimeSlots(
  //     String bookingDate, int offset) async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
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
  //     final url = Uri.parse(timeSlotsUrl);

  //     // Construct the request body
  //     final requestBody = jsonEncode({
  //       'salon_id': salonID,
  //       'branch_id': branchID,
  //       'customer_id': customerId,
  //       'limit': '14', // Number of slots to fetch
  //       'offset': offset.toString(), // Pagination offset
  //       'booking_date': bookingDate,
  //       'selected_services': serviceIds,
  //     });

  //     // Print the request body
  //     print('URL of timeslots : $url');
  //     print('Request Body: $requestBody');

  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: requestBody,
  //     );

  //     // Print the response status and body
  //     print('Response Status: ${response.statusCode}');
  //     print('Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //       if (jsonResponse['status'] == 'true') {
  //         return jsonResponse['data'];
  //       } else {
  //         throw Exception('Failed to load time slots');
  //       }
  //     } else {
  //       throw Exception('Failed to load time slots');
  //     }
  //   } catch (e) {
  //     print('Error fetching time slots: $e');
  //     return {}; // Return an empty map on error
  //   }
  // }
  Future<Map<String, dynamic>> fetchTimeSlots(
      String bookingDate, int offset, String selectedStylistId) async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
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
      int totalDuration = 0; // Initialize total duration

      // Process JSON 1
      if (selectedServiceDataJson1 != null) {
        final Map<String, dynamic> services1 =
            jsonDecode(selectedServiceDataJson1);
        serviceIds.addAll(
            services1.values.map((service) => service['serviceId'] as String));

        // Calculate total duration
        services1.forEach((key, service) {
          totalDuration += int.parse(service['duration']);
        });
      }

      // Process JSON 2
      if (selectedServiceDataJson2 != null) {
        final Map<String, dynamic> services2 =
            jsonDecode(selectedServiceDataJson2);
        serviceIds.addAll(
            services2.values.map((service) => service['serviceId'] as String));

        // Calculate total duration
        services2.forEach((key, service) {
          totalDuration += int.parse(service['duration']);
        });
      }

      // Save total duration in SharedPreferences
      await prefs.setInt('total_duration_minutes', totalDuration);
      print('Total Duration: $totalDuration minutes');

      final url = Uri.parse(timeSlotsUrl);

      // Construct the request body with the selected stylist ID
      final requestBody = jsonEncode({
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'limit': '14', // Number of slots to fetch
        'offset': offset.toString(), // Pagination offset
        'booking_date': bookingDate,
        'selected_services': serviceIds,
        'stylist_id': selectedStylistId, // Add the stylist ID here
      });

      // Print the request body
      print('URL of time slots: $url');
      log('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Print the response status and body
      print('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          return jsonResponse['data'];
        } else {
          throw Exception('Failed to load time slots');
        }
      } else {
        throw Exception('Failed to load time slots');
      }
    } catch (e, stackTrace) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
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
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchTimeslots",
        userId: customerId,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchtimeslots: $e');
      print('Stack Trace: $stackTrace');
      print('Error fetching time slots: $e');
      return {};
    }
  }
}
