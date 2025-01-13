import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/payment.dart';
import 'package:ms_salon_task/main.dart';
import 'dart:convert'; // Import to use jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

class GiftCardConfirmationPage extends StatelessWidget {
  final String giftCardId;
  final String giftCardName;
  final String giftCardCode;
  final String giftCardGender;
  final double giftCardPrice; // Expecting double
  final double minBookingAmount; // Expecting double
  final double gstAmount;
  final double gstRate;
  final bool isGstApplicable;
  final double regPrice;
  const GiftCardConfirmationPage({
    Key? key,
    required this.giftCardId,
    required this.giftCardName,
    required this.giftCardCode,
    required this.giftCardPrice,
    required this.giftCardGender,
    required this.minBookingAmount,
    required this.gstAmount,
    required this.gstRate,
    required this.isGstApplicable,
    required this.regPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Is GST Applicable: $isGstApplicable');
    return Scaffold(
      backgroundColor: CustomColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Gift Card Confirmation'),
        backgroundColor: CustomColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildItemDetails(),
            const SizedBox(height: 20),
            _buildTotal(),
            // const SizedBox(height: 20),
            // _buildCashAtSalon(),
            const SizedBox(height: 20),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Details',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Note: This gift card is applicable to ${giftCardGender == 0 ? 'male' : 'female'} customers.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Divider(thickness: 2, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildCashAtSalon() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.backgroundLight, // Background color of the box
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(color: Colors.grey[300]!), // Optional border
      ),
      padding: const EdgeInsets.all(16.0), // Padding inside the box
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Radio(
            value: true, // Change value if you want to use it later
            groupValue: true, // Use a state variable if you need to toggle
            onChanged: (value) {
              // Handle radio button change if necessary
            },
          ),
          const Text(
            'Cash at Salon',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: CustomColors.backgroundLight, // Set the background color to white
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Gift Card Name:', giftCardName),
            _buildDetailRow('Gift Card Code:', giftCardCode),

            _buildDetailRow(
                'Regular Price:', '₹${regPrice.toStringAsFixed(2)}'),

            // Conditionally show GST Rate and GST Amount if GST is applicable
            if (isGstApplicable) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildDetailRow(
                        'GST Rate (${gstRate.toStringAsFixed(2)}%)', ''),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        _buildDetailRow('', '₹${gstAmount.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ],

            _buildDetailRow(
                'Gift Card Price:', '₹${giftCardPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16, // Font size
              fontWeight: FontWeight.w400, // Font weight 400
              height: 1.2, // Line height as a multiplier
              letterSpacing: 0.02, // 2% letter spacing
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16, // Font size
              fontWeight: FontWeight.w600, // Font weight 600
              height: 1.2, // Line height as a multiplier
              letterSpacing: 0.02, // 2% letter spacing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: CustomColors.backgroundLight, // Set the background color to white
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '₹${giftCardPrice.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.backgroundtext),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () =>
          _showConfirmationDialog(context), // Show confirmation dialog
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.backgroundtext,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Confirm Payment',
          style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: const Text('Are you sure you want to buy this gift card?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          PaymentPage()), // Replace with your actual payment page
                );
                //  Navigator.of(context).pop(); // Close the dialog
                _buyGiftCard(context); // Proceed to buy the gift card
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buyGiftCard(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';

    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    final url = Uri.parse('${MyApp.apiUrl}/customer/buy-giftcard/');

    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
      'giftcard_id': giftCardId,
      'payment_status': '1',
      'payment_mode': '0',
    });

    // Print the request body
    print('Request URL: $url');
    print('Request Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Print the response body
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          // _showSuccessDialog(context, data['message']); // Show success dialog??
        } else {
          _showErrorDialog(context, data['message']); // Show error dialog
        }
      } else {
        _showErrorDialog(context, 'Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to buy gift card: $e');
    }
  }

  // void _showSuccessDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Success'),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               // Navigator.of(context).pop(); // Close the dialog
  //               // Navigate to the payment page
  //               Navigator.of(context).pushReplacement(
  //                 MaterialPageRoute(
  //                     builder: (context) =>
  //                         PaymentPage()), // Replace with your actual payment page
  //               );
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   child: const Text('OK'),
            // },
          ],
        );
      },
    );
  }
}
