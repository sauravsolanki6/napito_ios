import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class OffersWidget extends StatefulWidget {
  final VoidCallback onOfferChanged;

  OffersWidget({required this.onOfferChanged});

  @override
  _OffersWidgetState createState() => _OffersWidgetState();
}

class _OffersWidgetState extends State<OffersWidget>
    with SingleTickerProviderStateMixin {
  List<dynamic> _offers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isOffersVisible = false;
  int? _expandedOfferIndex;
  Map<String, dynamic>? _appliedOffer;
  Map<String, dynamic> _mergedServiceData = {};
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
    _loadAppliedOffer();
    _mergeAndPrintServiceData();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _mergeAndPrintServiceData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? selectedServiceDataJson1 =
        prefs.getString('selected_service_data');
    final String? selectedServiceDataJson2 =
        prefs.getString('selected_service_data1');

    // Decode JSON strings into Maps
    final Map<String, dynamic>? serviceData1 = selectedServiceDataJson1 != null
        ? jsonDecode(selectedServiceDataJson1) as Map<String, dynamic>
        : {};
    final Map<String, dynamic>? serviceData2 = selectedServiceDataJson2 != null
        ? jsonDecode(selectedServiceDataJson2) as Map<String, dynamic>
        : {};

    // Merge the Maps
    _mergedServiceData = {
      ...?serviceData1,
      ...?serviceData2,
    };

    // Print the merged data
    print('Merged Service Data in offers: $_mergedServiceData');

    // Extract and print service IDs from the merged data
    final List<int> serviceIds =
        _mergedServiceData.keys.map((key) => int.tryParse(key) ?? 0).toList();
    print('Service IDs: $serviceIds');
  }

  Future<void> _fetchOffers() async {
    try {
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

      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/store-offers/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salon_id': salonID,
          'branch_id': branchID,
          'customer_id': customerId,
        }),
      );

      print('Offers response body test: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> offersMap = jsonDecode(response.body);
        print('Offers response map: $offersMap');

        if (offersMap['status'] == 'true') {
          setState(() {
            _offers = offersMap['data'] ?? [];
            _isLoading = false;
            _mergeAndPrintServiceData(); // Call comparison after fetching offers
          });

          for (var offer in _offers) {
            final List<dynamic> services = offer['services'] ?? [];
            for (var service in services) {
              print('Service ID: ${service['service_id']}');
            }
          }
        } else {
          setState(() {
            _errorMessage = offersMap['message'] ?? 'No offers found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error fetching offers: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching offers: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppliedOffer() async {
    final prefs = await SharedPreferences.getInstance();

    // Load and print the offer flag
    final bool? isOfferApplied = prefs.getBool('offer_applied');
    print('Is offer applied: ${isOfferApplied ?? false}');

    final String? appliedOfferJson = prefs.getString('offers_response');
    if (appliedOfferJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(appliedOfferJson);
      final List<dynamic> offersList = decoded['data'] ?? [];
      if (offersList.isNotEmpty) {
        setState(() {
          _appliedOffer =
              offersList[0]; // Assuming the first offer is the applied one
        });

        // Print the applied offer details to the console
        print('Loaded applied offer: $_appliedOffer');
      } else {
        // Print a message if no offer was found in the data list
        print('No offers found in the loaded data.');
      }
    } else {
      // Print a message if no offer was found in shared preferences
      print('No applied offer found in shared preferences.');
    }
  }

  Future<void> _applyOffer(Map<String, dynamic> offer) async {
    final offerName = offer['offer_name'];
    final discount = offer['discount'];
    final offerId = offer['offer_id'];
    final offerText = offer['offer_discount_text'];
    print('offer text $offerText');

    if (offerName == null || discount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer details are missing.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Retrieve the selected service data from preferences
    final prefs = await SharedPreferences.getInstance();
    final String? selectedServiceData =
        prefs.getString('selected_service_data');
    print('Selected Service Data from prefs: $selectedServiceData');

    // If there's any selected service data, do not apply the offer
    if (selectedServiceData != null && selectedServiceData.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Cannot apply the offer as a Package is already selected.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Retrieve the merged service IDs
    final List<int> mergedServiceIds = _mergedServiceData.keys
        .map((key) =>
            int.tryParse(key) ?? -1) // Parse the service IDs as integers
        .where((id) => id != -1) // Filter out invalid IDs
        .toList();

    // Retrieve service IDs from the offer
    final List<int> offerServiceIds = (offer['services'] as List<dynamic>?)
            ?.map((service) =>
                int.tryParse(service['service_id'].toString()) ?? -1)
            .where((id) => id != -1)
            .toList() ??
        [];

    // Check for any matching service IDs
    final hasMatchingService =
        offerServiceIds.any((id) => mergedServiceIds.contains(id));

    if (!hasMatchingService) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The offer is not available for the selected service.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Proceed with applying the offer
    // Check if a coupon, gift card, or reward is already applied
    final bool? isCouponApplied = prefs.getBool('coupon_applied');
    final bool? isGiftCardApplied = prefs.getBool('giftcard_applied');
    final bool? isRewardApplied =
        prefs.getBool('reward_applied'); // Check reward
    if (isRewardApplied == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A reward has already been applied.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (isCouponApplied == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A coupon has already been applied.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isGiftCardApplied == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A gift card has been applied'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // if (isRewardApplied == true) {
    //   // Additional check for rewards
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('A reward has already been applied.'),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    //   return;
    // }

    // Store the offer response in SharedPreferences
    final offerResponse = jsonEncode({
      'status': 'true',
      'message': 'Success',
      'data': [offer], // Wrap the offer in a list
    });
    await prefs.setString('offers_response', offerResponse);
    await prefs.setBool('offer_applied', true); // Set the flag

    // Create and store offer details JSON
    final offerDetails = jsonEncode({
      'is_offer_applied': 1,
      'applied_offer_id': offerId,
    });
    await prefs.setString('offer_details', offerDetails);

    // Print the response and offer details to the console
    print('Offer applied successfully: $offerResponse');
    print('Offer details saved: $offerDetails');

    setState(() {
      _appliedOffer = offer;
      _isOffersVisible = false;
      _controller.reverse();
    });

    widget.onOfferChanged(); // Notify parent that an offer was applied
  }

  // Future<void> _applyOffer(Map<String, dynamic> offer) async {
  //   final offerName = offer['offer_name'];
  //   final discount = offer['discount'];
  //   final offerId = offer['offer_id'];

  //   if (offerName == null || discount == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Offer details are missing.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   // Retrieve the merged service IDs
  //   final List<int> mergedServiceIds = _mergedServiceData.keys
  //       .map((key) =>
  //           int.tryParse(key) ?? -1) // Parse the service IDs as integers
  //       .where((id) => id != -1) // Filter out invalid IDs
  //       .toList();

  //   // Retrieve service IDs from the offer
  //   final List<int> offerServiceIds = (offer['services'] as List<dynamic>?)
  //           ?.map((service) =>
  //               int.tryParse(service['service_id'].toString()) ?? -1)
  //           .where((id) => id != -1)
  //           .toList() ??
  //       [];

  //   // Check for any matching service IDs
  //   final hasMatchingService =
  //       offerServiceIds.any((id) => mergedServiceIds.contains(id));

  //   if (!hasMatchingService) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('No matching services for this offer.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   // Proceed with applying the offer
  //   // Check if a coupon or gift card is already applied
  //   final prefs = await SharedPreferences.getInstance();
  //   final bool? isCouponApplied = prefs.getBool('coupon_applied');
  //   final bool? isGiftCardApplied = prefs.getBool('giftcard_applied');

  //   if (isCouponApplied == true) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('A coupon has already been applied.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   if (isGiftCardApplied == true) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('A gift card has already been applied.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   // Store the offer response in SharedPreferences
  //   final offerResponse = jsonEncode({
  //     'status': 'true',
  //     'message': 'Success',
  //     'data': [offer], // Wrap the offer in a list
  //   });
  //   await prefs.setString('offers_response', offerResponse);
  //   await prefs.setBool('offer_applied', true); // Set the flag

  //   // Create and store offer details JSON
  //   final offerDetails = jsonEncode({
  //     'is_offer_applied': 1,
  //     'applied_offer_id': offerId,
  //   });
  //   await prefs.setString('offer_details', offerDetails);

  //   // Print the response and offer details to the console
  //   print('Offer applied successfully: $offerResponse');
  //   print('Offer details saved: $offerDetails');

  //   setState(() {
  //     _appliedOffer = offer;
  //     _isOffersVisible = false;
  //     _controller.reverse();
  //   });

  //   widget.onOfferChanged(); // Notify parent that an offer was applied
  // }

  Future<void> _removeAppliedOffer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offers_response');
    await prefs.remove('offer_applied'); // Clear the flag
    await prefs.remove('offer_details'); // Remove offer details

    setState(() {
      _appliedOffer = null;
      _isOffersVisible = true;
      _controller.forward();
    });

    widget.onOfferChanged(); // Notify parent that an offer was removed
  }

  void _toggleOffersVisibility() {
    setState(() {
      _isOffersVisible = !_isOffersVisible;
      _isOffersVisible ? _controller.forward() : _controller.reverse();
    });
  }

  void _toggleOfferDetails(int index) {
    setState(() {
      if (_expandedOfferIndex == index) {
        _expandedOfferIndex = null;
      } else {
        _expandedOfferIndex = index;
      }
    });
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    // Extracting the data from the offer
    final offerText = offer['offer_text'] ?? 'No description available';
    final validityText = offer['validity_text'] ?? 'No validity information';
    final rewards = offer['rewards'] ?? '0';
    final discount = offer['discount'] ?? '0.0';
    final discountType = offer['discount_type'] ?? '0'; // 0=percentage, 1=flat
    final servicesText = offer['services_text'] ?? 'No services information';
    final services = offer['services'] as List<dynamic>? ?? [];

    // Build the services text
    String servicesDetail = services.isEmpty
        ? 'No services information'
        : services.map((service) {
            return '${service['service_name']} (${service['service_name_marathi'] ?? 'No Marathi name'})';
          }).join('\n');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['offer_name'] ?? 'Offer Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        CustomColors.backgroundtext, // Replace with your color
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Offer Text:', offerText),
                _buildDetailRow('Validity:', validityText),
                _buildDetailRow('Rewards:', rewards),
                _buildDetailRow(
                  'Discount:',
                  '$discount ${discountType == '0' ? '%' : 'flat'}',
                ),
                _buildDetailRow('Services:', servicesText),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Services Details:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  servicesDetail,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors
                          .backgroundtext, // Replace with your color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close',
                        style: TextStyle(
                            fontSize: 16, color: CustomColors.backgroundLight)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to create a row for detail items
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If there are no offers, return an empty container
    if (_offers.isEmpty && !_isLoading && _errorMessage.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guideline text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Choose an offer from below and apply to get discounts:',
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w500, // Change to 500
              color: Colors.grey[700],
            ),
          ),
        ),
        if (_appliedOffer == null) ...[
          // Show one offer by default if there are offers available
          if (_offers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4), // Reduced vertical padding
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius:
                      BorderRadius.circular(6), // Reduced border radius
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.zero, // Removes extra padding inside ListTile
                  title: Text(
                    _offers[0]['offer_name'] ?? 'Unknown Offer',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w500, // Change to 500
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_offers[0]['discount']?.toString() ?? '0.0'}% off',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _applyOffer(_offers[0]),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.lato(
                              color:
                                  CustomColors.backgroundtext), // Use Lato font
                        ),
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor:
                              Colors.transparent, // Remove background
                          minimumSize: Size(0, 0), // Remove minimum size
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _applyOffer(_offers[0]),
                ),
              ),
            ),
          ],

          // Available Offers / Applied Offer button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _toggleOffersVisibility,
                    child: Text(
                      'Available Offers',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, // Changed to 500
                        color:
                            CustomColors.backgroundtext, // Use your theme color
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.transparent, // Remove background
                      side: BorderSide(
                          color: CustomColors.backgroundtext,
                          width: 1.0), // Border color and width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(0, 0), // Remove minimum size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_appliedOffer != null) ...[
          // Display the applied offer card
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Offer: ${_appliedOffer!['offer_name'] ?? 'Unknown Offer'} '
                      '${_appliedOffer!['offer_discount_text'] ?? 'Unknown Offer'} ',
                      // '(${_appliedOffer!['discount']?.toString() ?? '0.0'}%)',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w500, // Set to 500
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _removeAppliedOffer,
                    child: Text(
                      'Remove',
                      style: GoogleFonts.lato(
                        color: Colors.red,
                        fontWeight: FontWeight.w500, // Set to 500
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // No extra padding
                      backgroundColor: Colors.transparent, // Remove background
                      minimumSize: Size(0, 0), // Remove minimum size
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_appliedOffer == null) ...[
          // Offers List
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1.0,
            child: _isOffersVisible
                ? _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : _offers.isEmpty
                            ? Center(
                                child: Text('No offers available to apply.'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _offers.length > 1
                                    ? _offers.length - 1
                                    : 0, // Reduce itemCount by 1
                                itemBuilder: (context, index) {
                                  final offer = _offers[
                                      index + 1]; // Start from the second offer
                                  final offerName = offer['offer_name'];
                                  final discount = offer['discount'];

                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0, // Minimalist flat design
                                    child: ListTile(
                                      title: Text(
                                        offerName ?? 'Unknown Offer',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w500, // Set to 500
                                          color: Colors.black87,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${discount?.toString() ?? '0.0'}% off',
                                            style: GoogleFonts.lato(
                                              fontSize: 12,
                                              fontWeight: FontWeight
                                                  .w400, // Keeping at 400 for regular text
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () => _applyOffer(offer),
                                            child: Text(
                                              'Apply',
                                              style: GoogleFonts.lato(
                                                  color: Color(
                                                      0xFF0056D0)), // Use Lato font
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              backgroundColor: Colors
                                                  .transparent, // Remove background
                                              minimumSize: Size(
                                                  0, 0), // Remove minimum size
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _applyOffer(offer),
                                    ),
                                  );
                                },
                              )
                : Container(),
          ),
        ],
      ],
    );
  }
}
