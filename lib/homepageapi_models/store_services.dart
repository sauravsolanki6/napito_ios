import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // Ensure this package is included in your pubspec.yaml

// Model class for service categories
class ServiceCategory {
  final String id;
  final String name;
  final String imageUrl;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Factory method to create an instance from JSON
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }

  // Fetch service categories from the API
  static Future<List<ServiceCategory>> fetchServiceCategories() async {
    final errorLogger = ErrorLogger();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      final String? customerId1 = prefs.getString('customer_id');
      final String? customerId2 = prefs.getString('customer_id2');

      final String customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty) {
        throw Exception('No valid customer ID found');
      }

      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/store-service-category/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salon_id': salonID,
          'branch_id': branchID,
          'customer_id': customerId, // Added customer ID here
        }),
      );

      if (response.statusCode == 200) {
        print(
            'Response body of services: ${response.body}'); // Print response body for debugging
        return parseServiceCategories(response.body);
      } else {
        print('Failed to load service categories: ${response.statusCode}');
        log('Response body of servicess: ${response.body}');
        throw Exception('Failed to load service categories');
      }
    } catch (e, stackTrace) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? customerId1 = prefs.getString('customer_id');
      final String? customerId2 = prefs.getString('customer_id2');

      final String customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : 'Unknown';
      await errorLogger.setCustomerId(customerId);

      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "API's -> storefiledetailsInFirestore",
        userId: "user123",
        receiverId: "receiver456",
        // errorDetails: {"request": "fetchData", "responseCode": 500},
        stackTrace: stackTrace,
      );
      print("Error storing file details in Firestore: $e");
      print('Error: $e');
      print('Exception occurred: $e');
      throw Exception('Failed to fetch service categories: $e');
    }
  }

  // Parse JSON response into a list of ServiceCategory
  static List<ServiceCategory> parseServiceCategories(String responseBody) {
    final Map<String, dynamic> jsonData = json.decode(responseBody);

    // Check if 'data' key exists and is a list
    if (jsonData['data'] is List) {
      final List<dynamic> categories = jsonData['data'] as List;
      return categories.map<ServiceCategory>((json) {
        // Adjust the JSON keys to match the model
        return ServiceCategory.fromJson({
          'id': json['category_id'],
          'name': json['name'],
          'image_url': json['image'],
        });
      }).toList();
    } else {
      // Handle unexpected JSON format
      throw Exception('Unexpected JSON format');
    }
  }
}
