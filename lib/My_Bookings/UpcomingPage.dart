import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Booking%20Details/bookdetailspending2.dart';
import 'package:ms_salon_task/Booking%20Details/bookingdetailspending.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Models/booking_model.dart'; // Make sure this import is correct
import 'package:ms_salon_task/My_Bookings/cancel_appointment_dialog.dart';
import 'package:ms_salon_task/My_Bookings/mybooking_details.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_calender.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ms_salon_task/My_Bookings/CancelledPage.dart';
import 'package:ms_salon_task/My_Bookings/CompletedPage.dart';
import 'package:ms_salon_task/My_Bookings/bottom_nav_bar.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_services.dart';
import 'package:shimmer/shimmer.dart';

class UpcomingPage extends StatefulWidget {
  @override
  _UpcomingPageState createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  bool _isLoading = true;
  bool _hasMoreData = true; // Track if there are more items to load
  int _offset = 0; // Track the current offset
  String? _errorMessage;
  List<Booking> _bookings = [];
  bool _isSwitchOn = false;
  late ScrollController _scrollController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMoreData && !_isLoading) {
          _fetchBookings();
        }
      }
    });
    _fetchBookings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _setReminder(Booking booking, bool isReminderSet) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String salonID = prefs.getString('salon_id') ?? '';
    final String branchID = prefs.getString('branch_id') ?? '';
    final String customerId = prefs.getString('customer_id') ?? '';

    final Map<String, dynamic> requestBody = {
      'salon_id': salonID,
      'branch_id': branchID,
      'booking_id': booking.bookingId,
      'customer_id': customerId,
      'is_reminder_set': isReminderSet ? '1' : '0',
    };

    // Print the request body to debug
    print('Request body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/set-booking-reminder/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Print the response body for debugging
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final bool success = jsonResponse['success'] ?? false;
        if (success) {
          print(
              'Reminder set successfully for Booking ID: ${booking.bookingId}');
          // Handle successful response if needed
        } else {
          // Show error dialog if setting reminder fails and refresh on OK
          _showErrorDialog(
            context,
            'Failed to set reminder. Please try again.',
            onDismiss: () => _refresh(), // Refresh the page on OK
          );
        }
      } else {
        // Show error dialog if HTTP request fails and refresh on OK
        _showErrorDialog(
          context,
          'Failed to set reminder. Please try again.',
          onDismiss: () => _refresh(), // Refresh the page on OK
        );
      }
    } catch (e) {
      // Show error dialog for network errors or exceptions and refresh on OK
      _showErrorDialog(
        context,
        'An error occurred: $e',
        onDismiss: () => _refresh(), // Refresh the page on OK
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message,
      {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reminder Error'),
          content: Text('You can not send reminder for past date booking'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDismiss != null) {
                  onDismiss(); // Call the callback function
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? customerId1 = prefs.getString('customer_id');
      final String? customerId2 = prefs.getString('customer_id2');
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      final String customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      final requestBody = jsonEncode({
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerId,
        'limit': '10',
        'offset': _offset.toString(),
      });

      // Print the request body for debugging
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/pending-bookings/'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
      print('requestBody of upco $requestBody');
      // Print the response status code and headers for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      log('Response Body of updoming : ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        if (data.isEmpty) {
          _hasMoreData = false;
        } else {
          List<Booking> bookings =
              data.map((item) => Booking.fromJson(item)).toList();
          setState(() {
            _offset += 10; // Increment offset for next fetch
            _bookings.addAll(bookings);
          });
        }
      } else {
        // Print the error message if response is not OK
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage =
            errorResponse['error_message'] ?? 'Failed to load bookings';
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
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
      // Log the error details with Crashlytics or your custom logger
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> _fetchBookings",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error in _fetchBookings: $e');
      print('Stack Trace: $stackTrace');
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
      // Optionally, rethrow the exception or return an empty list
      throw Exception('Error during _fetchBookings API call: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _offset = 0;
      _hasMoreData = true;
      _bookings.clear();
    });
    await _fetchBookings();
  }

  Future<void> _cancelpage() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CancelledPage(),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(
                title: '',
              )),
    );
    return false; // Prevent default pop behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
              Navigator.pushNamed(context, '/home');
            },
          ),
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: _isLoading && _bookings.isEmpty
              ? _buildShimmerLoading()
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : Column(
                      children: [
                        _buildTabBar(context),
                        Expanded(child: _buildUpcomingContent(context)),
                      ],
                    ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // Number of skeleton items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey,
                  height: 20.0,
                  width: 100.0,
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.grey,
                  height: 20.0,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.grey,
                  height: 20.0,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(36, 20, 36, 11),
      color: CustomColors.backgroundPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, 0, 'Upcoming', true),
          _buildTabItem(context, 1, 'Completed', false),
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

  // Widget _buildUpcomingContent(BuildContext context) {
  //   if (_isLoading && _bookings.isEmpty) {
  //     // Display shimmer or loading indicator while data is loading
  //     return Center(child: CircularProgressIndicator());
  //   }

  //   if (!_isLoading && _bookings.isEmpty) {
  //     // Display a message when there are no bookings and loading is complete
  //     return Center(
  //         child: Text('No Data Available',
  //             style: TextStyle(fontSize: 16, color: Colors.black54)));
  //   }

  //   // Display the list of bookings
  //   return ListView.builder(
  //     controller: _scrollController,
  //     itemCount: _bookings.length +
  //         (_hasMoreData ? 1 : 0), // Add an extra item for the loader
  //     itemBuilder: (context, index) {
  //       if (index >= _bookings.length) {
  //         return Center(
  //             child: CircularProgressIndicator()); // Show loader at the end
  //       }
  //       final booking = _bookings[index];
  //       return GestureDetector(
  //         onTap: () async {
  //           final prefs = await SharedPreferences.getInstance();
  //           await prefs.setString('selected_booking_id', booking.bookingId);
  //           print(booking.bookingId);
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => BookingDetailsPendingPage(),
  //             ),
  //           );
  //           // Navigator.push(
  //           //   context,
  //           //   MaterialPageRoute(
  //           //     builder: (context) => BookingDetailsPage2(),
  //           //   ),
  //           // );
  //         },
  //         child: _buildBookingCard(booking),
  //       );
  //     },
  //   );
  // }
  Widget _buildUpcomingContent(BuildContext context) {
    if (_isLoading && _bookings.isEmpty) {
      // Display shimmer or loading indicator while data is loading
      return Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _bookings.isEmpty) {
      // Display a message when there are no bookings and loading is complete
      return Center(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.0,
            left: MediaQuery.of(context).size.width * 0.02,
          ),
          child: Image.asset(
            'assets/nodata2.png', // Replace with your image path
            height: MediaQuery.of(context).size.height *
                0.6, // 70% of screen height
            width:
                MediaQuery.of(context).size.width * 0.6, // 70% of screen width
          ),
        ),
      );
    }

    // Determine if we should show the loader
    bool showLoader = _hasMoreData && _bookings.length > 10;

    // Display the list of bookings
    return ListView.builder(
      controller: _scrollController,
      itemCount: _bookings.length +
          (showLoader
              ? 1
              : 0), // Add an extra item for the loader only if needed
      itemBuilder: (context, index) {
        if (index >= _bookings.length) {
          return Center(
              child:
                  CircularProgressIndicator()); // Show loader at the end if applicable
        }
        final booking = _bookings[index];
        return GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('selected_booking_id', booking.bookingId);
            print(booking.bookingId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsPendingPage(),
              ),
            );
          },
          child: _buildBookingCard(booking),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      child: Card(
        elevation: 0, // Set elevation to 0 to remove shadow
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8), // Optional: Set a border radius
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Remind Me Row with grey line
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // 'Date & Time: ${booking.formattedBookingDate}, ${booking.servicesFrom}',
                            'Booking ID: ${booking.refId}',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.035, // Adjust font size based on screen width
                                fontWeight: FontWeight.w600,
                                height: 14.4 / 12,
                                letterSpacing: 0.02,
                                color: Color(0xFF1D2024),
                              ),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       'Remind me',
                          //       style: GoogleFonts.lato(
                          //         textStyle: TextStyle(
                          //           fontSize: MediaQuery.of(context)
                          //                   .size
                          //                   .width *
                          //               0.035, // Adjust font size based on screen width
                          //           fontWeight: FontWeight.w400,
                          //           color: Color(0xFF1D2024),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     Transform.scale(
                          //       scale: 0.7,
                          //       child: Switch(
                          //         value: booking.isReminderSet,
                          //         onChanged: (value) {
                          //           setState(() {
                          //             booking.isReminderSet = value;
                          //           });
                          //           _setReminder(booking, value);
                          //         },
                          //         activeColor: CustomColors.backgroundtext,
                          //         activeTrackColor:
                          //             Colors.blue.withOpacity(0.5),
                          //         inactiveThumbColor: Colors.grey,
                          //         inactiveTrackColor:
                          //             Colors.grey.withOpacity(0.5),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(
                          height: 10), // Adjust margin based on screen height,
                      Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.01), // Adjust margin based on screen height
                    ],
                  ),

                  // _buildOrderIdRow(booking.refId),

                  _buildBookingDetailRow('Date & Time',
                      '${booking.formattedBookingDate}, ${booking.servicesFrom}'),
                  _buildBookingDetailRow('Services', booking.servicesText),
                  _buildBookingDetailRow('Stylist', booking.stylistsText),

                  _buildBookingDetailRow(
                    'Price',
                    '\₹${booking.totalPrice.toStringAsFixed(2)}',
                  ),

                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                                'selected_booking_id2', booking.bookingId);
                            print(booking.bookingId);
                            _showCancelOverlay(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFE13B3B),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel Appointment',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final bookingJson = jsonEncode(booking.toJson());
                            await prefs.setString(
                                'selected_booking_json', bookingJson);
                            print('Booking JSON stored: $bookingJson');
                            print('Booking JSON stored: ');
                            await prefs.setString(
                                'selected_booking_id', booking.bookingId);
                            print('Booking ID stored: ${booking.bookingId}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RescheduleCalender(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                'Reschedule',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRescheduleClicked(Booking booking) {
    if (booking.services.isNotEmpty) {
      for (var service in booking.services) {
        print('Service ID: ${service.serviceId}');
      }
    } else {
      print('No services available.');
    }
  }

  Widget _buildOrderIdRow(String value) {
    TextStyle orderIdTextStyle = GoogleFonts.lato(
      textStyle: const TextStyle(
        fontSize: 15, // Font-size: 16px
        fontWeight: FontWeight.w600, // Font-weight: 700 (bold)
        height: 19.2 / 16, // Line-height: 19.2px (16px * 1.2)
        letterSpacing: 0.02, // Letter-spacing: 0.02em
        color: Color(0xFF424752), // Color: #424752
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Booking ID :',
              style: orderIdTextStyle, // Same style for label
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: orderIdTextStyle, // Same style for value
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value,
      {TextStyle? labelStyle, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: labelStyle ??
                  GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400, // Normal weight for label
                      fontSize: 15, // Font size for label
                      height: 1.2, // Line-height adjustment
                      letterSpacing: 0.02, // Letter-spacing for label
                      color: const Color(0xFF424752), // Label color
                    ),
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ??
                  GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 14, // Font size for value
                      fontWeight: FontWeight.w500, // Medium weight for value
                      height: 14.4 /
                          12, // Corresponds to line-height of 14.4px with font size of 12px
                      letterSpacing: 0.02, // Corresponds to 0.02em
                      color: Color(0xFF1D2024), // Set text color to #1D2024
                    ),
                  ),
              textAlign: TextAlign.left, // Align text to the left
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CancelAppointmentDialog(
          onCancel: () {
            // Handle cancel logic if needed
            _refresh(); // Refresh the page when 'No' is tapped
          },
          onConfirm: () {
            // Handle cancellation logic here
            // For example, you can call a method to cancel the booking
            // _cancelBooking(); // You need to implement _cancelBooking
            // _refresh(); // Refresh the page when 'Yes' is tapped
            _cancelpage();
          },
        );
      },
    );
  }
}
