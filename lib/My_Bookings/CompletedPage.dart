import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Models/booking_model.dart';
import 'package:ms_salon_task/My_Bookings/CancelledPage.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/My_Bookings/bottom_nav_bar.dart';
import 'package:ms_salon_task/My_Bookings/mybooking_details.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'review_dialog.dart'; // Import the review dialog

class CompletedPage extends StatefulWidget {
  @override
  _CompletedPageState createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  List<Booking> _bookingList = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isRefreshing = false;
  int _offset = 0;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    fetchBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      if (!_isRefreshing) {
        _refresh(); // Trigger a refresh when the page becomes visible
      }
    }
  }

  Future<void> _fetchBookings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Booking> newBookings = await fetchBookings();
      setState(() {
        _offset += _limit;
        _isLoading = false;
        if (_isRefreshing) {
          _bookingList = newBookings;
          _isRefreshing = false;
        } else {
          _bookingList.addAll(newBookings);
        }
        if (newBookings.isEmpty) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      // Handle the error (e.g., show a message to the user)
    }
  }

  Future<List<Booking>> fetchBookings() async {
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

    // Prepare the request body
    final requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
      'limit': '$_limit',
      'offset': '$_offset',
    };

    // Print the request body
    print('Request Body: ${jsonEncode(requestBody)}');

    // Make the API request
    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/completed-bookings/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Print the response status and body
    print('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    // Check if the response was successful
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'true') {
        final List<dynamic> bookingsJson = data['data'];
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
      _offset = 0;
      _hasMoreData = true;
    });
    await _fetchBookings();
  }

  void _onReviewSubmitted() {
    _refresh(); // Refresh the page data when review is submitted
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: CustomColors.backgroundLight,
        title: Text(
          'My Bookings',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 20, // You can adjust the font size as needed
              fontWeight: FontWeight.w600, // Adjust font weight if necessary
              color: Colors.black, // Change color if needed
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    if (_hasMoreData) {
                      _fetchBookings();
                    }
                  }
                  return false;
                },
                child: _bookingList.isEmpty && !_isLoading
                    ? _buildNoDataMessage()
                    : ListView.builder(
                        itemCount: _bookingList.length + (_isLoading ? 5 : 0),
                        itemBuilder: (context, index) {
                          if (index < _bookingList.length) {
                            final booking = _bookingList[index];
                            return _buildBookingCard(
                              booking.bookingId,
                              booking.refId,
                              booking.bookingDate,
                              booking.customer,
                              booking.phoneNo,
                              booking.servicesText,
                              booking.stylistsText,
                              booking.isReviewSubmitted,
                              booking.servicesFrom,
                            );
                          } else if (_isLoading) {
                            return _buildLoadingSkeleton();
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your image widget
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.0,
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              child: Image.asset(
                'assets/nodata2.png', // Replace with your image path
                height: MediaQuery.of(context).size.height *
                    0.6, // 70% of screen height
                width: MediaQuery.of(context).size.width *
                    0.6, // 70% of screen width
              ),
            ),
            // Optional: Additional message below the image
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(36, 20, 36, 11),
      color: CustomColors.backgroundPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, 0, 'Upcoming', false),
          _buildTabItem(context, 1, 'Completed', true),
          _buildTabItem(context, 2, 'Cancelled', false),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      BuildContext context, int index, String text, bool isSelected) {
    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UpcomingPage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CompletedPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CancelledPage()),
            );
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? CustomColors
                          .backgroundtext // Blue color for selected tab
                      : Colors.black,
                ),
              ),
            ),
            if (isSelected) // Add underline only for the selected tab
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 70,
                color: CustomColors.backgroundtext,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    String bookingId,
    String refId,
    String bookingDate,
    String customerName,
    String phoneNumber,
    String services,
    String stylist,
    bool isReviewSubmitted,
    String serviceFrom,
  ) {
    String _formatBookingDate(String date) {
      try {
        DateTime parsedDate = DateFormat("dd MMM, yyyy").parse(date);
        return DateFormat("dd MMM yy").format(parsedDate); // e.g. 11 Nov 24
      } catch (e) {
        return date; // Return original date if parsing fails
      }
    }

    // Format the booking date
    final formattedBookingDate = _formatBookingDate(bookingDate);

    String _formatSpecialistText(String text, int maxWords) {
      final words = text.split(' ');
      final formattedText = StringBuffer();
      for (var i = 0; i < words.length; i++) {
        if (i > 0 && i % maxWords == 0) {
          formattedText.write('\n');
        }
        formattedText.write(words[i]);
        if (i < words.length - 1) {
          formattedText.write(' ');
        }
      }
      return formattedText.toString();
    }

    final formattedStylist = _formatSpecialistText(stylist, 2);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_booking_id', bookingId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsPage(),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.only(bottom: 16.0, top: 10),
          color: Colors.white,
          elevation: 0, // Set elevation to 0 to remove shadow
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8.0), // Optional: Customize border radius
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Booking ID: ${refId}',
                                  // 'Date & Time: $formattedBookingDate, $serviceFrom',
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      fontSize:
                                          14, // Equivalent to font-size: 12px;
                                      fontWeight: FontWeight
                                          .w600, // Equivalent to font-weight: 500;
                                      height:
                                          1.2, // Equivalent to line-height: 14.4px (12px * 1.2)
                                      letterSpacing:
                                          0.02, // Equivalent to letter-spacing: 0.02em;
                                      color: Color(
                                          0xFF1D2024), // Equivalent to #1D2024;
                                      textBaseline: TextBaseline.alphabetic,
                                    ),
                                  ),
                                  textAlign: TextAlign
                                      .left, // Equivalent to text-align: left;
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Remind me',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF1D2024),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        _buildInfoRow('Date & Time',
                            '${formattedBookingDate}, ${serviceFrom}'),
                        SizedBox(height: 8),
                        _buildInfoRow('Services:', services),
                        SizedBox(height: 8),
                        _buildInfoRow('Stylists:', formattedStylist),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Completed',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Visibility(
                      visible: !isReviewSubmitted,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'selected_booking_id', bookingId);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => ReviewDialog(
                              onReviewSubmitted:
                                  _onReviewSubmitted, // Pass the callback
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: CustomColors.backgroundtext,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 2.0,
                            horizontal: 10.0,
                          ),
                          minimumSize: Size(100, 40),
                        ),
                        child: Text(
                          'Add Review',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Container(
              //   height: 1.0,
              //   color: Colors.grey[300], // Adjust the color as needed
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool hasDivider = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontWeight: label == 'Booking ID'
                        ? FontWeight.w700 // Bold for 'Order ID'
                        : FontWeight.w400, // Normal for other labels
                    fontSize: 15, // Font size 15px for label
                    height: 1.2, // Adjust line height as needed
                    letterSpacing: 0.02,
                    color: const Color(0xFF424752), // Color: #424752 for label
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: label == 'Booking ID'
                    ? GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 15, // Font size 15px for 'Order ID' value
                          fontWeight: FontWeight.w600, // Font-weight: 500
                          height: 1.2, // Adjust line height as needed
                          letterSpacing: 0.02,
                          color: Color(0xFF1D2024), // Color: #424752
                        ),
                      )
                    : GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14, // Font size 12px for other values
                          fontWeight: FontWeight.w500, // Font-weight: 500
                          height: 14.4 / 12, // Line-height: 14.4px
                          letterSpacing: 0.02, // Letter-spacing: 0.02em
                          color: Color(0xFF1D2024), // Color: #1D2024
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (hasDivider)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            height: 1.0,
            color: Colors.grey[300], // Divider color
          ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20.0,
                    color: Colors.grey,
                    width: 120.0,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 16.0,
                    color: Colors.grey,
                    width: double.infinity,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 16.0,
                    color: Colors.grey,
                    width: 150.0,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 16.0,
                    color: Colors.grey,
                    width: 100.0,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 16.0,
                    color: Colors.grey,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
