import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/main.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'buy_gift_card_page.dart'; // Import the new page

class GiftcardList extends StatefulWidget {
  @override
  _GiftcardListState createState() => _GiftcardListState();
}

class _GiftcardListState extends State<GiftcardList> {
  List<dynamic> giftcards = [];
  String responseMessage = 'Fetching gift cards...';
  bool isLoading = true;
  String? selectedStoreName;
  String _storeCode = '';
  @override
  void initState() {
    super.initState();
    fetchGiftCards();
    getStoredValues();
    _fetchStoreProfile();
  }

  Future<void> _fetchStoreProfile() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      // Initialize SharedPreferences to retrieve branchID and salonID
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Set up request body
      final Map<String, String> requestBody = {
        "salon_id": salonID,
        "branch_id": branchID,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse("${MyApp.apiUrl}customer/store-profile/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Debugging output
      print("Response status: ${response.statusCode}");
      print("Response body of store profile: ${response.body}");

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Check the response status as a string
        if (responseData['status'] == "true") {
          // Debugging before setting
          print(
              "Store Code from response: ${responseData['data']['branch_unique_code']}");

          setState(() {
            _storeCode = responseData['data']['branch_unique_code'] ?? '';
          });
          print("Branch Code after setState: $_storeCode");
        } else {
          print("Error: ${responseData['message']}");
        }
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> storeProfile",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in storeProfile: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      throw Exception('Failed to fetch storeProfile: $e');
    }
  }

  Future<void> getStoredValues() async {
    final prefs = await SharedPreferences.getInstance();

    final storedStoreName =
        prefs.getString('store_name'); // Retrieve store name

    setState(() {
      selectedStoreName = storedStoreName; // Set the retrieved store name
    });

    print('Stored Store Name: $storedStoreName');
  }

  final List<Color> customColors = [
    const Color(0xFF8C75F5), // #8C75F5
    const Color(0xFFF677CF), // #F677CF
    const Color(0xFFEC5B75), // #EC5B75
    // Color(0xFFF9CA51), // #F9CA51
  ];

// Function to get a random color from the custom colors list
  Color getRandomColor() {
    Random random = Random();
    return customColors[random.nextInt(customColors.length)];
  }

  Future<void> fetchGiftCards() async {
    setState(() {
      isLoading = true; // Start loading
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

    if (customerId.isEmpty) {
      setState(() {
        responseMessage = 'No valid customer ID found';
        isLoading = false; // End loading
      });
      return;
    }

    final url = Uri.parse('${MyApp.apiUrl}/customer/giftcards/');
    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
    });
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('Request URL: $url');

      print('Request Body of Giftcard List: $body');
      // Print the response body
      print('Response body of giftcard: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchgiftcard",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );
      setState(() {
        responseMessage = 'Failed to fetch gift cards: $e';
      });
      // Print the error for debugging
      print('Error in fetchgiftcard: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // End loading
      });
    }
  }

  Future<void> _onRefresh() async {
    await fetchGiftCards();
    _fetchStoreProfile();
  }

  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _navigateToBuyGiftCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BuyGiftCardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin =
        MediaQuery.of(context).size.width * 0.05; // 5% margin

    return WillPopScope(
      onWillPop: () async {
        // This will navigate back to the first occurrence of `HomePage` in the stack
        Navigator.of(context).pop((route) => route.isFirst);

        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Use back arrow icon
            onPressed: () {
              // This will navigate back to the first occurrence of `HomePage` in the stack
              Navigator.of(context).pop((route) => route.isFirst);

              // Navigator.pop(context); // Pop the current page to go back
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => HomePage(
              //       title: '',
              //     ),
              //   ),
              // );
            },
          ),
          title: Text(
            'Gift Cards',
            style: GoogleFonts.lato(), // Use Google Fonts here
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: _navigateToBuyGiftCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.backgroundtext,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  foregroundColor: Colors.white, // Set text color to white
                ),
                child: Text(
                  'Buy Gift Card',
                  style: GoogleFonts.lato(),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
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
                        final cardColor = Color(int.parse(
                            '0xff${giftcard['background_color'].substring(1)}')); // Extract color

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 5.0),
                          // elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: cardColor,
                          child: Stack(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                    ),
                                    color: Colors.white, // Background color
                                    border: Border(
                                      // top: BorderSide.none,
                                      right: BorderSide(
                                        color: CustomColors.backgroundtext,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: CustomColors.backgroundtext,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: CustomColors.backgroundtext,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(height: 40),
                                      Expanded(
                                        child: Text(
                                          'Code: ${giftcard['giftcard_code']}', // Adding the label and gift card code
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(
                                              int.parse(
                                                '0xff${giftcard['text_color'].substring(1)}',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (giftcard['status_text'] !=
                                          'Used') ...[
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                  text: giftcard[
                                                      'giftcard_code']),
                                            ).then((_) {
                                              // Optional SnackBar or feedback logic
                                            });
                                          },
                                          child: Icon(
                                            CupertinoIcons.doc_on_clipboard,
                                            size: 22,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            // Determine gender text based on value
                                            String genderText =
                                                giftcard['giftcard_gender'] == 0
                                                    ? 'Male'
                                                    : 'Female';

                                            String code =
                                                giftcard['giftcard_code'];
                                            String customer =
                                                giftcard['customer_name'];

                                            // Construct the deep link URL for the app with the referrer
                                            String pageId = "giftcard_page";
                                            String playStoreBaseUrl =
                                                "https://play.google.com/store/apps/details?id=com.quick.napito2";
                                            String deepLinkUrl =
                                                "$playStoreBaseUrl&referrer=courselist_pageId=$pageId&giftcard_code=$code&saloon_code=$_storeCode";

                                            // Share the message via URL intent
                                            Share.share(
                                              '🎉 Congratulations!\n'
                                              'You’ve received an exclusive Gift Card from $customer 🎁\n\n'
                                              '🌟 Gift Card Details 🌟\n'
                                              '• Gift Card Name: ${giftcard['giftcard_name']}\n'
                                              '• Code: ${giftcard['giftcard_code']}\n\n'
                                              '💡 How to Redeem 💡\n\n'
                                              '1. Download the Napito App from the link below.\n\n'
                                              '2. Sign up or log in to your account.\n\n'
                                              '3. Enter the Gift Card Code in the app to redeem your offer!\n\n\n'
                                              '🛍 Terms & Conditions 🛍\n\n'
                                              'This gift card is applicable at $selectedStoreName only.\n\n'
                                              'Valid for $genderText Customers only.\n\n'
                                              'Non-transferable and cannot be exchanged for cash.\n\n\n'
                                              '📲 Download Napito 📲\n'
                                              '👉 $deepLinkUrl\n\n' // Deep link now included in the URL
                                              '📞 Need Assistance?\n'
                                              'For any queries, feel free to contact us at schedulesavvy10@gmail.com.\n\n',
                                              subject:
                                                  'Your Exclusive Gift Card from Napito App',
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Color(
                                                int.parse(
                                                  '0xff${giftcard['text_color'].substring(1)}',
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.share,
                                              size: 20,
                                              color: Colors
                                                  .white, // Contrast color for visibility
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 38),
                                    Text(
                                      giftcard['giftcard_name'],
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(int.parse(
                                            '0xff${giftcard['text_color'].substring(1)}')),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      children: [
                                        Text(
                                          'Purchase Price: ',
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Color(
                                              int.parse(
                                                  '0xff${giftcard['text_color'].substring(1)}'),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${giftcard['purchase_price'] ?? 0}',
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Color(
                                              int.parse(
                                                  '0xff${giftcard['text_color'].substring(1)}'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       'Giftcard Worth Price: ',
                                    //       style: GoogleFonts.lato(
                                    //         fontSize: 16,
                                    //         color: Color(int.parse(
                                    //             '0xff${giftcard['text_color'].substring(1)}')),
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       '₹${giftcard['offered_price']}',
                                    //       style: GoogleFonts.lato(
                                    //         fontSize: 16,
                                    //         color: Color(int.parse(
                                    //             '0xff${giftcard['text_color'].substring(1)}')),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 4),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       'Current Balance: ',
                                    //       style: GoogleFonts.lato(
                                    //         fontSize: 16,
                                    //         color: Color(int.parse(
                                    //             '0xff${giftcard['text_color'].substring(1)}')),
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       '₹${giftcard['giftcard_balance']}',
                                    //       style: GoogleFonts.lato(
                                    //         fontSize: 16,
                                    //         color: Color(int.parse(
                                    //             '0xff${giftcard['text_color'].substring(1)}')),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 4),
                                    if (giftcard['status_text'] != 'Used') ...[
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        child: GestureDetector(
                                          onTap: () async {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();

                                            // Ensure giftcard name and code are being retrieved correctly
                                            final giftCardCode =
                                                giftcard['giftcard_code'] ?? '';
                                            final giftCardName =
                                                giftcard['giftcard_name'] ?? '';

                                            // Only store if the gift card code exists
                                            if (giftCardCode.isNotEmpty) {
                                              await prefs.setString(
                                                  'gift_card_code',
                                                  giftCardCode);
                                              await prefs.setString(
                                                  'gift_card_name',
                                                  giftCardName);
                                              print(giftCardName);
                                              // Navigate to the BookAppointmentPage
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookAppointmentPage()),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color:
                                                  CustomColors.backgroundLight,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Colors
                                                    .white, // Border color
                                                width: 1, // Border width
                                              ),
                                            ),
                                            child: Text(
                                              'Use Gift Card',
                                              style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       'Min Booking Amount: ',
                                    //       style: GoogleFonts.lato(
                                    //         fontSize: 16,
                                    //         color: Color(int.parse(
                                    //             '0xff${giftcard['text_color'].substring(1)}')),
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       '₹${giftcard['giftcard_min_booking_amount']}',
                                    //       style: GoogleFonts.lato(
                                    //         fontSize: 16,
                                    //         color: Color(int.parse(
                                    //             '0xff${giftcard['text_color'].substring(1)}')),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 8),
                                    if (giftcard['redemptions'] != null &&
                                        giftcard['redemptions'].isNotEmpty) ...[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          foregroundColor: cardColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            giftcard['expanded'] =
                                                !(giftcard['expanded'] ??
                                                    false);
                                          });
                                        },
                                        child: Text(giftcard['expanded'] == true
                                            ? 'Hide Redemptions'
                                            : 'Show Redemptions'),
                                      ),
                                      if (giftcard['expanded'] == true) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          'Redemptions:',
                                          style: GoogleFonts.lato(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(int.parse(
                                                '0xff${giftcard['text_color'].substring(1)}')),
                                          ),
                                        ),
                                        ...giftcard['redemptions']
                                            .map<Widget>((redemption) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Booking ID: ${redemption['booking_id']}',
                                                  style: GoogleFonts.lato(
                                                      color: Color(int.parse(
                                                          '0xff${giftcard['text_color'].substring(1)}'))),
                                                ),
                                                redemption['redeemed_by'] == '-'
                                                    ? SizedBox.shrink()
                                                    : Text(
                                                        'Redeemed By: ${redemption['redeemed_by']}',
                                                        style: GoogleFonts.lato(
                                                          color: Color(int.parse(
                                                              '0xff${giftcard['text_color'].substring(1)}')),
                                                        ),
                                                      ),
                                                Text(
                                                  'Redeemed Amount: ₹${redemption['redeemed_amount']}',
                                                  style: GoogleFonts.lato(
                                                      color: Color(int.parse(
                                                          '0xff${giftcard['text_color'].substring(1)}'))),
                                                ),
                                                Text(
                                                  'Redeemed On: ${redemption['redeemed_on']}',
                                                  style: GoogleFonts.lato(
                                                      color: Color(int.parse(
                                                          '0xff${giftcard['text_color'].substring(1)}'))),
                                                ),
                                                if (redemption[
                                                            'booking_receipt'] !=
                                                        null &&
                                                    redemption[
                                                            'booking_receipt']
                                                        .isNotEmpty) ...[
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Receipt: ',
                                                        style: GoogleFonts.lato(
                                                            color: Color(int.parse(
                                                                '0xff${giftcard['text_color'].substring(1)}'))),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () => _openUrl(
                                                            redemption[
                                                                'booking_receipt']),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 4.0),
                                                          child: Icon(
                                                            Icons.link,
                                                            color: Colors.white,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: GestureDetector(
                                  onTap: () => _openUrl(giftcard['receipt']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: CustomColors.backgroundtext,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        topRight: Radius.circular(0),
                                      ),
                                      border: Border.all(
                                        color: Colors
                                            .black, // Use the `cardColor` or any desired color
                                        width:
                                            1, // Adjust the width of the border
                                      ),
                                    ),
                                    child: Text(
                                      'View Receipt',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Status: ${giftcard['status_text'] ?? 'N/A'}',
                                    style: GoogleFonts.lato(
                                      color: Color(int.parse(
                                        '0xff${giftcard['text_color'].substring(1)}',
                                      )),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.1,
                                right:
                                    MediaQuery.of(context).size.height * 0.02,
                                child: Icon(
                                  Icons.card_giftcard,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
