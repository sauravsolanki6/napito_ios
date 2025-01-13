import 'dart:convert'; // Import for json.decode
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/payment.dart';
import 'package:ms_salon_task/offers%20and%20membership/store_package_controller.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class PackageDetailsPage extends StatefulWidget {
  @override
  _PackageDetailsPageState createState() => _PackageDetailsPageState();
}

class _PackageDetailsPageState extends State<PackageDetailsPage> {
  Map<String, dynamic>? _packageDetails;
  bool _isCashAtSalon = false; // State variable for radio button
  String? _selectedPackageId; // Add this variable
  final StorePackageController _controller = StorePackageController();
  @override
  void initState() {
    super.initState();
    _loadPackageDetails();
  }

  Future<void> _loadPackageDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPackageDetails = prefs.getString('selectedPackageforbuy');

    // Print the retrieved saved package details
    print(
        'Retrieved package details from SharedPreferences: $savedPackageDetails');

    if (savedPackageDetails != null) {
      setState(() {
        _packageDetails = json.decode(savedPackageDetails);
        _selectedPackageId =
            _packageDetails!['id']; // Assuming package has an ID field
      });
    } else {
      print('No package details found in Shared Preferences.');
    }
  }

  Future<void> _buyNow() async {
    if (_selectedPackageId == null) {
      print('No package selected');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Retrieve customer IDs from SharedPreferences
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchId = prefs.getString('branch_id') ?? '';
    final String salonId = prefs.getString('salon_id') ?? '';

    // Determine the valid customer ID
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      print('No valid customer ID found');
      return;
    }

    // Call the method to buy the package
    final responseMessage = await _controller.buyPackage(
        salonId, branchId, customerId, _selectedPackageId!);

    // Show the response message in a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(responseMessage),
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate to CustomerPackages1 page after a successful purchase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Package Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _packageDetails != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBillingDetails(),
                  SizedBox(height: 10),
                  _buildPackageDetails(),
                  SizedBox(height: 10),
                  _buildServiceDetails(),
                  SizedBox(height: 10),
                  _buildPackageInfo(),
                  SizedBox(height: 10),
                  _buildTotalPrice(),
                  SizedBox(height: 10),
                  _buildCashAtSalonRadio(),
                  SizedBox(height: 20), // Added space between radio and button
                  Center(child: _buildProceedButton()), // Centering the button
                  Spacer(), // Pushes everything above the button to the top
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProceedButton() {
    return InkWell(
      onTap: _showConfirmationDialog, // Call the confirmation dialog
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.backgroundtext,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: const Text(
            'Confirm Payment',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Purchase'),
          content: Text('Are you sure you want to proceed with the payment?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _buyNow(); // Call the method to proceed with the purchase
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPackageDetails() {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Package Name: ${_packageDetails!['name']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Included Services:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 5),
          ...(_packageDetails!['services'] as List).map((service) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: CustomColors.backgroundtext, size: 20),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${service['serviceName']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBillingDetails() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        'Billing Details:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildPackageInfo() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(
              'Discounted Price:', '\₹${_packageDetails!['discountedPrice']}',
              isBold: true, textColor: CustomColors.backgroundtext),
          SizedBox(height: 10),
          if (_packageDetails!['isGstApplicable']) ...[
            _buildGstRow(), // Call the new method to build the GST row
          ],
        ],
      ),
    );
  }

// Corrected method to build the GST Rate and Amount row
  Widget _buildGstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'GST Rate: (${_packageDetails!['gstRate']}%)',
          style: TextStyle(fontSize: 16), // Regular size for the label
        ),
        Text(
          '\₹${_packageDetails!['gstAmount']}', // GST Amount on the right
          style: TextStyle(fontSize: 16, color: CustomColors.backgroundtext),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPrice() {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Price:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            '\₹${_packageDetails!['price']}',
            style: TextStyle(fontSize: 20, color: CustomColors.backgroundtext),
          ),
        ],
      ),
    );
  }

  Widget _buildCashAtSalonRadio() {
    // Ensure _isCashAtSalon is always true
    _isCashAtSalon = true; // Set it to true by default

    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Radio<bool>(
            value: true,
            groupValue: _isCashAtSalon,
            onChanged: null, // Disable changing the value
            activeColor: Colors.blue, // Set the radio button color to blue
          ),
          Text(
            'Cash at Salon',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}
