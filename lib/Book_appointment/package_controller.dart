import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackageController extends ChangeNotifier {
  PackageData? _packageData;
  bool _isLoading = true;
  String _errorMessage = '';

  PackageData? get packageData => _packageData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  PackageController() {
    _loadPackageData();
  }

  Future<void> _loadPackageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('selected_package_data_add_package');
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);
        _packageData = PackageData.fromJson(jsonData);
        _errorMessage = '';
      } else {
        _errorMessage = 'No data found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Additional methods for interacting with the package data can be added here
}

class PackageData {
  final String packageId;
  final String packageName;
  final double price;
  final List<Service> servicesArray;

  PackageData({
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.servicesArray,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    var list = json['services_array'] as List;
    List<Service> servicesList = list.map((i) => Service.fromJson(i)).toList();

    return PackageData(
      packageId: json['package_id'],
      packageName: json['package_name'],
      price: json['price'].toDouble(),
      servicesArray: servicesList,
    );
  }
}

class Service {
  final String serviceId;
  final String serviceName;
  final String serviceMarathiName;
  final String image;
  final String serviceDescription;
  final String serviceDuration;
  final List<dynamic> products;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceMarathiName,
    required this.image,
    required this.serviceDescription,
    required this.serviceDuration,
    required this.products,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      serviceMarathiName: json['service_marathi_name'],
      image: json['image'],
      serviceDescription: json['service_description'],
      serviceDuration: json['service_duration'],
      products: json['products'],
    );
  }
}
