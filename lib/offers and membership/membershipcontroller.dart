import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ms_salon_task/main.dart';

class MembershipController {
  final String apiUrl = '${MyApp.apiUrl}customer/store-memberships/';
  final String buyMembershipUrl = '${MyApp.apiUrl}customer/buy-membership/';
  final String membershipDetailsUrl = '${MyApp.apiUrl}customer/membership/';

  List<dynamic> _memberships = [];
  List<dynamic> get memberships => _memberships;

  Future<void> fetchMembershipData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty || branchId.isEmpty || salonId.isEmpty) {
        print('Missing required parameters.');
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'salon_id': salonId,
          'branch_id': branchId,
          'customer_id': customerId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'true') {
          _memberships = data['data'];
          print('Fetched memberships: $_memberships');
        } else {
          print('Failed to fetch memberships: ${data['message']}');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching membership data: $e');
    }
  }

  Future<bool> buyMembership(String membershipId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';
      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty || branchId.isEmpty || salonId.isEmpty) {
        print('Missing required parameters.');
        return false;
      }

      final response = await http.post(
        Uri.parse(buyMembershipUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'salon_id': salonId,
          'branch_id': branchId,
          'membership_id': membershipId,
          'customer_id': customerId,
          'payment_status': '1', // static value
          'payment_mode': '0' // static value
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'true') {
          print('Buy Membership Response: $data');
          return true; // Return true if successful
        } else {
          print('Failed to buy membership: ${data['message']}');
          return false;
        }
      } else {
        print('Failed to buy membership. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error buying membership: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchMembershipDetails() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';
      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty || branchId.isEmpty || salonId.isEmpty) {
        print('Missing required parameters.');
        return null;
      }

      final response = await http.post(
        Uri.parse(membershipDetailsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'salon_id': salonId,
          'branch_id': branchId,
          'customer_id': customerId,
        }),
      );
      print('Raw response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'true') {
          print('Membership Details Response: $data');
          return data['data']; // Return the membership details
        } else {
          print('Failed to fetch membership details: ${data['message']}');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
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
        return null;
      }
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);
      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchMembershipDetails",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchMembershipDetails: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      // throw Exception('Failed to fetch storeProfile: $e');
      print('Error fetching membership details: $e');
      return null;
    }
  }
}
