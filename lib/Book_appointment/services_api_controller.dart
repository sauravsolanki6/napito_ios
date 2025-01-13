import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';

// Define the models
class Product {
  final String serviceId;
  final String productId;
  final String price;
  final String productName;
  final String image;
  final String productPrice;

  Product(
      {required this.serviceId,
      required this.productId,
      required this.price,
      required this.productName,
      required this.image,
      required this.productPrice});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      serviceId: json['service_id'].toString(), // Ensure it's a string
      productId: json['product_id'].toString(), // Ensure it's a string
      price: json['price'].toString(), // Ensure it's a string
      productName: json['product_name'].toString(), // Ensure it's a string
      image: json['image'].toString(),
      productPrice: json['price'].toString(), // Ensure it's a string
    );
  }
}

class Service {
  final String isSpecial;
  final String serviceId;
  final String categoryId;
  final String subCategoryId;
  final String serviceName;
  final String serviceMarathiName;
  final String image;
  final String categoryName;
  final String subCategoryName;
  final String categoryMarathiName;
  final String subCategoryMarathiName;
  final List<Product> products;
  final String serviceDescription;
  final String serviceDuration;
  final String rewardPoints;
  final String price;
  final String isOfferApplied;
  final String appliedOfferId;
  final String serviceAddedFrom;

  Service({
    required this.isSpecial,
    required this.serviceId,
    required this.categoryId,
    required this.subCategoryId,
    required this.serviceName,
    required this.serviceMarathiName,
    required this.image,
    required this.categoryName,
    required this.subCategoryName,
    required this.categoryMarathiName,
    required this.subCategoryMarathiName,
    required this.products,
    required this.serviceDescription,
    required this.serviceDuration,
    required this.rewardPoints,
    required this.price,
    required this.isOfferApplied,
    required this.appliedOfferId,
    required this.serviceAddedFrom,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as List;
    List<Product> productsList =
        productsJson.map((i) => Product.fromJson(i)).toList();

    return Service(
      isSpecial: json['is_special'].toString(),
      serviceId: json['service_id'].toString(),
      categoryId: json['category_id'].toString(),
      subCategoryId: json['sub_category_id'].toString(),
      serviceName: json['service_name'].toString(),
      serviceMarathiName: json['service_marathi_name'].toString(),
      image: json['image'].toString(),
      categoryName: json['category_name'].toString(),
      subCategoryName: json['sub_category_name'].toString(),
      categoryMarathiName: json['category_marathi_name'].toString(),
      subCategoryMarathiName: json['sub_category_marathi_name'].toString(),
      products: productsList,
      serviceDescription: json['service_description'].toString(),
      serviceDuration: json['service_duration'].toString(),
      rewardPoints: json['discount_text'].toString(),
      price: json['price'].toString(),
      isOfferApplied: json['is_offer_applied'].toString(),
      appliedOfferId: json['applied_offer_id'].toString(),
      serviceAddedFrom: json['service_added_from'].toString(),
    );
  }
}

class SubCategory {
  final String subCategoryId;
  final String subCategoryName;
  final String subCategoryMarathiName;
  final String image;
  final List<Service> services;
  bool isExpanded; // Track expansion state

  SubCategory({
    required this.subCategoryId,
    required this.subCategoryName,
    required this.subCategoryMarathiName,
    required this.image,
    required this.services,
    this.isExpanded = false, // Default to collapsed
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    var servicesJson =
        json['services'] as List? ?? []; // Handle null or missing field
    List<Service> servicesList =
        servicesJson.map((i) => Service.fromJson(i)).toList();

    return SubCategory(
      subCategoryId: json['sub_category_id'].toString(),
      subCategoryName: json['sub_category_name'].toString(),
      subCategoryMarathiName: json['sub_category_marathi_name'].toString(),
      image: json['sub_category_image']?.toString() ?? '',
      services: servicesList,
    );
  }
}

class Category {
  final String categoryId;
  final String categoryName;
  final String categoryMarathiName;
  final String image;
  final List<Service> services;
  final List<SubCategory> subCategories;
  bool isExpanded;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.categoryMarathiName,
    required this.image,
    required this.services,
    required this.subCategories,
    this.isExpanded = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var servicesJson =
        json['services'] as List? ?? []; // Handle null or missing field
    List<Service> servicesList =
        servicesJson.map((i) => Service.fromJson(i)).toList();

    var subCategoriesJson =
        json['sub_categories'] as List? ?? []; // Handle null or missing field
    List<SubCategory> subCategoriesList =
        subCategoriesJson.map((i) => SubCategory.fromJson(i)).toList();

    return Category(
      categoryId: json['category_id'].toString(),
      categoryName: json['category_name'].toString(),
      categoryMarathiName: json['category_marathi_name'].toString(),
      image: json['image']?.toString() ?? '',
      services: servicesList,
      subCategories: subCategoriesList,
    );
  }
}

// Define the ApiController
class ServicesApiController {
  final String baseUrl = '${MyApp.apiUrl}customer/booking-services/';
  Future<List<Category>> fetchBookingServices(
      String salonID, String branchID, String customerID) async {
    final url = Uri.parse(baseUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerID,
    });

    final errorLogger = ErrorLogger(); // Initialize the error logger

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'];
        final message = responseData['message'];
        final data = responseData['data'] as List;
        print('Response Status Code: ${response.statusCode}');
        log('Response Body: ${response.body}');
        if (status == 'true' && message == 'success') {
          List<Category> categories =
              data.map((item) => Category.fromJson(item)).toList();
          return categories;
        } else {
          throw Exception('Failed to load data. Message: $message');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // Log branch and salon IDs in case of an error
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchBookingServices",
        userId: customerID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging purposes
      print('Error in fetchBookingServices: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      throw Exception('Error fetching booking services: $e');
    }
  }
}
