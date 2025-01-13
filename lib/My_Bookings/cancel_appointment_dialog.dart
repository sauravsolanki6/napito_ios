import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/CancelledPage.dart';
import 'package:ms_salon_task/My_Bookings/mybooking_details.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
// import 'booking_details_page.dart'; // Ensure this import is correct

class CancelAppointmentDialog extends StatefulWidget {
  final VoidCallback onConfirm; // Called when 'Yes' is tapped
  final VoidCallback onCancel; // Called when 'No' is tapped

  const CancelAppointmentDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  _CancelAppointmentDialogState createState() =>
      _CancelAppointmentDialogState();
}

class _CancelAppointmentDialogState extends State<CancelAppointmentDialog> {
  late Future<List<dynamic>> _servicesFuture;
  String _bookingError = '';
  Map<String, bool> _selectedServiceDetailsIds = {};
  final TextEditingController _remarkController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _servicesFuture = _fetchBookingDetails();
    _fetchBookingDetails();
  }

  Future<List<dynamic>> _fetchBookingDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingId = prefs.getString('selected_booking_id2');

    if (bookingId == null) {
      setState(() {
        _bookingError = 'No booking ID found';
      });
      throw Exception('No booking ID found');
    }

    final salonID = prefs.getString('salon_id') ?? '';
    final branchID = prefs.getString('branch_id') ?? '';

    // Get the customer IDs from preferences or from other variables
    final customerId1 =
        prefs.getString('customer_id'); // Assuming customer_id1 is saved
    final customerId2 =
        prefs.getString('customer_id2'); // Assuming customer_id2 is saved

    // Set customerID based on the logic for customerId1 and customerId2
    final String customerID = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerID.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    // Prepare the request body
    final requestBody = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerID, // Use the resolved customerID here
      'booking_id': bookingId,
    });

    // Print the request
    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/booking-details/'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    // Print the response status code and body
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data['status'] == 'true') {
        final bookingList = data['data'] as List<dynamic>;
        if (bookingList.isNotEmpty) {
          final bookingDetails = bookingList.first;
          final services = bookingDetails['services'] as List<dynamic>;

          // Filter out services with service_status_flag of '1'
          final filteredServices = services.where((service) {
            return service['service_status_flag'] == '0';
          }).toList();

          _initializeSelectedServices(filteredServices);
          return filteredServices;
        } else {
          throw Exception('No booking details found');
        }
      } else {
        throw Exception('Failed to load booking details');
      }
    } else {
      throw Exception('Failed to load booking details');
    }
  }

  void _initializeSelectedServices(List<dynamic> services) {
    setState(() {
      _selectedServiceDetailsIds = {
        for (var service in services) service['service_details_id']: true
      };
    });
  }

  void _toggleServiceSelection(String serviceDetailsId) {
    setState(() {
      _selectedServiceDetailsIds[serviceDetailsId] =
          !(_selectedServiceDetailsIds[serviceDetailsId] ?? false);
    });
  }

  Future<void> _showRemarkDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Remark',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              hintText: 'Enter your remark here',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blueGrey,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
            ),
            maxLines: 3,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleConfirm(); // Proceed with confirmation
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleConfirm() async {
    final remark = _remarkController.text.trim();

    // Show a confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if No is pressed
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true if Yes is pressed
              },
            ),
          ],
        );
      },
    );

    // If the user confirmed the cancellation
    if (confirmed == true) {
      try {
        final success = await _cancelServices(remark);
        print('Cancellation Success: $success');
        if (success) {
          // Clear SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('selected_booking_id2');

          // Close dialog if open
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close dialog
          }
          print('Navigating to CancelledPage');

          // Use a new navigator to ensure we navigate to the CancelledPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => CancelledPage(),
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        widget.onConfirm();
      }
    } else {
      print('Cancellation not confirmed.');
    }
  }

  Future<bool> _cancelServices(String remark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookingId = prefs.getString('selected_booking_id2');
    if (bookingId == null) {
      throw Exception('No booking ID found');
    }

    // Fetching salon, branch, and customer IDs from shared preferences
    final salonID = prefs.getString('salon_id') ?? '';
    final branchID = prefs.getString('branch_id') ?? '';

    // Fetch customer ID either from customer_id1 or customer_id2
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');
    final customerID = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerID.isEmpty) {
      throw Exception('No customer ID found');
    }

    final selectedServices = _selectedServiceDetailsIds.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Prepare the request body
    final requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'booking_id': bookingId,
      'customer_id': customerID, // Use the selected customer ID
      'services_to_cancel': selectedServices,
      'remark': remark,
    };

    print('Request Body: ${jsonEncode(requestBody)}'); // Print the request body

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/cancel-service/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print(
        'Response Status: ${response.statusCode}'); // Print the response status code
    print(
        'Response Body of cancel: ${response.body}'); // Print the response body

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'true') {
        // Return true if the cancellation was successful
        return true;
      } else {
        throw Exception('Failed to cancel services');
      }
    } else {
      throw Exception('Failed to cancel services');
    }
  }

  Widget _buildRoundCheckbox(bool isSelected, Function(bool?) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? CustomColors.backgroundtext : Colors.transparent,
          border: Border.all(color: CustomColors.backgroundtext, width: 2.0),
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16.0,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cancel Appointment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<dynamic>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text(_bookingError.isNotEmpty
                        ? _bookingError
                        : 'Error fetching booking details');
                  } else {
                    final services = snapshot.data ?? [];
                    return services.isEmpty
                        ? Text('No services found')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: services.map<Widget>((service) {
                              final serviceDetailsId =
                                  service['service_details_id'];
                              final isSelected = _selectedServiceDetailsIds[
                                      serviceDetailsId] ??
                                  false;
                              final imageUrl = service['image'];
                              return InkWell(
                                onTap: () =>
                                    _toggleServiceSelection(serviceDetailsId),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildRoundCheckbox(
                                          isSelected,
                                          (value) {
                                            _toggleServiceSelection(
                                                serviceDetailsId);
                                          },
                                        ),
                                        SizedBox(width: 8.0),
                                        imageUrl != null && imageUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 40.0,
                                                  height: 40.0,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Icon(Icons.image,
                                                        size: 40.0);
                                                  },
                                                ),
                                              )
                                            : Icon(Icons.image, size: 40.0),
                                      ],
                                    ),
                                    title: Text(
                                      service['service_name'] ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    subtitle: Text(
                                      'From: ${service['service_from']} To: ${service['service_to']}\nStylist: ${service['stylist']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    trailing: Text(
                                      '\₹${service['final_price']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                  }
                },
              ),
              // Error message display
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 16.0),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onCancel(); // Call the onCancel callback
                    },
                    child: Text('No'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Check if at least one service is selected
                      final hasSelectedServices = _selectedServiceDetailsIds
                          .values
                          .any((isSelected) => isSelected);

                      if (!hasSelectedServices) {
                        // Set the error message if no services are selected
                        setState(() {
                          _errorMessage =
                              'Please select at least one service to cancel.';
                        });
                        return; // Exit the method to prevent further action
                      }

                      // Clear any previous error messages
                      setState(() {
                        _errorMessage = '';
                      });
                      Navigator.of(context).pop();
                      _handleConfirm();

                      // Show the remark dialog if services are selected
                      // _showRemarkDialog();
                    },
                    child: const Text('Yes'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.backgroundtext,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
