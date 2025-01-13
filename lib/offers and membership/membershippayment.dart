import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for json.encode
import 'package:http/http.dart' as http;

import '../main.dart'; // Import http package for API calls

class MembershipPayment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Membership Payment',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: CustomColors.backgroundLight,
      ),
      body: FutureBuilder(
        future: _getMembershipData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data as Map<String, String>;
            return Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isSmallScreen),
                  SizedBox(height: 16),
                  _buildDetailsBox(data, isSmallScreen),
                  SizedBox(height: 20),
                  _buildCashAtSalon(),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),
                  Center(
                      child:
                          _buildConfirmButton(context, data['membershipId'])),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Details',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(thickness: 2, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildDetailsBox(Map<String, String> data, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Title:', data['membershipTitle'], isSmallScreen),
          _buildDetailRow(
              'Validity:', data['membershipValidity'], isSmallScreen),
          _buildDetailRow(
              'Registration Price:', data['regPrice'], isSmallScreen),
          // Check if GST is applicable
          data['isGstApplicable'] == 'true'
              ? _buildGstDetailRow(
                  data['gstRate'], data['gstAmt'], isSmallScreen)
              : Container(), // Show nothing if GST is not applicable
          _buildDetailRow('Price:', data['membershipPrice'], isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildGstDetailRow(
      String? gstRate, String? gstAmt, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'GST Rate ($gstRate %)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
        SizedBox(width: 8), // Spacing between the rate and amount
        Expanded(
          child: Text(
            '$gstAmt',
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            textAlign: TextAlign.end, // Align to the end
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String? value, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getMembershipData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'membershipId': prefs.getString('membershipId') ?? '',
      'membershipTitle': prefs.getString('membershipTitle') ?? '',
      'membershipValidity': prefs.getString('membershipValidity') ?? '',
      'membershipDescription': prefs.getString('membershipDescription') ?? '',
      'membershipPrice': prefs.getString('membershipPrice') ?? '',
      'gstRate': prefs.getString('gstRate') ?? '', // New field
      'gstAmt': prefs.getString('gstAmt') ?? '', // New field
      'regPrice': prefs.getString('regPrice') ?? '', // New field
      'isGstApplicable': prefs.getString('isGstApplicable') ??
          'false', // New field to check if GST is applicable
    };
  }

  Widget _buildCashAtSalon() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Radio(
            value: true,
            groupValue: true,
            onChanged: (value) {},
          ),
          const Text(
            'Cash at Salon',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, String? membershipId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showConfirmationDialog(context, membershipId),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.backgroundtext,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Confirm Payment',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String? membershipId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Payment',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to proceed with the payment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (membershipId != null && membershipId.isNotEmpty) {
                  _buyMembership(membershipId, context);
                }

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes',
                  style: TextStyle(color: CustomColors.backgroundtext)),
            ),
          ],
        );
      },
    );
  }

  void _buyMembership(String membershipId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('branch_id') ?? '';
    final salonId = prefs.getString('salon_id') ?? '';
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');

    final customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty || branchId.isEmpty || salonId.isEmpty) {
      print('Missing required parameters.');
      return;
    }

    final membershipDetailsUrl = '${MyApp.apiUrl}customer/membership/'; // URL
    final requestBody = {
      'salon_id': salonId,
      'branch_id': branchId,
      'customer_id': customerId,
      'membership_id': membershipId, // Include membership ID
    };

    try {
      // Print the request body
      print('Request: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(membershipDetailsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Print the response body regardless of status code
      print('Response: ${response.body}');

      // Check if the purchase was successful (assuming a successful response has a specific status code)
      if (response.statusCode == 200) {
        // Directly proceed to buy the membership
        await _processMembershipPurchase(membershipId, context);
      } else {
        // Handle the case when the response indicates failure
        print('Failed to buy membership: ${response.body}');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
  }

  Future<void> _processMembershipPurchase(
      String membershipId, BuildContext context) async {
    // Implement your logic for processing the purchase here.
    // This should include the API call to finalize the purchase.
    print('Processing purchase for membership ID: $membershipId');

    // Example API call for processing purchase:
    // final purchaseResponse = await http.post(...);

    // Assume the purchase was successful, navigate to PaymentPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Membership purchased successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
