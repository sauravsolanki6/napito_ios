import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ms_salon_task/main.dart'; // Import MyApp class to access apiUrl

class SalonDetailsController {
  final String baseUrl = '${MyApp.apiUrl}customer/store-about-us/';
  final String galleryUrl = '${MyApp.apiUrl}customer/store-gallary/';
  final String specialistsUrl = '${MyApp.apiUrl}customer/store-employees/';
  final String reviewsUrl =
      '${MyApp.apiUrl}customer/store-reviews/'; // New URL for reviews

  Future<Map<String, dynamic>> fetchSalonData() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'salon_id': salonId,
          'branch_id': branchId,
        }),
      );

      print('Salon Data Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          final salonData = data['data'];

          // Extract additional data
          final address = salonData['address'] ?? 'No address available';
          final branchName = salonData['branch_name'] ?? 'Unknown';
          final storeLogo = salonData['store_logo'] ?? '';
          final website = salonData['website'] ?? '';
          final image = salonData['image'] ?? '';
          final phoneNumber = salonData['phone_number'] ?? '';

          // Save the data to SharedPreferences
          await prefs.setString('salon_address', address);
          await prefs.setString('branch_name', branchName);
          await prefs.setString('store_logo', storeLogo);
          await prefs.setString('website', website);
          await prefs.setString('image', image);
          await prefs.setString('phone_number', phoneNumber);

          return salonData;
        } else {
          return {'message': 'No data available'};
        }
      } else {
        return {'message': 'Failed to load salon data'};
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> storeProfile",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in storeProfile: $e');
      print('Stack Trace: $stackTrace');
      print('Exception: $e');
      return {'message': 'An error occurred while fetching salon data'};
    }
  }

  Future<List<String>> fetchGalleryImages() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';

      final response = await http.post(
        Uri.parse(galleryUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'salon_id': salonId,
          'branch_id': branchId,
        }),
      );

      print('Gallery Data Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          return List<String>.from(data['data']);
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchgallaryimages",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchgallaryimages: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      // throw Exception('Failed to fetch storeProfile: $e');
      print('Exception: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchSpecialists() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';

      final response = await http.post(
        Uri.parse(specialistsUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'salon_id': salonId,
          'branch_id': branchId,
        }),
      );

      print('Specialists Data Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchSpecialists",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchSpecialists: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      // throw Exception('Failed to fetch storeProfile: $e');
      print('Exception: $e');
      return [];
    }
  }

  Future<List<Review>> fetchReviews() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';

      final response = await http.post(
        Uri.parse(reviewsUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'salon_id': salonId,
          'branch_id': branchId,
        }),
      );

      print('Reviews Data Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          final reviews = data['data'] as List;
          return reviews.map((json) => Review.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchReviews",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchReviews: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      // throw Exception('Failed to fetch storeProfile: $e');
      print('Exception: $e');
      return [];
    }
  }
}

// Review class to parse review data
class Review {
  final int stars;
  final String description;
  final String customerName;
  final String date;
  final String profilePic;

  Review({
    required this.stars,
    required this.description,
    required this.customerName,
    required this.date,
    required this.profilePic,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      stars: int.parse(json['stars'].toString().split('.').first),
      description: json['description'],
      customerName: json['customer_name'],
      date: json['date'],
      profilePic: json['profile_pic'],
    );
  }
}
