import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Booking%20Details/bookingdetailspending.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/CancelledPage.dart';
import 'package:ms_salon_task/Raise_Ticket/ticket_details.dart';
import 'package:ms_salon_task/Splashscreen/splashscreen.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/main.dart';
import 'package:ms_salon_task/offers%20and%20membership/offers.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart'; // Import Cupertino package

// Model to represent a notification
class NotificationModel {
  final String title;
  final String content;
  final String dateTime;
  final String landingPage;
  final String redirectId;

  NotificationModel({
    required this.title,
    required this.content,
    required this.dateTime,
    required this.landingPage,
    required this.redirectId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      content: json['content'],
      dateTime: json['date_time'],
      landingPage: json['redirection_data']['landing_page'],
      redirectId: json['redirection_data']['redirect_id'],
    );
  }
}

// Widget to display a single notification item
// Widget to display a single notification item// Widget to display a single notification item
class NotificationItem extends StatelessWidget {
  final String message;
  final String timeAgo;
  final Function() onTap;

  NotificationItem({
    required this.message,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    double horizontalPadding = screenWidth * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            vertical: 8, horizontal: 16), // Margin around the card
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12), // Added vertical padding
        decoration: BoxDecoration(
          color: Colors.white, // Card background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
          border: Border.all(
              color: Color(0xFFD9D9D9), width: 0.8), // Border color and width
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adjust height according to content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHtmlContent(message),
            SizedBox(height: 4), // Add space between message and timeAgo
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeAgo,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.023,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Color(0xFFC4C4C4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This method processes the message, makes the links clickable, and converts <br> to line breaks
  Widget _buildHtmlContent(String message) {
    // Convert <br> tags to newline characters
    String textContent = message.replaceAll(RegExp(r'<br\s*/?>'), '\n');

    // Use a regular expression to find URLs
    final regex = RegExp(r'(https?://[^\s]+)');
    final matches = regex.allMatches(textContent);

    if (matches.isEmpty) {
      return Text(
        textContent,
        style: TextStyle(
          fontSize: 16, // Adjust font size as needed
          fontWeight: FontWeight.w400,
          color: Color(0xFF424752),
        ),
      );
    }

    List<InlineSpan> children = [];
    int lastMatchEnd = 0;

    // Process the message, adding clickable links
    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final url = match.group(0);

      // Add the text before the link
      if (start > lastMatchEnd) {
        children.add(TextSpan(
          text: textContent.substring(lastMatchEnd, start),
          style: TextStyle(
            fontSize: 16, // Adjust font size as needed
            fontWeight: FontWeight.w400,
            color: Color(0xFF424752),
          ),
        ));
      }

      // Add the clickable link
      if (url != null) {
        children.add(TextSpan(
          text: url,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 16, // Adjust font size as needed
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ));
      }

      lastMatchEnd = end;
    }

    // Add any remaining text after the last match
    if (lastMatchEnd < textContent.length) {
      children.add(TextSpan(
        text: textContent.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: 16, // Adjust font size as needed
          fontWeight: FontWeight.w400,
          color: Color(0xFF424752),
        ),
      ));
    }

    return RichText(text: TextSpan(children: children));
  }

  // This method opens the URL when a link is clicked
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }
}

// Notification page that displays a list of notifications
class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final prefs = await SharedPreferences.getInstance();
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');

    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    final requestBody = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
    });

    final String apiUrl = '${Config.apiUrl}customer/notifications/';

    print('Request URL: $apiUrl');
    print('Request Body: $requestBody');
    final errorLogger = ErrorLogger(); // Initialize the error logger    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "true") {
          final List<dynamic> notificationsData = data['data'];
          setState(() {
            _notifications = notificationsData
                .map((notification) => NotificationModel.fromJson(notification))
                .toList();
          });
        }
      } else {
        print(
            'Failed to load notifications. Status code: ${response.statusCode}');
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
        errorLocation: "Function -> fetchNotifications",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error in fetchNotifications: $e');
      print('Stack Trace: $stackTrace');

      // Optionally, rethrow the exception or return an empty list
      throw Exception('Error during fetchNotifications API call: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Method to handle navigation based on the notification data
  void _handleNotificationTap(NotificationModel notification) async {
    try {
      final String landingPage = notification.landingPage.toLowerCase();
      final String redirectId = notification.redirectId;

      switch (landingPage) {
        case 'offers_list':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Offers()),
          );
          break;
        case 'cancelled_list':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CancelledPage()),
          );
          break;
        case 'booking_details':
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_booking_id', redirectId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BookingDetailsPendingPage()),
          );
          break;
        case 'query_details':
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_ticket_id', redirectId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TicketDetails()),
          );
          break;
        default:
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => HomePage(
          //             title: '',
          //           )),
          // );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NotificationPage()),
          );
          break;
      }
    } catch (e) {
      print('Error handling notification click: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Notifications',
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? ListView.builder(
                itemCount: 10, // Display placeholder for loading
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              )
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return NotificationItem(
                    message: notification.content,
                    timeAgo:
                        notification.dateTime, // Assuming this is formatted
                    onTap: () => _handleNotificationTap(notification),
                  );
                },
              ),
      ),
    );
  }
}
