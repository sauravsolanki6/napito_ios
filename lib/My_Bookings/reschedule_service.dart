import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService2 {
  final String baseUrl = '${MyApp.apiUrl}customer/booking-rules/';
  final String timeSlotsUrl = '${MyApp.apiUrl}customer/reschedule-timeslots/';

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
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'branch_id': branchID,
        'salon_id': salonID,
      }),
    );
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

  Future<Map<String, dynamic>> fetchTimeSlots(
      String bookingDate, int offset, String selectedStylistId) async {
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

      final url = Uri.parse(timeSlotsUrl);
      final Map<String, dynamic> requestBodyMap = {
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'limit': '18', // Number of slots to fetch
        'offset': offset.toString(), // Pagination offset
        'booking_id': bookingId,
        'booking_date': bookingDate,
        'reschedule_details': rescheduleDetails,
        'stylist_id': selectedStylistId, // Add the stylist ID here
      };

      // Convert request body to JSON string
      final String requestBody = jsonEncode(requestBodyMap);

      // Print the request body for debugging
      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
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
    } catch (e) {
      print('Error fetching time slots: $e');
      return {}; // Return an empty map on error
    }
  }
}
