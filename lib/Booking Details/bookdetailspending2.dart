import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class BookingDetailsPage2 extends StatefulWidget {
  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage2> {
  late Future<Map<String, dynamic>> _bookingDetails;
  String? _bookingId;

  @override
  void initState() {
    super.initState();
    _loadBookingId(); // Load the booking ID and fetch details
  }

  Future<void> _loadBookingId() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingId1 = prefs.getString('selected_booking_id');
    final bookingId2 = prefs.getString('selected_booking_id2');

    final bookingId = bookingId1 ?? bookingId2;

    if (bookingId != null) {
      setState(() {
        _bookingId = bookingId;
        _bookingDetails = _fetchBookingDetails(bookingId);
      });
    } else {
      setState(() {
        _bookingDetails = Future.error('No booking ID found');
      });
    }
  }

  Future<Map<String, dynamic>> _fetchBookingDetails(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve and determine the customer ID
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String customerID = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    // Prepare the request URL and body
    final url = '${MyApp.apiUrl}customer/booking-details/';
    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerID,
      'booking_id': bookingId,
    });

    // Make the API call
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception(
          'Failed to load booking details: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookingDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Extracting booking details
            final bookingDetails = snapshot.data!['data'][0];
            final services = bookingDetails['services'] as List;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // Added scroll view for better layout
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Booking ID: ${bookingDetails['booking_id'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('Reference ID: ${bookingDetails['ref_id'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('Customer: ${bookingDetails['customer'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'Phone Number: ${bookingDetails['phone_no'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'Booking Date: ${bookingDetails['booking_date'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('From: ${bookingDetails['from'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('To: ${bookingDetails['to'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('Services:'),
                    for (var service in services)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                            ' - ${service['service_name'] ?? 'N/A'} (${service['duration']} mins)'),
                      ),
                    SizedBox(height: 8),
                    Text(
                        'Booking Status: ${bookingDetails['booking_status_text'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'Payment Status: ${bookingDetails['payment_status_text'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'Final Price: \$${bookingDetails['final_price'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'Discount Amount: \$${bookingDetails['total_discount_amount'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'GST Amount: \$${bookingDetails['gst_amount'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text(
                        'Amount to Paid: \$${bookingDetails['amount_to_paid'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('Receipt:'),
                    TextButton(
                      onPressed: () async {
                        final receiptUrl = bookingDetails['receipt'];
                        if (receiptUrl != null) {
                          if (await canLaunch(receiptUrl)) {
                            await launch(receiptUrl);
                          } else {
                            throw 'Could not launch $receiptUrl';
                          }
                        }
                      },
                      child: Text(bookingDetails['receipt'] ?? 'N/A'),
                    ),
                    SizedBox(height: 8),
                    Text(
                        'Review Submitted: ${bookingDetails['is_review_submitted'] == '1' ? 'Yes' : 'No'}'),
                    SizedBox(height: 8),
                    if (bookingDetails['is_review_submitted'] == '1') ...[
                      Text(
                          'Review ID: ${bookingDetails['review_id'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text(
                          'Review Stars: ${bookingDetails['review_stars'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text(
                          'Review Description: ${bookingDetails['review_description'] ?? 'N/A'}'),
                    ],
                    SizedBox(height: 8),
                    Text('Membership Details:'),
                    if (bookingDetails['applied_membership_details'] != null)
                      Text(
                          ' - Membership ID: ${bookingDetails['applied_membership_details']['membership_id'] ?? 'N/A'}'),
                    if (bookingDetails['applied_membership_details'] != null)
                      Text(
                          ' - Membership Name: ${bookingDetails['applied_membership_details']['name'] ?? 'N/A'}'),
                    if (bookingDetails['applied_membership_details'] != null)
                      Text(
                          ' - Service Discount: ${bookingDetails['applied_membership_details']['service_discount'] ?? 'N/A'}%'),
                    if (bookingDetails['applied_membership_details'] != null)
                      Text(
                          ' - Product Discount: ${bookingDetails['applied_membership_details']['product_discount'] ?? 'N/A'}%'),
                    // Add more fields based on the response structure as needed
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('No data found.'));
        },
      ),
    );
  }
}
