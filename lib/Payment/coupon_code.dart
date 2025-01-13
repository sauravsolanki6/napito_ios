import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart'; // Adjust if needed
import 'package:ms_salon_task/Payment/dotted_line.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'all_coupons_page.dart'; // Import the new page

class CouponCodeWidget extends StatefulWidget {
  final VoidCallback onCouponChanged;

  CouponCodeWidget({required this.onCouponChanged});

  @override
  _CouponCodeWidgetState createState() => _CouponCodeWidgetState();
}

class _CouponCodeWidgetState extends State<CouponCodeWidget> {
  List<dynamic> _coupons = [];
  bool _isLoading = false;
  String? _appliedCoupon;
  bool _showAllCoupons = false;

  @override
  void initState() {
    super.initState();
    _loadAppliedCoupon();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() {
      _isLoading = true;
    });

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
        Uri.parse('${MyApp.apiUrl}customer/store-coupons/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salon_id': salonID,
          'branch_id': branchID,
          'customer_id': customerId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> couponsMap = jsonDecode(response.body);

        if (couponsMap['status'] == 'true') {
          setState(() {
            _coupons = couponsMap['data'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching coupons: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppliedCoupon() async {
    final prefs = await SharedPreferences.getInstance();
    final String? appliedCouponJson = prefs.getString('coupons_response');

    if (appliedCouponJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(appliedCouponJson);
      final List<dynamic> couponsList = decoded['data'] ?? [];
      if (couponsList.isNotEmpty) {
        setState(() {
          _appliedCoupon = couponsList[0]['coupon_name'];
        });
      }
    }
  }

  double? _savedSubtotal;

  Future<void> _retrieveSubtotal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedSubtotal = prefs.getDouble('subtotal');
    });
  }

  // Future<void> _applyCoupon(String couponCode) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   if (couponCode.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Invalid coupon code.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   final isOfferApplied = prefs.getBool('offer_applied') ?? false;
  //   final isGiftCardApplied = prefs.getBool('giftcard_applied') ?? false;

  //   if (isOfferApplied) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An offer has already been applied.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   if (isGiftCardApplied) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('A gift card has already been applied.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   final String? selectedServiceData =
  //       prefs.getString('selected_service_data');
  //   if (selectedServiceData != null) {
  //     final Map<String, dynamic> serviceData = jsonDecode(selectedServiceData);
  //     final packageName = serviceData.values
  //         .map((service) => service['packageName'])
  //         .firstWhere((name) => name != null && name.isNotEmpty,
  //             orElse: () => '');

  //     if (packageName.isNotEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Cannot apply coupons with a package name.'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   await _retrieveSubtotal();

  //   if (_savedSubtotal == null || _savedSubtotal! < 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Subtotal is not available or invalid.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   if (_coupons.isEmpty) {
  //     await _fetchCoupons();
  //   }

  //   final coupon = _coupons.firstWhere(
  //     (c) => c['coupon_code'] == couponCode,
  //     orElse: () => {},
  //   );

  //   if (coupon.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Coupon code not found.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   final minimumAmount =
  //       double.tryParse(coupon['minimum_amount']?.toString() ?? '0') ?? 0;

  //   if (_savedSubtotal! < minimumAmount) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //             'Subtotal is less than the minimum amount required for this coupon.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   final offeredPrice = coupon['offered_price'];

  //   await prefs.setString(
  //     'coupons_response',
  //     jsonEncode({
  //       'status': 'true',
  //       'message': 'Success',
  //       'data': [coupon],
  //     }),
  //   );
  //   await prefs.setString('minimum_amount', minimumAmount.toString());
  //   await prefs.setString('offered_price', offeredPrice);
  //   await prefs.setBool('coupon_applied', true);

  //   final couponDetails = {
  //     'is_coupon_applied': '1',
  //     'applied_coupon_id': coupon['coupon_id'].toString(),
  //   };
  //   await prefs.setString('coupon_details', jsonEncode(couponDetails));

  //   setState(() {
  //     _appliedCoupon = coupon['coupon_name'];
  //   });

  //   widget.onCouponChanged();
  // }
  Future<void> _applyCoupon(String couponCode) async {
    final prefs = await SharedPreferences.getInstance();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid coupon code.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final isOfferApplied = prefs.getBool('offer_applied') ?? false;
    final isGiftCardApplied = prefs.getBool('giftcard_applied') ?? false;
    final isRewardApplied =
        prefs.getBool('reward_applied') ?? false; // Check reward
    if (isRewardApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A reward has already been applied.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    print('isRewardApplied: $isRewardApplied');
    print('isOfferApplied: $isOfferApplied');
    print('isGiftCardApplied: $isGiftCardApplied');

    if (isOfferApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An offer has already been applied.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isGiftCardApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A gift card has been applied'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if the selected service data exists
    final String? selectedServiceData =
        prefs.getString('selected_service_data');
    print('selectedServiceData: $selectedServiceData');

    if (selectedServiceData != null && selectedServiceData.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot apply coupons when a package is selected.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (selectedServiceData != null) {
      final Map<String, dynamic> serviceData = jsonDecode(selectedServiceData);
      final packageName = serviceData.values
          .map((service) => service['packageName'])
          .firstWhere((name) => name != null && name.isNotEmpty,
              orElse: () => '');

      print('packageName: $packageName');

      if (packageName.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot apply coupons with a package name.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // Retrieve the subtotal directly from SharedPreferences
    final subtotal = prefs.getDouble('subtotal') ?? 0.0;
    print('subtotal: $subtotal');

    if (subtotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subtotal is not available or invalid.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_coupons.isEmpty) {
      await _fetchCoupons();
    }

    final coupon = _coupons.firstWhere(
      (c) => c['coupon_code'] == couponCode,
      orElse: () => {},
    );

    print('coupon: $coupon');

    if (coupon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon code not found.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final minimumAmount =
        double.tryParse(coupon['minimum_amount']?.toString() ?? '0') ?? 0;
    print('minimumAmount: $minimumAmount');

    // Use the subtotal retrieved from SharedPreferences for comparison
    if (subtotal < minimumAmount) {
      await prefs.remove('coupon_details'); // Clear the preference
      print(
          'coupon_details after clearing: ${prefs.getString('coupon_details')}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Subtotal is less than the minimum amount required for this coupon.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final offeredPrice = coupon['offered_price'];
    print('offeredPrice: $offeredPrice');

    await prefs.setString(
      'coupons_response',
      jsonEncode({
        'status': 'true',
        'message': 'Success',
        'data': [coupon],
      }),
    );
    await prefs.setString('minimum_amount', minimumAmount.toString());
    await prefs.setString('offered_price', offeredPrice);
    await prefs.setBool('coupon_applied', true);

    final couponDetails = {
      'is_coupon_applied': '1',
      'applied_coupon_id': coupon['coupon_id'].toString(),
    };
    await prefs.setString('coupon_details', jsonEncode(couponDetails));

    print(
        'coupon_details after applying: ${prefs.getString('coupon_details')}');

    setState(() {
      _appliedCoupon = coupon['coupon_name'];
    });

    widget.onCouponChanged();
  }

  Future<void> _removeAppliedCoupon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coupons_response');
    await prefs.remove('minimum_amount');
    await prefs.remove('offered_price');
    await prefs.remove('coupon_applied');
    await prefs.remove('coupon_details');

    setState(() {
      _appliedCoupon = null;
    });

    widget.onCouponChanged();
  }

  void _viewAllCoupons() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllCouponsPage(
          coupons: _coupons,
          onApplyCoupon: (couponCode) {
            _applyCoupon(couponCode);
          },
          onRefresh: () async {
            // Refresh the coupons here. For example, you might want to fetch new data
            // and then update the _coupons list. This should return a Future<void>.
            await _fetchCoupons();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCoupons = _showAllCoupons
        ? _coupons
        : _coupons.take(1).toList(); // Show only one coupon by default

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_appliedCoupon == null) ...[
            Text(
              'Apply a coupon to save on your order',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 24,
                  color: CustomColors.backgroundtext,
                ),
                SizedBox(width: 8),
                Text(
                  'Available Coupons',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.backgroundtext,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.white,
              child: Column(
                children: visibleCoupons.map((coupon) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0), // Reduced padding
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0), // Adjusted padding
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon['coupon_name'],
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Color(0xFF664E0B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                    height: 4), // Add spacing below the title
                                Text(
                                  'Minimum Amount: ${coupon['minimum_amount']}',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Offered Price: ${coupon['offered_price']}',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8), // Add spacing before the button
                          TextButton(
                            onPressed: () =>
                                _applyCoupon(coupon['coupon_code']),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF664E0B).withOpacity(0.1),
                              foregroundColor: Color(0xFF664E0B),
                              textStyle: TextStyle(
                                fontSize: 12,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4), // Adjusted padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Apply',
                              style: GoogleFonts.lato(
                                fontSize:
                                    16, // You can adjust the font size as needed
                                fontWeight: FontWeight
                                    .w500, // Adjust the font weight as needed
                                color:
                                    Color(0xFF664E0B), // Change color if needed
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_coupons.length > 1 && !_showAllCoupons) ...[
              SizedBox(height: 8),
              DottedLine(
                height: 1.0,
                color: CustomColors.backgroundtext,
                dashWidth: 4.0,
                dashSpace: 2.0,
              ),
              SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _viewAllCoupons,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                  child: Text(
                    'View All Coupons',
                    style: GoogleFonts.lato(
                      fontSize: 16, // Adjust the font size as needed
                      fontWeight:
                          FontWeight.w600, // Adjust the font weight as needed
                      color: CustomColors
                          .backgroundtext, // Change the color if needed
                    ),
                  ),
                ),
              ),
            ],
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coupon is applied!',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Color(0xFFFFF3CD).withOpacity(0.4),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$_appliedCoupon',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF664E0B),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _removeAppliedCoupon,
                          child: Icon(
                            Icons.close,
                            color: Color(0xFF664E0B),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
