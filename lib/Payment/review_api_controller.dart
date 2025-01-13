import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logResponseData() async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve the saved JSON response body
  final String? savedResponseBody = prefs.getString('response_body');

  // log the saved response body for debugging
  log('Saved Response data Body: $savedResponseBody');
}

void main() {
  // Call the function to log the response data
  logResponseData();
}

class ApiController {
  final String membershipApiUrl = '${MyApp.apiUrl}customer/membership/';
  final String bookingApiUrl = '${MyApp.apiUrl}customer/booking/';

  // Fetches membership data
  Future<Map<String, dynamic>> fetchMembershipData(
      String salonId, String branchId, String customerId) async {
    final body = jsonEncode({
      'salon_id': salonId,
      'branch_id': branchId,
      'customer_id': customerId,
    });

    log('Request Body for Membership Data: $body');

    final response = await http.post(
      Uri.parse(membershipApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load membership data');
    }
  }

  // Saves selected time slot to SharedPreferences
  Future<void> _saveSelectedTimeSlot(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    final timeSlot = '$from-$to';
    await prefs.setString('selected_time_slot', timeSlot);
    log('Saved time slot to SharedPreferences: $timeSlot');
  }

  // Retrieves saved service times from SharedPreferences
  Future<Map<String, String>> getSavedServiceTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedResponseBody = prefs.getString('response_body');
    log('Saved Response Body: $savedResponseBody');

    if (savedResponseBody != null) {
      try {
        final Map<String, dynamic> responseData = jsonDecode(savedResponseBody);
        final List<dynamic> services =
            responseData['data'] as List<dynamic>? ?? [];
        if (services.isNotEmpty) {
          final service = services.first;
          final serviceFrom = service['service_from'] ?? '';
          final serviceTo = service['service_to'] ?? '';
          return {
            'service_from': serviceFrom,
            'service_to': serviceTo,
          };
        } else {
          throw Exception('No services found in the response.');
        }
      } catch (e) {
        log('Failed to parse response JSON: $e');
        throw Exception('Failed to parse saved response JSON.');
      }
    } else {
      throw Exception('No saved response body found.');
    }
  }

  // Confirms a booking with the given parameters
  Future<Map<String, dynamic>> confirmBooking({required String note}) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve IDs from SharedPreferences
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');
    final branchId = prefs.getString('branch_id') ?? '';
    final salonId = prefs.getString('salon_id') ?? '';
    final selected_stylist_id = prefs.getString('selected_stylist_id') ?? '';

    final customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    // Retrieve service data JSON
    final serviceDataJson = prefs.getString('service_data') ?? '{}';
    final serviceData = jsonDecode(serviceDataJson) as Map<String, dynamic>;

    // Extract services data from the saved response body
    final savedResponseBody = prefs.getString('response_body');
    if (savedResponseBody == null) {
      throw Exception('No saved response body found.');
    }

    final savedResponseData =
        jsonDecode(savedResponseBody) as Map<String, dynamic>;
    final services = savedResponseData['data'] as List<dynamic>? ?? [];

    // Create a map of stylist shifts for easy lookup
    final stylistShiftMap = <String, Map<String, dynamic>>{};
    for (var service in services) {
      final availableStylists =
          service['available_stylists'] as List<dynamic>? ?? [];
      for (var stylist in availableStylists) {
        final stylistId = stylist['stylist_id'] as String;
        stylistShiftMap[stylistId] = {
          'stylist_shift_id': stylist['stylist_shift_id'] ?? '',
          'stylist_shift_type': stylist['stylist_shift_type'] ?? '',
        };
      }
    }

    final serviceTimings = {
      for (var service in services)
        service['service_id']: {
          'service_from': service['service_from'],
          'service_to': service['service_to'],
        }
    };

    final bookingDate = prefs.getString('selected_date');
    if (bookingDate == null || bookingDate.isEmpty) {
      throw Exception('No valid booking date found');
    }

    // Extract saved service times
    final serviceTimes = await getSavedServiceTimes();
    final selectedSlotFrom = serviceTimes['service_from']!;
    final selectedSlotTo = serviceTimes['service_to']!;

    // Retrieve and decode selected service data
    final selectedServiceDataJson1 = prefs.getString('selected_service_data');
    final selectedServiceDataJson2 = prefs.getString('selected_service_data1');
    log('services from services $selectedServiceDataJson1');
    log('services from packages $selectedServiceDataJson2');
    // Retrieve selected stylist IDs

    final selectedStylistIdsJson = prefs.getString('selected_stylist_ids');
    final selectedStylistIds = selectedStylistIdsJson != null
        ? jsonDecode(selectedStylistIdsJson) as Map<String, dynamic>
        : {};

    // Function to format service data
    List<Map<String, dynamic>> formatServiceData(Map<String, dynamic> data) {
      final serviceMap = <String, Map<String, dynamic>>{};
      String? stylistSelectionResponse =
          prefs.getString('stylist_selection_response');
      String? selectedStylistDataList =
          prefs.getString('selected_stylist_data_list');
      List<dynamic> stylistDataList = [];
      if (selectedStylistDataList != null) {
        stylistDataList = jsonDecode(selectedStylistDataList) as List<dynamic>;
      }

      for (var entry in data.entries) {
        final service = entry.value as Map<String, dynamic>;
        final serviceId = service['serviceId'] as String;
        final serviceName =
            service['serviceName'] ?? 'Unknown Service'; // Handle null names

        final timings = serviceTimings[serviceId] ??
            {
              'service_from': bookingDate + ' 00:00:00',
              'service_to': bookingDate + ' 00:00:00',
            };

        final stylistId = (selectedStylistIds[serviceId] as List<dynamic>?)
                ?.first
                ?.toString() ??
            '';

        // Get stylist shift ID and type from the map
        final stylistShift = stylistShiftMap[stylistId] ??
            {
              'stylist_shift_id': '',
              'stylist_shift_type': '',
            };

        List<dynamic> serviceStylistsData = [];
        if (stylistSelectionResponse != null &&
            stylistSelectionResponse.isNotEmpty) {
          final parsedResponse = jsonDecode(stylistSelectionResponse);
          serviceStylistsData = (parsedResponse['data']['service_stylists_data']
                  as List<dynamic>? ??
              []);
        }

        // Find the matching service from stylist data in `stylist_selection_response`
        final selectedStylistData = serviceStylistsData.firstWhere(
          (serviceStylist) => serviceStylist['service_id'] == serviceId,
          orElse: () => null,
        );

        // If no data in `stylist_selection_response`, fallback to `selected_stylist_data_list`
        final fallbackStylistData = stylistDataList.firstWhere(
          (stylistData) => stylistData['service_id'] == serviceId,
          orElse: () => null,
        );

// Extract stylist details from shared preferences if available
        final sharedPrefStylistId = selectedStylistData?['selected_stylists']
                ['stylist_id'] ??
            fallbackStylistData?['stylist_id'];
        final sharedPrefStylistShiftId =
            selectedStylistData?['selected_stylists']['stylist_shift_id'] ??
                fallbackStylistData?['stylist_shift_id'];
        final sharedPrefStylistShiftType =
            selectedStylistData?['selected_stylists']['stylist_shift_type'] ??
                fallbackStylistData?['stylist_shift_type'];

        // Implement logic to decide which stylist data to use
        final effectiveStylistId = sharedPrefStylistId ?? stylistId;
        final effectiveStylistShiftId =
            sharedPrefStylistShiftId ?? stylistShift['stylist_shift_id']!;
        final effectiveStylistShiftType =
            sharedPrefStylistShiftType ?? stylistShift['stylist_shift_type']!;
        // Add or update service in the map
        serviceMap[serviceId] = {
          'service_id': serviceId,
          'service_name': serviceName, // Ensure the service name is not null
          'service_added_from': service['is_old_package'] ?? '0',
          'service_from': timings['service_from']!,
          'service_to': timings['service_to']!,
          'selected_stylist': effectiveStylistId,
          'selected_stylist_shift_id': effectiveStylistShiftId,
          'selected_stylist_shift_type': effectiveStylistShiftType,
          'price': service['price'],
          'is_offer_applied': service['is_offer_applied'] ?? '0',
          'applied_offer_id': service['applied_offer_id'] ?? '',
          'selected_package_id': service['package_id'] ?? '',
          'selected_package_allocation_id':
              service['package_allocation_id'] ?? '',
          'is_old_package': service['is_old_package'],
          'products': service['products'] ?? [],
        };
      }

      return serviceMap.values.toList();
    }

    List<Map<String, dynamic>> selectedServices = [];
    if (selectedServiceDataJson1 != null) {
      final jsonData1 =
          jsonDecode(selectedServiceDataJson1) as Map<String, dynamic>;
      selectedServices.addAll(formatServiceData(jsonData1));
    }
    if (selectedServiceDataJson2 != null) {
      final jsonData2 =
          jsonDecode(selectedServiceDataJson2) as Map<String, dynamic>;
      selectedServices.addAll(formatServiceData(jsonData2));
    }

    // Remove duplicate services based on service_id
    final uniqueServicesMap = <String, Map<String, dynamic>>{};
    for (var service in selectedServices) {
      final serviceId = service['service_id'] as String;
      uniqueServicesMap[serviceId] = service;
    }
    final finalSelectedServices = uniqueServicesMap.values.toList();

    // log the unique services for debugging
    for (var service in finalSelectedServices) {
      log('Service ID: ${service['service_id']}');
      log('Service Name: ${service['service_name']}');
    }

    final packagesDetailsJson = prefs.getString('packages_details') ?? '{}';
    final membershipDetailsJson = prefs.getString('membership_details') ?? '{}';
    log('membershipDetailsJson is $membershipDetailsJson');

    final packagesDetails =
        jsonDecode(packagesDetailsJson) as Map<String, dynamic>;
    final membershipDetailsData = membershipDetailsJson.isNotEmpty
        ? jsonDecode(membershipDetailsJson) as Map<String, dynamic>
        : {};
    final isMember = membershipDetailsData['is_member'] ?? 0;
    final membershipDetail =
        membershipDetailsData['membership_details'] as Map<String, dynamic>? ??
            {};
    final membershipDetails = {
      // 'is_old_member': membershipDetailsData['is_members'] ?? '',
      'is_old_member': isMember,
      'membership_id': membershipDetail['membership_id'] ?? '',
      'membership_allocation_id':
          membershipDetail['membership_allocation_id'] ?? '',
    };

    // Retrieve offer, coupon, giftcard, and reward details
    final offerDetailsJson = prefs.getString('offer_details') ?? '{}';
    final couponDetailsJson = prefs.getString('coupon_details') ?? '{}';
    final giftCardDetailsJson = prefs.getString('giftcard_details') ?? '{}';
    final rewardDetailsJson = prefs.getString('reward_details') ?? '{}';

    final offerDetails = jsonDecode(offerDetailsJson) as Map<String, dynamic>;
    final couponDetails = jsonDecode(couponDetailsJson) as Map<String, dynamic>;
    final giftCardDetails =
        jsonDecode(giftCardDetailsJson) as Map<String, dynamic>;
    final rewardDetails = jsonDecode(rewardDetailsJson) as Map<String, dynamic>;

    final body = jsonEncode({
      'membership_details': membershipDetails,
      'offer_details': {
        'is_offer_applied': offerDetails.isEmpty ? '0' : '1',
        'applied_offer_id': offerDetails['applied_offer_id'] ?? '',
      },
      'coupon_details': {
        'is_coupon_applied': couponDetails.isEmpty ? '0' : '1',
        'applied_coupon_id': couponDetails['applied_coupon_id'] ?? '',
      },
      'giftcard_details': {
        'is_giftcard_applied': giftCardDetails.isEmpty ? '0' : '1',
        'applied_giftcard_id': giftCardDetails['applied_giftcard_id'] ?? '',
        'giftcard_owner_id': giftCardDetails['giftcard_owner_id'] ?? '',
      },
      'reward_details': {
        'is_reward_applied': rewardDetails.isEmpty ? '0' : '1',
        'used_rewards': rewardDetails['used_rewards'] ?? '',
        'reward_discount': rewardDetails['reward_discount'] ?? '',
      },
      'salon_id': salonId,
      'branch_id': branchId,
      'selected_stylist_id': selected_stylist_id,
      'customer_id': customerId,
      'selected_slot_from': selectedSlotFrom,
      'selected_slot_to': selectedSlotTo,
      'booking_date': bookingDate,
      'note': note,
      'used_rewards': '', // Placeholder as per the format
      'selected_services': finalSelectedServices,
      'packages_details': {
        'selected_package_id': packagesDetails['selected_package_id'] ?? '',
        'selected_package_allocation_id':
            packagesDetails['selected_package_allocation_id'] ?? '',
        'is_old_package': packagesDetails['is_old_package'] ?? '0',
      },
    });

    // log full request body
    log('Full Request Body:');
    log(body);

    try {
      final response = await http.post(
        Uri.parse(bookingApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // log full response details
      log('Response Status: ${response.statusCode}');
      log('Response Headers: ${response.headers}');
      log('Response Body:');
      log(response.body);

      // Attempt to decode JSON response
      try {
        final responseData = jsonDecode(response.body);
        // log('Decoded Response Data:');
        // log(responseData);
        if (responseData['status'] == true) {
          // Save the receipt URL to SharedPreferences
          final receiptUrl = responseData['data']['receipt'] as String?;
          if (receiptUrl != null && receiptUrl.isNotEmpty) {
            await prefs.setString('booking_receipt', receiptUrl);
            log('Receipt URL saved to SharedPreferences: $receiptUrl');
          }
        }
        return responseData;
      } catch (e) {
        // log('Failed to decode JSON response: $e');
        // log('Raw Response Body: ${response.body}');
        throw Exception('Invalid JSON response: ${response.body}');
      }
    } catch (e) {
      // log('Error confirming booking: $e');
      throw Exception('Failed to confirm booking: $e');
    }
  }
}

class Offer {
  final String offerId;
  final String offerText;
  final String validity;
  final String validityText;
  final String rewards;
  final String offerIcon;
  final String offerName;
  final String servicesText;
  final String discountType;
  final double discount;
  final List<Service> services;

  Offer({
    required this.offerId,
    required this.offerText,
    required this.validity,
    required this.validityText,
    required this.rewards,
    required this.offerIcon,
    required this.offerName,
    required this.servicesText,
    required this.discountType,
    required this.discount,
    required this.services,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerId: json['offer_id'],
      offerText: json['offer_text'],
      validity: json['validity'],
      validityText: json['validity_text'],
      rewards: json['rewards'],
      offerIcon: json['offer_icon'],
      offerName: json['offer_name'],
      servicesText: json['services_text'],
      discountType: json['discount_type'],
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      services: (json['services'] as List<dynamic>)
          .map((service) => Service.fromJson(service))
          .toList(),
    );
  }
}

class Service {
  final String serviceId;
  final String serviceName;
  final String serviceNameMarathi;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceNameMarathi,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      serviceNameMarathi: json['service_name_marathi'],
    );
  }
}
