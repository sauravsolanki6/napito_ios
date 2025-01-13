import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TipModel to handle the API response
class TipModel {
  final String status;
  final String message;
  final List<Tip> data;

  TipModel({required this.status, required this.message, required this.data});

  factory TipModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Tip> tipList = list.map((i) => Tip.fromJson(i)).toList();
    return TipModel(
      status: json['status'],
      message: json['message'],
      data: tipList,
    );
  }

  // Method to fetch tips from the API
// Method to fetch tips from the API
  static Future<TipModel> fetchTips() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger

    try {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      final String url = '${Config.apiUrl}customer/store-tips/';
      final requestBody = jsonEncode({
        'salon_id': salonID,
        'branch_id': branchID,
      });

      print('Request URL: $url');
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return TipModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load tips');
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      // final String salonID = prefs.getString('salon_id') ?? '';
      await errorLogger.setBranchId(branchID);
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
      throw Exception('Failed to fetch tips: $e');
    }
  }
}

class Tip {
  final String isExtraTips; // Changed to match the API response
  final String title;
  final String description;
  final String bannerImage;
  final List<ImagePath> allImages;
  final List<ExtraTip> extraTips; // Added to match the extra tips in response

  Tip({
    required this.isExtraTips,
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.allImages,
    required this.extraTips,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    var list = json['all_images'] as List;
    List<ImagePath> imagePathList =
        list.map((i) => ImagePath.fromJson(i)).toList();

    var extraTipsList = json['extra_tips'] as List;
    List<ExtraTip> extraTipList =
        extraTipsList.map((i) => ExtraTip.fromJson(i)).toList();

    return Tip(
      isExtraTips: json['is_extra_tips'].toString(), // Convert to String
      title: json['title'],
      description: json['description'],
      bannerImage: json['banner_image'],
      allImages: imagePathList,
      extraTips: extraTipList, // Populate extra tips
    );
  }
}

class ImagePath {
  final String path;

  ImagePath({required this.path});

  factory ImagePath.fromJson(Map<String, dynamic> json) {
    return ImagePath(path: json['path']);
  }
}

// ExtraTip class to handle extra tips from the response
class ExtraTip {
  final String itemName;
  final String description;

  ExtraTip({required this.itemName, required this.description});

  factory ExtraTip.fromJson(Map<String, dynamic> json) {
    return ExtraTip(
      itemName: json['item_name'],
      description: json['description'],
    );
  }
}
