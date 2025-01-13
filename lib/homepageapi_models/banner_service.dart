import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// Model
class BannerResponse {
  final bool status;
  final String message;
  final List<String> data;

  BannerResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      status: json['status'] == 'true',
      message: json['message'],
      data: List<String>.from(json['data']),
    );
  }
}

// Service
Future<List<String>> fetchBannerImages(String salonID, String branchID) async {
  final errorLogger = ErrorLogger(); // Initialize the error logger
  try {
    final url = Uri.parse('${MyApp.apiUrl}customer/banner');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'salon_id': salonID,
        'branch_id': branchID,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      final bannerResponse = BannerResponse.fromJson(responseJson);

      if (bannerResponse.status) {
        return bannerResponse.data;
      } else {
        throw Exception('Failed to load banner: ${bannerResponse.message}');
      }
    } else {
      throw Exception('Failed to load banners');
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
