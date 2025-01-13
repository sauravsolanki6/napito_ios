// services/product_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the Product model
class Products {
  final String categoryId;
  final String name;
  final String marathiName;
  final String image;

  Products({
    required this.categoryId,
    required this.name,
    required this.marathiName,
    required this.image,
  });

  // Factory method to create a Product instance from JSON
  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      categoryId: json['category_id'],
      name: json['name'],
      marathiName: json['marathi_name'],
      image: json['image'],
    );
  }
}

// Function to fetch products from the API
Future<List<Products>> fetchProducts() async {
  // Retrieve salon_id and branch_id from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String branchID = prefs.getString('branch_id') ?? '';
  final String salonID = prefs.getString('salon_id') ?? '';

  final response = await http.post(
    // Uri.parse(
    //     '${MyApp.apiUrl}customer/store-product-category/'),
    Uri.parse('${Config.apiUrl}customer/store-product-category/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'salon_id': salonID,
      'branch_id': branchID,
    }),
  );
  log('Response body of products: ${response.body}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> data = jsonResponse['data'];
    return data.map((item) => Products.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}
