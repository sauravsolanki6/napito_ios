import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/offers%20and%20membership/giftcard_list.dart';
import 'package:ms_salon_task/offers%20and%20membership/giftcardpayment.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ms_salon_task/main.dart';

class BuyGiftCardPage extends StatefulWidget {
  @override
  _BuyGiftCardPageState createState() => _BuyGiftCardPageState();
}

class _BuyGiftCardPageState extends State<BuyGiftCardPage> {
  List<dynamic> giftcards = [];
  String responseMessage = 'Fetching available gift cards...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableGiftCards();
  }

  Future<void> fetchAvailableGiftCards() async {
    setState(() {
      isLoading = true;
    });

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

    final url = Uri.parse('${MyApp.apiUrl}/customer/store-giftcards');
    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('giftcard response $data');
        if (data['status'] == 'true') {
          setState(() {
            giftcards = data['data'];
            responseMessage = '';
          });
        } else {
          setState(() {
            responseMessage = 'Error: ${data['message']}';
          });
        }
      } else {
        setState(() {
          responseMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Failed to fetch gift cards: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await fetchAvailableGiftCards();
  }

  Future<void> _buyGiftCard(String giftCardId) async {
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
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          _showSuccessDialog();
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty || branchID.isEmpty || salonID.isEmpty) {
        print('Missing required parameters.');
      }
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);
      await errorLogger.setGiftcardId(giftCardId);
      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> buygiftcard",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );
      setState(() {
        responseMessage = 'Failed to fetch gift cards: $e';
      });
      // Print the error for debugging
      print('Error in buygiftcard: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
      print('Error: $e');
      _showErrorDialog('Failed to buy gift card: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Success',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomColors.backgroundtext, // Your primary color
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  color: CustomColors.backgroundtext, size: 40), // Success icon
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gift card purchased successfully!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GiftcardList(), // Adjust this to your GiftCardList page
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                backgroundColor: CustomColors.backgroundtext,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    return Color(int.parse("FF$hex", radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define custom colors
    final List<Color> customColors = [
      Color(0xFF8C75F5), // #8C75F5
      // Color(0xFFF677CF), // #F677CF
      // Color(0xFFEC5B75), // #EC5B75
      // Color.fromARGB(255, 84, 101, 248), // #8C75F5
    ];

    return Scaffold(
      backgroundColor: CustomColors.backgroundLight,
      appBar: AppBar(
        title: Text('Buy Gift Cards', style: TextStyle(color: Colors.black)),
        backgroundColor: CustomColors.backgroundPrimary,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : giftcards.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/nodata2.png', // Replace with your image path
                            height: MediaQuery.of(context).size.height *
                                0.4, // 40% of screen height
                            width: MediaQuery.of(context).size.width *
                                0.7, // 70% of screen width
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: giftcards.length,
                    itemBuilder: (context, index) {
                      final giftcard = giftcards[index];

                      // Pick a random color from the list
                      final randomColor = Color(int.parse(
                        '0xff${giftcard['background_color'].substring(1)}',
                      ));
                      // Set text color to white
                      final textColor = Color(int.parse(
                        '0xff${giftcard['text_color'].substring(1)}',
                      ));

                      return GestureDetector(
                        onTap: () {
                          // Handle card tap logic here
                        },
                        child: Container(
                          width: screenWidth * 0.9, // Thinner card width
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color:
                                randomColor, // Use random color from the customColors list
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey
                            //         .withOpacity(0.3), // Shadow effect
                            //     spreadRadius: 3,
                            //     blurRadius: 8,
                            //     offset: Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      giftcard['giftcard_name'],
                                      style: GoogleFonts.lato(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textColor, // White text
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Code: ${giftcard['giftcard_code']}',
                                      style: GoogleFonts.lato(
                                        color: textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    // SizedBox(height: 6),
                                    // Text(
                                    //   'Discount: ${giftcard['discount_text']}',
                                    //   style: GoogleFonts.lato(
                                    //     color: textColor,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    SizedBox(height: 6),
                                    // Text(
                                    //   'Giftcard Worth Price: ${giftcard['offered_price']}',
                                    //   style: GoogleFonts.lato(
                                    //     color: textColor,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    SizedBox(height: 6),
                                    // Text(
                                    //   'Min Booking: ₹${giftcard['min_booking_amt']}',
                                    //   style: GoogleFonts.lato(
                                    //     color: textColor,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    SizedBox(
                                        height: 2), // Extra spacing for clarity
                                    Divider(
                                      color: Colors.white.withOpacity(
                                          0.5), // Subtle white divider
                                    ),
                                    // SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Purchase Price: ₹${giftcard['final_buy_price']}',
                                              style: GoogleFonts.lato(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    textColor, // White text for the price
                                              ),
                                            ),
                                            Text(
                                              '(Including GST)',
                                              style: GoogleFonts.lato(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: textColor.withOpacity(
                                                    0.7), // Slightly lighter color for the GST text
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _showBuyConfirmationDialog(
                                                giftcard['giftcard_id']);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors
                                                .white, // Transparent background for flat style
                                            foregroundColor: Colors
                                                .black, // Button text color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // Rounded button
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 5), // Padding
                                          ),
                                          child: Text(
                                            'BUY NOW',
                                            style: GoogleFonts.lato(
                                              color:
                                                  randomColor, // Button text matches card background
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Positioned gift card icon
                              Positioned(
                                top: MediaQuery.of(context).size.height *
                                    0.01, // Adjust for vertical alignment
                                right: MediaQuery.of(context).size.width *
                                    0.02, // Adjust for right alignment
                                child: Icon(
                                  Icons.card_giftcard, // Gift card icon
                                  size: MediaQuery.of(context).size.height *
                                      0.1, // Adjust size with MediaQuery
                                  color: Colors
                                      .white, // Slight transparency for subtlety
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

  void _showBuyConfirmationDialog(String giftCardId) {
    // Find the selected gift card based on its ID
    final selectedGiftCard = giftcards
        .firstWhere((giftcard) => giftcard['giftcard_id'] == giftCardId);

    print('Selected Gift Card: $selectedGiftCard'); // Debug output

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Purchase',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomColors.backgroundtext, // Your primary color
            ),
          ),
          content: Text(
            'Do you want to buy this gift card?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Save gift card data to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'giftCardId', selectedGiftCard['giftcard_id']);
                await prefs.setString(
                    'giftCardName', selectedGiftCard['giftcard_name']);
                // await prefs.setString(
                //     'giftCardGender', selectedGiftCard['giftcard_gender']);
                await prefs.setString(
                    'giftCardCode', selectedGiftCard['giftcard_code']);
                await prefs.setString('giftCardPrice',
                    selectedGiftCard['final_buy_price'].toString());
                await prefs.setString('giftCardMinBooking',
                    selectedGiftCard['min_booking_amt'].toString());
                await prefs.setString('isGstApplicable',
                    selectedGiftCard['is_gst_applicable'].toString());
                await prefs.setString(
                    'gstRate', selectedGiftCard['salon_gst_rate'].toString());
                await prefs.setString(
                    'gstAmt', selectedGiftCard['gst_amount'].toString());
                await prefs.setString(
                    'regPrice', selectedGiftCard['regular_price'].toString());

                // Debugging output
                print('Gift Card ID: ${selectedGiftCard['giftcard_id']}');
                print('Gift Card Name: ${selectedGiftCard['giftcard_name']}');
                print('Gift Card Code: ${selectedGiftCard['giftcard_code']}');
                // print(
                //     'Gift Card Gender: ${selectedGiftCard['giftcard_gender']}');
                print(
                    'Gift Card Price: ₹${selectedGiftCard['final_buy_price']}');
                print(
                    'Minimum Booking Amount: ₹${selectedGiftCard['min_booking_amt']}');
                print(
                    'GST Applicable: ${selectedGiftCard['is_gst_applicable']}');
                print('GST Rate: ${selectedGiftCard['salon_gst_rate']}%');
                print('GST Amount: ₹${selectedGiftCard['gst_amount']}');
                print('Regular Price: ₹${selectedGiftCard['regular_price']}');

                // Convert values to double
                double giftCardPrice = double.tryParse(
                        selectedGiftCard['final_buy_price'].toString()) ??
                    0.0;
                double minBookingAmount = double.tryParse(
                        selectedGiftCard['min_booking_amt'].toString()) ??
                    0.0;
                double gstRate = double.tryParse(
                        selectedGiftCard['salon_gst_rate'].toString()) ??
                    0.0;
                double gstAmount = double.tryParse(
                        selectedGiftCard['gst_amount'].toString()) ??
                    0.0;
                double regPrice = double.tryParse(
                        selectedGiftCard['regular_price'].toString()) ??
                    0.0;

                // Convert is_gst_applicable to boolean
                int isGstApplicableInt = int.tryParse(
                        selectedGiftCard['is_gst_applicable'].toString()) ??
                    0;
                bool isGstApplicable = (isGstApplicableInt == 1);

                // Debugging output
                print('isGstApplicable (int): $isGstApplicableInt');
                print('isGstApplicable (bool): $isGstApplicable');

                // Navigate to the GiftCardConfirmationPage
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftCardConfirmationPage(
                      giftCardId: selectedGiftCard['giftcard_id'],
                      giftCardName: selectedGiftCard['giftcard_name'],
                      giftCardCode: selectedGiftCard['giftcard_code'],
                      giftCardGender: selectedGiftCard['giftcard_gender'],
                      giftCardPrice: giftCardPrice, // Pass as double
                      minBookingAmount: minBookingAmount, // Pass as double
                      isGstApplicable: isGstApplicable, // Pass as bool
                      gstRate: gstRate, // Pass as double
                      gstAmount: gstAmount, // Pass as double
                      regPrice: regPrice,
                    ),
                  ),
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
