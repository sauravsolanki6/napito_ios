import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Booking%20Details/booking_details_cancelled.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Models/booking_model.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/My_Bookings/mybooking_details.dart';
import 'package:ms_salon_task/main.dart';
import 'CompletedPage.dart';
import 'bottom_nav_bar.dart'; // Import the common bottom navigation bar
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class CancelledPage extends StatefulWidget {
  @override
  _CancelledPageState createState() => _CancelledPageState();
}

class _CancelledPageState extends State<CancelledPage> {
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

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/canceled-bookings/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'limit': '$_limit',
        'offset': '$_offset',
      }),
    );

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
          _buildTabItem(context, 1, 'Completed', false),
          _buildTabItem(
              context, 2, 'Cancelled', true), // Blue underline for Cancelled
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      child: GestureDetector(
        onTap: () async {
          // Save the booking ID to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_booking_id', bookingId);

          // Print the booking ID (for debugging purposes)
          print('Booking ID saved: $bookingId');

          // Navigate to BookingDetailsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsCancelledPage(),
            ),
          );
        },
        child: Material(
          color: Colors.transparent, // Set the material color to transparent
          child: Card(
            margin: EdgeInsets.only(bottom: 16.0),
            elevation: 0, // Remove elevation
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      // Order ID with underline
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking ID: ${refId}',
                            // 'Date & Time: $formattedBookingDate, $serviceFrom',
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 14, // Font size remains 14
                                fontWeight:
                                    FontWeight.w600, // Font weight set to 500
                                height: 1.2, // Line height
                                letterSpacing: 0.02, // Letter spacing
                                color: Color(
                                    0xFF1D2024), // Text color set to #1D2024
                              ),
                            ),
                            textAlign: TextAlign.left, // Align text to the left
                          ),

                          SizedBox(height: 4), // Space between text and line
                          Container(
                            height: 1.0, // Line thickness
                            color: const Color.fromARGB(255, 210, 210, 210),
                            width: double.infinity, // Extends to full width
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // When calling _buildInfoRow, apply the specific style for Order ID
                      // _buildInfoRow(
                      //   'Booking ID ',
                      //   refId,
                      //   labelStyle: GoogleFonts.lato(
                      //     textStyle: TextStyle(
                      //       fontSize: 15,
                      //       fontWeight: FontWeight.w700,
                      //       letterSpacing: 0.02,
                      //       color: Color(
                      //           0xFF424752), // Assuming #424752 is the color you want to use
                      //     ),
                      //   ),
                      //   valueStyle: GoogleFonts.lato(
                      //     textStyle: TextStyle(
                      //       fontSize: 15,
                      //       fontWeight:
                      //           FontWeight.w700, // Weight 700 for Order ID
                      //     ),
                      //   ),
                      // ),
                      _buildInfoRow('Date & Time',
                          '${formattedBookingDate}, ${serviceFrom}'),
// Call without special style for other labels
                      _buildInfoRow('Services', services),
                      _buildInfoRow('Specialist', stylist),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Cancelled',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {TextStyle? labelStyle, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: labelStyle ??
                  GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w500, // Default weight for other values
                    ),
                  ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
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
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
