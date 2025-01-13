import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart'; // Ensure this contains the required colors
import 'package:shared_preferences/shared_preferences.dart';

class AllCouponsPage extends StatelessWidget {
  final List<dynamic> coupons;
  final Function(String) onApplyCoupon;
  final Future<void> Function() onRefresh;

  AllCouponsPage({
    required this.coupons,
    required this.onApplyCoupon,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate margin based on screen width
    final horizontalMargin = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      appBar: AppBar(
        title: Text('All Coupons'),
        backgroundColor: CustomColors.backgroundLight, // Consistent color theme
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            final coupon = coupons[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: horizontalMargin,
              ), // Reduced vertical padding
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1.0, // Border for card
                  ),
                ),
                color: Color(0xFFFFF3CD),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon['coupon_name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF664E0B),
                            ),
                          ),
                          SizedBox(
                              height: 4), // Reduced space between text elements
                          Text(
                            'Minimum Amount: ${coupon['minimum_amount']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Offered Price: ${coupon['offered_price']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4), // Reduced space
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      left: 8,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            onApplyCoupon(coupon['coupon_code']);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF664E0B).withOpacity(0.1),
                            foregroundColor: Color(0xFF664E0B),
                            textStyle: TextStyle(
                              fontSize: 12,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4), // Adjusted padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text('Apply'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
