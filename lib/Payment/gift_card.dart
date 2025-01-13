import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class GiftCardWidget extends StatefulWidget {
  final VoidCallback onGiftCardChanged;

  GiftCardWidget({required this.onGiftCardChanged});

  @override
  _GiftCardWidgetState createState() => _GiftCardWidgetState();
}

class _GiftCardWidgetState extends State<GiftCardWidget> {
  bool _isLoading = false;
  bool isGiftCardInvalid = false; // Global flag to track gift card validity
  TextEditingController _giftCardNumberController = TextEditingController();
  Map<String, dynamic>? _appliedGiftCard;
  String? giftCardDiscountAmount;
  @override
  void initState() {
    super.initState();
    _checkAndApplyGiftCard();
    _loadAppliedGiftCard();
    _loadAppliedGiftCards();
    _giftCardNumberController.addListener(_convertTextToUpperCase);
  }

  Future<void> _checkAndApplyGiftCard() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if a gift card code is saved in SharedPreferences
    final savedGiftCardCode = prefs.getString('gift_card_code') ?? '';

    if (savedGiftCardCode.isNotEmpty) {
      // Set the gift card number in the controller if found
      _giftCardNumberController.text = savedGiftCardCode;

      // Apply the gift card immediately
      await _applyGiftCard();
    }
  }

  Future<void> _loadAppliedGiftCards() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the gift card discount amount from SharedPreferences
    final discountAmount = prefs.getString('giftcard_discount_amount');

    setState(() {
      giftCardDiscountAmount = discountAmount; // Store the value
    });
  }

  @override
  void dispose() {
    _giftCardNumberController.removeListener(_convertTextToUpperCase);
    _giftCardNumberController.dispose();
    super.dispose();
  }

  void _convertTextToUpperCase() {
    final text = _giftCardNumberController.text.toUpperCase();
    if (_giftCardNumberController.text != text) {
      _giftCardNumberController.value =
          _giftCardNumberController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  Future<void> _fetchGiftCardDetails() async {
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
        Uri.parse('${MyApp.apiUrl}customer/giftcard-details/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salon_id': salonID,
          'branch_id': branchID,
          'customer_id': customerId,
          'giftcard_no': _giftCardNumberController.text.trim(),
        }),
      );

      // Print the response body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body of Giftcard: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> giftCardMap = jsonDecode(response.body);

        print(
            'Parsed Response: $giftCardMap'); // Ensure this contains the right keys

        if (giftCardMap['status'] == 'true') {
          final giftCardData = giftCardMap['data'];

          if (giftCardData != null) {
            final giftCardDetails = {
              'giftcard_redemption_id': giftCardData['giftcard_redemption_id'],
              'giftcard_owner_id': giftCardData['giftcard_owner_id'],
              'giftcard_min_amount': giftCardData['giftcard_min_amount'],
              'giftcard_discount_amount':
                  giftCardData['giftcard_discount_amount'],
            };

            setState(() {
              _appliedGiftCard = giftCardDetails;
              _isLoading = false;
            });

            // Save gift card details in SharedPreferences
            await prefs.setString('giftcard_redemption_id',
                giftCardData['giftcard_redemption_id']);
            await prefs.setString(
                'giftcard_min_amount', giftCardData['giftcard_min_amount']);
            await prefs.setString('giftcard_discount_amount',
                giftCardData['giftcard_discount_amount']);
            await prefs.setBool('giftcard_applied', true);

            // Reset the invalid gift card flag in case the card is valid
            isGiftCardInvalid = false;

            print('Gift card applied successfully: $giftCardDetails');
          } else {
            print('Gift card data is missing in the response.');
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          print('Gift card status is false. Response: $giftCardMap');

          // Set the global flag to true if the gift card is invalid
          isGiftCardInvalid = true;

          // Clear the saved gift card details if the status is false
          await prefs.remove('giftcard_redemption_id');
          await prefs.remove('giftcard_min_amount');
          await prefs.remove('giftcard_discount_amount');
          await prefs.setBool('giftcard_applied', false);
          await prefs.remove('gift_card_code');
          // Show a Snackbar with the error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The gift card number entered is not valid.'),
              backgroundColor: Colors.red,
            ),
          );

          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print(
            'Failed to fetch gift card details. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching gift card details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _fetchGiftCardDetails() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? customerId1 = prefs.getString('customer_id');
  //     final String? customerId2 = prefs.getString('customer_id2');
  //     final String branchID = prefs.getString('branch_id') ?? '';
  //     final String salonID = prefs.getString('salon_id') ?? '';
  //     final String customerId = customerId1?.isNotEmpty == true
  //         ? customerId1!
  //         : customerId2?.isNotEmpty == true
  //             ? customerId2!
  //             : '';

  //     final response = await http.post(
  //       Uri.parse(
  //           '${MyApp.apiUrl}customer/giftcard-details/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'salon_id': salonID,
  //         'branch_id': branchID,
  //         'customer_id': customerId,
  //         'giftcard_no': _giftCardNumberController.text.trim(),
  //       }),
  //     );

  //     // Print the response body for debugging
  //     print('Response status: ${response.statusCode}');
  //     print('Response body of Giftcard: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> giftCardMap = jsonDecode(response.body);

  //       print(
  //           'Parsed Response: $giftCardMap'); // Ensure this contains the right keys

  //       if (giftCardMap['status'] == 'true') {
  //         final giftCardData = giftCardMap['data'];

  //         if (giftCardData != null) {
  //           final giftCardDetails = {
  //             'giftcard_redemption_id': giftCardData['giftcard_redemption_id'],
  //             'giftcard_min_amount': giftCardData['giftcard_min_amount'],
  //             'giftcard_discount_amount':
  //                 giftCardData['giftcard_discount_amount'],
  //           };

  //           setState(() {
  //             _appliedGiftCard = giftCardDetails;
  //             _isLoading = false;
  //           });

  //           // Save gift card details in SharedPreferences
  //           final prefs = await SharedPreferences.getInstance();
  //           await prefs.setString('giftcard_redemption_id',
  //               giftCardData['giftcard_redemption_id']);
  //           await prefs.setString(
  //               'giftcard_min_amount', giftCardData['giftcard_min_amount']);
  //           await prefs.setString('giftcard_discount_amount',
  //               giftCardData['giftcard_discount_amount']);
  //           await prefs.setBool('giftcard_applied', true);

  //           print('Gift card applied successfully: $giftCardDetails');
  //         } else {
  //           print('Gift card data is missing in the response.');
  //           setState(() {
  //             _isLoading = false;
  //           });
  //         }
  //       } else {
  //         print('Gift card status is false. Response: $giftCardMap');
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     } else {
  //       print(
  //           'Failed to fetch gift card details. Status code: ${response.statusCode}');
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching gift card details: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _loadAppliedGiftCard() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve gift card details from SharedPreferences
    final giftCardId = prefs.getString('giftcard_id');
    final giftCardMinAmount = prefs.getString('giftcard_min_amount');
    giftCardDiscountAmount =
        prefs.getString('giftcard_discount_amount'); // Set the global variable
    final isGiftCardApplied = prefs.getBool('giftcard_applied');

    if (giftCardId != null &&
        giftCardMinAmount != null &&
        giftCardDiscountAmount != null &&
        isGiftCardApplied == true) {
      setState(() {
        _appliedGiftCard = {
          'giftcard_id': giftCardId,
          'giftcard_min_amount': giftCardMinAmount,
          'giftcard_discount_amount': giftCardDiscountAmount,
        };
      });
    }

    // Print the global giftCardDiscountAmount
    print(
        'Is gift card applied: $giftCardDiscountAmount ${isGiftCardApplied ?? false}');

    // Store giftCardDiscountAmount in SharedPreferences (if necessary)
    if (giftCardDiscountAmount != null) {
      prefs.setString('giftcard_discount_amount',
          giftCardDiscountAmount!); // Save the value in SharedPreferences
    }
  }

  Future<void> _removeAppliedGiftCard() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove individual gift card-related entries
    await prefs.remove('giftcard_id');
    await prefs.remove('gift_card_code');
    await prefs.remove('giftcard_min_amount');
    await prefs.remove('giftcard_discount_amount');
    await prefs.remove('giftcard_applied');

    // Remove the combined gift card details JSON entry
    await prefs.remove('giftcard_details');

    setState(() {
      _appliedGiftCard = null;
    });

    widget.onGiftCardChanged();
  }

  Future<void> _applyGiftCard() async {
    final giftCardNo = _giftCardNumberController.text.trim();

    if (giftCardNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a gift card number.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isGiftCardApplied = prefs.getBool('giftcard_applied') ?? false;
    final isOfferApplied = prefs.getBool('offer_applied') ?? false;
    final isCouponApplied = prefs.getBool('coupon_applied') ?? false;
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
    if (isOfferApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An offer has already been applied.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isCouponApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A coupon has already been applied.'),
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

    // Retrieve the subtotal from SharedPreferences
    final double subtotal = prefs.getDouble('subtotal') ?? 0.0;

    // Fetch gift card details from SharedPreferences or your API
    await _fetchGiftCardDetails();

    if (_appliedGiftCard != null) {
      // Get the minimum amount required for the gift card
      final double giftCardMinAmount =
          double.parse(_appliedGiftCard!['giftcard_min_amount'].toString());

      // Check if the subtotal is less than the minimum amount required for the gift card
      // if (subtotal < giftCardMinAmount) {
      //   // Check if the gift card is invalid
      //   if (!isGiftCardInvalid) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //             'The subtotal must be at least ₹$giftCardMinAmount to use this gift card.'),
      //         duration: Duration(seconds: 2),
      //       ),
      //     );
      //   }

      //   // Clear relevant SharedPreferences when gift card cannot be applied
      //   await _clearGiftCardPreferences();
      //   return;
      // }

      // Proceed with applying the gift card if the subtotal is sufficient
      final giftCardDetails = jsonEncode({
        'is_giftcard_applied': 1,
        'applied_giftcard_id': _appliedGiftCard!['giftcard_redemption_id'],
        'giftcard_owner_id': _appliedGiftCard!['giftcard_owner_id'],
      });

      // Save the gift card details to SharedPreferences
      await prefs.setString('giftcard_details', giftCardDetails);

      // Print the saved gift card details from SharedPreferences
      final savedGiftCardDetails = prefs.getString('giftcard_details');
      print('Saved Gift Card Details: $savedGiftCardDetails');

      print('Gift card applied: ${_appliedGiftCard!}');
      widget.onGiftCardChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gift card number not found or invalid.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear relevant SharedPreferences when gift card is invalid
      await _clearGiftCardPreferences();
    }
  }

  Future<void> _clearGiftCardPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear the gift card-related preferences
    await prefs.remove('giftcard_id');
    await prefs.remove('giftcard_min_amount');
    await prefs.remove('giftcard_discount_amount');
    await prefs.remove('giftcard_applied');
    await prefs.remove('giftcard_details');
    await prefs.remove('gift_card_code');
    // Optionally, you can clear other relevant preferences if needed
    // For example, if you want to clear the subtotal or offer-related preferences
    await prefs.remove('subtotal'); // If you want to reset the subtotal
    await prefs.remove('offer_applied'); // Clear offer preference if needed

    print('Gift card preferences cleared.');
  }

  @override
  Widget build(BuildContext context) {
    print('_appliedGiftCard is $giftCardDiscountAmount');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (giftCardDiscountAmount != null)
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: 1.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50, // Light background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.grey.shade300, width: 1), // Minimal border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gift Card Applied',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Show gift card balance with ₹ symbol
                          Text(
                            'Balance: ₹$giftCardDiscountAmount',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Colors.blueGrey.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.close, color: Colors.redAccent, size: 20),
                      onPressed: _removeAppliedGiftCard,
                    ),
                  ],
                ),
              ),
            ),
          if (giftCardDiscountAmount == null) ...[
            Text(
              'Enter your gift card number to apply the discount.',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _giftCardNumberController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Gift Card Number',
                      labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: CustomColors.backgroundtext),
                      ),
                      suffixIcon: Icon(
                        Icons.card_giftcard,
                        color: Colors.blueGrey.shade600,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: _applyGiftCard,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        CustomColors.backgroundtext, // Custom color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.backgroundtext,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
