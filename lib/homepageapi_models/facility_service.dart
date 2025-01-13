// facility_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model Classes
class FacilityModel {
  final String title;
  final String icon;

  FacilityModel({
    required this.title,
    required this.icon,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      title: json['title'] as String,
      icon: json['icon'] as String,
    );
  }
}

class FacilityResponse {
  final String status;
  final String message;
  final List<FacilityModel> data;

  FacilityResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FacilityResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<FacilityModel> facilities =
        list.map((i) => FacilityModel.fromJson(i)).toList();

    return FacilityResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: facilities,
    );
  }
}

// API Service Class
class ApiService {
  Future<FacilityResponse> fetchFacilities() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      final response = await http.post(
        Uri.parse(
            '${Config.apiUrl}customer/store-facility/'), // Use Config.apiUrl here
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'salon_id': salonID,
          'branch_id': branchID,
        }),
      );

      print('Request Body: ${jsonEncode({
            'salon_id': salonID,
            'branch_id': branchID,
          })}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return FacilityResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load facilities');
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      await errorLogger.setBranchId(branchID);
      await errorLogger.setSalonId(salonID);
      // Log error with detailed information
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "API -> fetchTips",
        userId:
            "Unknown User", // You can replace this with actual user ID if available
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception
      throw Exception('Failed to fetch facilities: $e');
    }
  }
}
