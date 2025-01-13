import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_crash/Crashannalytics.dart';

// Define your data models

class ProductInPackage {
  final String productId;
  final String productName;
  final String price;
  final String image;

  ProductInPackage({
    required this.productId,
    required this.productName,
    required this.price,
    required this.image,
  });

  factory ProductInPackage.fromJson(Map<String, dynamic> json) {
    return ProductInPackage(
      productId: json['product_id'].toString(),
      productName: json['product_name'].toString(),
      price: json['price']?.toString() ?? '',
      image: json['image'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'image': image,
    };
  }
}

class ServiceInPackage {
  final String isSpecial;
  final String serviceId;
  final String isServiceAvailable;
  final String packageDetailsId;
  final String serviceName;
  final String serviceMarathiName;
  final String serviceRewards;
  final String duration;
  final String serviceAddedFrom;
  final String price;
  final String image;
  final String packageId;
  final String packageAllocationId;
  final String isOldPackage;
  final List<ProductInPackage> products;

  ServiceInPackage({
    required this.isSpecial,
    required this.serviceId,
    required this.isServiceAvailable,
    required this.packageDetailsId,
    required this.serviceName,
    required this.serviceMarathiName,
    required this.serviceRewards,
    required this.duration,
    required this.serviceAddedFrom,
    required this.price,
    required this.image,
    required this.products,
    required this.packageId,
    required this.packageAllocationId,
    required this.isOldPackage,
  });

  factory ServiceInPackage.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as List;
    List<ProductInPackage> productsList =
        productsJson.map((i) => ProductInPackage.fromJson(i)).toList();

    return ServiceInPackage(
      isSpecial: json['is_special'].toString(),
      serviceId: json['service_id'].toString(),
      isServiceAvailable: json['is_service_available']?.toString() ?? '',
      packageDetailsId: json['package_details_id']?.toString() ?? '',
      serviceName: json['service_name'].toString(),
      serviceMarathiName: json['service_name_marathi']?.toString() ?? '',
      serviceRewards: json['service_rewards']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      serviceAddedFrom: json['service_added_from']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? '',
      packageAllocationId: json['package_allocation_id']?.toString() ?? '',
      isOldPackage: json['is_old_package']?.toString() ?? '',
      products: productsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'is_service_available': isServiceAvailable,
      'package_details_id': packageDetailsId,
      'service_name': serviceName,
      'service_name_marathi': serviceMarathiName,
      'service_rewards': serviceRewards,
      'duration': duration,
      'service_added_from': serviceAddedFrom,
      'price': price,
      'image': image,
      'package_id': packageId,
      'package_allocation_id': packageAllocationId,
      'is_old_package': isOldPackage,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

class Package {
  final String packageId;
  final String packageAllocationId;
  final String packageName;
  final String packageNameMarathi;
  final String price;
  final String isOldPackage;
  final List<ServiceInPackage> services;
  final String description;
  final String image;

  Package({
    required this.packageId,
    required this.packageAllocationId,
    required this.packageName,
    required this.packageNameMarathi,
    required this.price,
    required this.isOldPackage,
    required this.services,
    required this.description,
    required this.image,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    var servicesJson = json['services'] as List;
    List<ServiceInPackage> servicesList =
        servicesJson.map((i) => ServiceInPackage.fromJson(i)).toList();

    return Package(
      packageId: json['package_id'].toString(),
      packageAllocationId: json['package_allocation_id']?.toString() ?? '',
      packageName: json['package_name'].toString(),
      packageNameMarathi: json['package_name_marathi']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      isOldPackage: json['is_old_package']?.toString() ?? '',
      services: servicesList,
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'package_allocation_id': packageAllocationId,
      'package_name': packageName,
      'package_name_marathi': packageNameMarathi,
      'price': price,
      'is_old_package': isOldPackage,
      'services': services.map((s) => s.toJson()).toList(),
      'description': description,
      'image': image,
    };
  }
}

// Shared Preferences Data Model
class SharedPrefData {
  final String packageId;
  final String packageName;
  final String price;
  final String? isOldPackage;
  final String description;
  final String image;
  final List<Map<String, dynamic>> servicesArray;

  SharedPrefData({
    required this.packageId,
    required this.packageName,
    required this.price,
    this.isOldPackage,
    required this.description,
    required this.image,
    required this.servicesArray,
  });

  factory SharedPrefData.fromJson(Map<String, dynamic> json) {
    var servicesArrayJson = json['services_array'] as List;
    return SharedPrefData(
      packageId: json['package_id'].toString(),
      packageName: json['package_name'].toString(),
      price: json['price']?.toString() ?? '',
      isOldPackage: json['is_old_package']?.toString(),
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      servicesArray: servicesArrayJson.cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'package_name': packageName,
      'price': price,
      'is_old_package': isOldPackage,
      'description': description,
      'image': image,
      'services_array': servicesArray,
    };
  }
}

// Controller Class
class PackageApiController {
  Future<List<Package>> fetchPackages(
      String salonID, String branchID, String customerID) async {
    const String baseUrl = '${MyApp.apiUrl}/customer/packages/';
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
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'];
        final message = responseData['message'];
        final data = responseData['data'] as List;

        if (status == 'true' && message == 'success') {
          List<Package> packages =
              data.map((item) => Package.fromJson(item)).toList();

          // Try to get shared preferences data
          SharedPrefData? sharedPrefData;
          try {
            sharedPrefData = await getSharedPrefData();
            // Print data for debugging
            print('Shared Pref Data: ${sharedPrefData.toJson()}');
          } catch (e) {
            print('Error fetching shared preferences data: $e');
            // If shared preferences data is not available, use API response only
            sharedPrefData = null;
          }

          if (sharedPrefData != null) {
            // Merge packages if shared preferences data is available
            packages = mergePackages(packages, sharedPrefData);
          }

          // Print merged packages or API packages
          print('Packages After Merge or API Packages:');
          packages.forEach((pkg) {
            print(packageToString(pkg));
          });

          return packages;
        } else {
          throw Exception('API response status is not successful.');
        }
      } else {
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchPackages",
        userId: customerID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in fetchPackages: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      throw Exception('Failed to fetch packages: $e');
    }
  }

  String packageToString(Package package) {
    // Construct a string representation of the package for debugging
    var services = package.services.map((s) => s.serviceName).join(', ');
    return 'Package ID: ${package.packageId}, Name: ${package.packageName}, Services: [$services]';
  }

  Future<SharedPrefData> getSharedPrefData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('sharedPrefData');

    if (jsonString != null) {
      final jsonData = jsonDecode(jsonString);
      return SharedPrefData.fromJson(jsonData);
    } else {
      throw Exception('No shared preferences data found.');
    }
  }

  List<Package> mergePackages(
      List<Package> apiPackages, SharedPrefData sharedPrefData) {
    var packageMap = {for (var pkg in apiPackages) pkg.packageId: pkg};

    var sharedPrefPackage = Package(
      packageId: sharedPrefData.packageId,
      packageAllocationId: '',
      packageName: sharedPrefData.packageName,
      packageNameMarathi: '',
      price: sharedPrefData.price,
      isOldPackage: sharedPrefData.isOldPackage ?? '',
      services: [],
      description: sharedPrefData.description,
      image: sharedPrefData.image,
    );

    var sharedPrefServices = sharedPrefData.servicesArray
        .map((serviceJson) => ServiceInPackage.fromJson(serviceJson))
        .toList();

    for (var service in sharedPrefServices) {
      var existingPackage = packageMap[sharedPrefData.packageId];
      if (existingPackage != null) {
        var existingServices = existingPackage.services;
        var serviceMap = {for (var svc in existingServices) svc.serviceId: svc};

        for (var sharedPrefService in sharedPrefServices) {
          if (serviceMap.containsKey(sharedPrefService.serviceId)) {
            var existingService = serviceMap[sharedPrefService.serviceId]!;

            serviceMap[sharedPrefService.serviceId] = ServiceInPackage(
              isSpecial: sharedPrefService.isSpecial,
              serviceId: sharedPrefService.serviceId,
              isServiceAvailable:
                  sharedPrefService.isServiceAvailable.isNotEmpty
                      ? sharedPrefService.isServiceAvailable
                      : existingService.isServiceAvailable,
              packageDetailsId: sharedPrefService.packageDetailsId.isNotEmpty
                  ? sharedPrefService.packageDetailsId
                  : existingService.packageDetailsId,
              serviceName: sharedPrefService.serviceName.isNotEmpty
                  ? sharedPrefService.serviceName
                  : existingService.serviceName,
              serviceMarathiName:
                  sharedPrefService.serviceMarathiName.isNotEmpty
                      ? sharedPrefService.serviceMarathiName
                      : existingService.serviceMarathiName,
              serviceRewards: sharedPrefService.serviceRewards.isNotEmpty
                  ? sharedPrefService.serviceRewards
                  : existingService.serviceRewards,
              duration: sharedPrefService.duration.isNotEmpty
                  ? sharedPrefService.duration
                  : existingService.duration,
              serviceAddedFrom: sharedPrefService.serviceAddedFrom.isNotEmpty
                  ? sharedPrefService.serviceAddedFrom
                  : existingService.serviceAddedFrom,
              price: sharedPrefService.price.isNotEmpty
                  ? sharedPrefService.price
                  : existingService.price,
              image: sharedPrefService.image.isNotEmpty
                  ? sharedPrefService.image
                  : existingService.image,
              packageId: sharedPrefService.packageId,
              packageAllocationId: sharedPrefService.packageAllocationId,
              isOldPackage: sharedPrefService.isOldPackage.isNotEmpty
                  ? sharedPrefService.isOldPackage
                  : existingService.isOldPackage,
              products: mergeProducts(existingService.products,
                  sharedPrefService.products.cast<Map<String, dynamic>>()),
            );
          } else {
            existingPackage.services.add(sharedPrefService);
          }
        }
      } else {
        packageMap[sharedPrefData.packageId] = sharedPrefPackage;
      }
    }

    return packageMap.values.toList();
  }

  List<ProductInPackage> mergeProducts(List<ProductInPackage> apiProducts,
      List<Map<String, dynamic>> sharedPrefProducts) {
    var productMap = {for (var prod in apiProducts) prod.productId: prod};

    for (var sharedPrefProduct in sharedPrefProducts) {
      var sharedPrefProductObj = ProductInPackage.fromJson(sharedPrefProduct);
      productMap[sharedPrefProductObj.productId] = sharedPrefProductObj;
    }

    return productMap.values.toList();
  }
}
