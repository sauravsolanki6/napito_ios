import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

// Define the models

class ProductInPackage {
  final String productId;
  final String productName;
  final String image;

  ProductInPackage({
    required this.productId,
    required this.productName,
    required this.image,
  });

  factory ProductInPackage.fromJson(Map<String, dynamic> json) {
    return ProductInPackage(
      productId: json['product_id'].toString(),
      productName: json['product_name'].toString(),
      image: json['image'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image': image,
    };
  }
}

class ServiceInPackage {
  final String serviceId;
  final String serviceName;
  final String serviceMarathiName;
  final String image;
  final String duration;
  final List<ProductInPackage> products;

  ServiceInPackage({
    required this.serviceId,
    required this.serviceName,
    required this.serviceMarathiName,
    required this.image,
    required this.duration,
    required this.products,
  });

  factory ServiceInPackage.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as List;
    List<ProductInPackage> productsList =
        productsJson.map((i) => ProductInPackage.fromJson(i)).toList();

    return ServiceInPackage(
      serviceId: json['service_id'].toString(),
      serviceName: json['service_name'].toString(),
      serviceMarathiName: json['service_marathi_name'].toString(),
      image: json['image'].toString(),
      duration: json['service_duration'].toString(),
      products: productsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'service_marathi_name': serviceMarathiName,
      'image': image,
      'service_duration': duration,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class Package {
  final String packageId;
  final String packageName;
  final String packageNameMarathi;
  final String price;
  final List<ServiceInPackage> services;
  final String description;
  final String image;
  final String durationText;
  final String originalPrice;
  final String discountText;
  final double discountedPrice;
  final String gstRate; // GST rate as a string
  final double gstAmount; // GST amount as a double
  final bool isGstApplicable; // GST applicability as a boolean

  Package({
    required this.packageId,
    required this.packageName,
    required this.packageNameMarathi,
    required this.price,
    required this.services,
    required this.description,
    required this.image,
    required this.durationText,
    required this.originalPrice,
    required this.discountText,
    required this.discountedPrice,
    required this.gstRate,
    required this.gstAmount,
    required this.isGstApplicable,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    var servicesJson = json['services_array'] as List;
    List<ServiceInPackage> servicesList =
        servicesJson.map((i) => ServiceInPackage.fromJson(i)).toList();

    return Package(
      packageId: json['package_id'].toString(),
      packageName: json['package_name'].toString(),
      packageNameMarathi: json['package_name_marathi']?.toString() ?? '',
      price: json['price'].toString(),
      services: servicesList,
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      durationText: json['duration_text'].toString(),
      originalPrice: json['original_price'].toString(),
      discountText: json['discount_text']?.toString() ?? '',
      discountedPrice: (json['discounted_price'] is String)
          ? double.tryParse(json['discounted_price']) ?? 0.0
          : json['discounted_price']?.toDouble() ?? 0.0,
      gstRate: json['salon_gst_rate']?.toString() ?? '',
      gstAmount: (json['gst_amount'] is String)
          ? double.tryParse(json['gst_amount']) ?? 0.0
          : json['gst_amount']?.toDouble() ?? 0.0,
      isGstApplicable:
          json['is_gst_applicable'] == '1', // Convert string to boolean
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'package_name': packageName,
      'package_name_marathi': packageNameMarathi,
      'price': price,
      'services_array': services.map((service) => service.toJson()).toList(),
      'description': description,
      'image': image,
      'duration_text': durationText,
      'original_price': originalPrice,
      'discount_text': discountText,
      'discounted_price': discountedPrice,
      'salon_gst_rate': gstRate,
      'gst_amount': gstAmount,
      'is_gst_applicable':
          isGstApplicable ? '1' : '0', // Convert boolean to string for JSON
    };
  }
}

// Define the ApiController
class StorePackageController {
  final String baseUrl = '${MyApp.apiUrl}customer/store-packages/';
  final String buyPackageUrl = '${MyApp.apiUrl}customer/buy-package/';

  Future<List<Package>> fetchPackages(
      String salonId, String branchId, String customerId) async {
    final url = Uri.parse(baseUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'salon_id': salonId,
      'branch_id': branchId,
      'customer_id': customerId,
    });

    // Print the request body
    print('Request URL: $url');
    print('Request Headers: $headers');
    print('Request Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Print the response body
      print('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'];
        final message = responseData['message'];
        final data = responseData['data'] as List;

        if (status == 'true' && message == 'success') {
          List<Package> packages =
              data.map((item) => Package.fromJson(item)).toList();
          return packages;
        } else {
          throw Exception('Failed to load data. Message: $message');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<String> buyPackage(String salonId, String branchId, String customerId,
      String packageId) async {
    final url = Uri.parse(buyPackageUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'salon_id': salonId,
      'branch_id': branchId,
      'package_id': packageId,
      'customer_id': customerId,
      'payment_status': '1',
      'payment_mode': '0',
    });

    // Print the request URL, headers, and body
    print('Request URL: $url');
    print('Request Headers: $headers');
    print('Request Body: $body');
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final response = await http.post(url, headers: headers, body: body);

      // Print the response body
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final status = responseData['status'];
      final message = responseData['message'];

      if (response.statusCode == 200) {
        if (status == 'true' && message == 'success') {
          return 'Purchase successful';
        } else {
          return '$message';
        }
      } else {
        return 'Failed to buy package. Status code: ${response.statusCode}';
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
      }
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);
      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> buyPackage",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in buyPackage: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
      print('Error: $e');
      return 'Error: $e';
    }
  }
}
