import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package

class Offers extends StatefulWidget {
  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  List<Map<String, dynamic>> offers = [];
  bool isLoading = true;

  final List<Color> offerColors = [
    Color(0xFF8C75F5), // #8C75F5
    Color(0xFFF677CF), // #F677CF
    Color(0xFFEC5B75),
    Color(0xFFF9CA51),
    // #EC5B75
  ];

  // Function to get a random color
  Color getRandomColor() {
    final random = Random();
    return offerColors[random.nextInt(offerColors.length)];
  }

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');
      final branchId = prefs.getString('branch_id') ?? '';
      final salonId = prefs.getString('salon_id') ?? '';

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      final requestBody = jsonEncode({
        "salon_id": salonId,
        "branch_id": branchId,
        "customer_id": customerId,
      });

      final url = Uri.parse('${MyApp.apiUrl}customer/store-offers/');

      // Print request details
      print('Request URL: $url');
      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      // Print response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the status is 'true'
        if (responseData['status'] == 'true') {
          final offersData = responseData['data'];
          setState(() {
            offers = List<Map<String, dynamic>>.from(offersData);
            isLoading = false;
          });

          // Store only the offers data in SharedPreferences
          await prefs.setString('offers_data', jsonEncode(offersData));
        } else {
          setState(() {
            offers = []; // Set to empty if status is not 'true'
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch offers. Status code: ${response.statusCode}');
        setState(() {
          offers = []; // Set to empty on failure
          isLoading = false;
        });
      }
    } catch (error, stackTrace) {
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
        errorLocation: "Function -> fetchOffers",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );
      print('Error in fetchOffers: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
      print('Error: $e');
      // Ensure the UI updates even if an exception occurs
      setState(() {
        offers = []; // Set to empty on error
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchOffers();
  }

  Future<void> _handleBooking(String offerId) async {
    final prefs = await SharedPreferences.getInstance();
    final salonId = prefs.getString('salon_id') ?? '';
    final branchId = prefs.getString('branch_id') ?? '';
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');

    final customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    final url = Uri.parse('${MyApp.apiUrl}customer/store-offers/');
    final requestBody = jsonEncode({
      "salon_id": salonId,
      "branch_id": branchId,
      "customer_id": customerId,
      "offer_id": offerId,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Booking response: $responseData');

        // Store the JSON response in SharedPreferences
        await prefs.setString('offers_response', response.body);

        // Navigate to the BookAppointmentPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookAppointmentPage()),
        );
      } else {
        print('Failed to book offer. Status code: ${response.statusCode}');
        // Optionally, show an error message to the user here
      }
    } catch (e) {
      print('An error occurred: $e');
      // Optionally, show an error message to the user here
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // This will navigate back to the first occurrence of `HomePage` in the stack
        Navigator.of(context).pop((route) => route.isFirst);

        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  // Navigator.pushNamed(context, '/home');

                  // This will navigate back to the first occurrence of `HomePage` in the stack
                  Navigator.of(context).pop((route) => route.isFirst);
                },
              ),
              Text(
                'Your Offers',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: isLoading
              ? ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Container(
                          height: 137.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : offers.isEmpty
                  ? Center(
                      child: Text(
                        'No offers available',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : ListView(
                      children: offers.map((offer) {
                        // Get a random color for each offer
                        Color randomColor = getRandomColor();

                        return OfferContainer(
                          title: 'Code : ${offer['offer_id']}',
                          description: offer['offer_text'] ?? '',
                          offername: offer['offer_name'] ?? '',
                          expiryDate: offer['validity_text'] ?? '',
                          screenWidth: screenWidth,
                          color: randomColor, // Pass the random color
                          offerIcon: offer['offer_icon'] ?? '',
                          onBookNow:
                              _handleBooking, // Pass the booking callback
                        );
                      }).toList(),
                    ),
        ),
      ),
    );
  }
}

// Reusable Offer Container Widget
// Reusable Offer Container Widget
class OfferContainer extends StatelessWidget {
  final String title;
  final String description;
  final String offername;
  final String expiryDate;
  final double screenWidth;
  final Color color;
  final String offerIcon;
  final Function(String offerId) onBookNow; // Callback for booking

  const OfferContainer({
    Key? key,
    required this.title,
    required this.description,
    required this.offername,
    required this.expiryDate,
    required this.screenWidth,
    required this.color,
    required this.offerIcon,
    required this.onBookNow, // Initialize callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerWidth =
        screenWidth * 0.95; // Adjusted width to fit within the padding
    final containerHeight = 137.0;

    // Split the description into lines of maximum 6 words
    List<String> splitDescription(String text) {
      final words = text.split(' ');
      final lines = <String>[];
      for (int i = 0; i < words.length; i += 6) {
        lines.add(words
            .sublist(i, i + 6 > words.length ? words.length : i + 6)
            .join(' '));
      }
      return lines;
    }

    final descriptionLines = splitDescription(description);

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 20.0), // Reduced margin
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Color(0xFF8C75F5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: containerHeight * 0.02,
              left: screenWidth * 0.633,
              child: CustomPaint(
                painter: DottedLinePainter(
                  lineLength: containerHeight * 0.9,
                  lineWidth: 1,
                  spacing: 3,
                ),
                child: Container(),
              ),
            ),
            Positioned(
              top: containerHeight * 0.79,
              left: screenWidth * 0.58,
              child: Image.asset(
                offerIcon.isNotEmpty
                    ? 'assets/$offerIcon'
                    : 'assets/scissors1.png',
                height: containerHeight * 0.3,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 18.0),
                  child: Transform.translate(
                    offset: Offset(0, 10.0),
                    child: Image.asset(
                      offerIcon.isNotEmpty
                          ? 'assets/$offerIcon'
                          : 'assets/offerss.png',
                      height: containerHeight * 0.5,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 7.0,
              right: 6.0,
              child: GestureDetector(
                onTap: () {
                  onBookNow(title
                      .split(':')[1]
                      .trim()); // Pass the offerId to the callback
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 13.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  constraints: BoxConstraints(minWidth: 60, minHeight: 20),
                  child: Center(
                    child: Text(
                      'BOOK NOW',
                      style: GoogleFonts.lato(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8C75F5),
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: containerWidth / 2,
                height: containerHeight / 6,
                decoration: BoxDecoration(
                  color: Color(0x2202A6D8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      expiryDate,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFFFFF),
                        height: 7.2 / 6.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: containerHeight * 0.2,
              left: screenWidth * 0.02,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                width: containerWidth * 0.9,
                child: Text(
                  offername,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lato(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                    height: 16.8 / 14.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: containerHeight * 0.45,
              left: screenWidth * 0.02,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                width: containerWidth * 0.6,
                child: Text(
                  description,
                  maxLines: 3, // Limit to 3 lines
                  overflow: TextOverflow.ellipsis, // Show "..." if it overflows
                  style: GoogleFonts.lato(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                    height: 16.8 / 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Dotted Line
class DottedLinePainter extends CustomPainter {
  final double lineLength;
  final double lineWidth;
  final double spacing;

  DottedLinePainter({
    required this.lineLength,
    required this.lineWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    while (startY < lineLength) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + spacing),
        paint,
      );
      startY += spacing * 2; // twice the spacing for gaps
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
