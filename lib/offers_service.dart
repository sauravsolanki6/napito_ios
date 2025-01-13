import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';

class OffersService {
  final String _baseUrl = '${MyApp.apiUrl}customer/store-offers/';

  Future<void> fetchOffers(
      String salonId, String branchId, String customerId) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'salon_id': salonId,
        'branch_id': branchId,
        'customer_id': customerId,
      }),
    );

    if (response.statusCode == 200) {
      // Print the response body for debugging
      print('All Offers Response: ${response.body}');
    } else {
      // Print the error if something went wrong
      print('Failed to fetch offers. Status code: ${response.statusCode}');
    }
  }
}
