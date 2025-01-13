import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/payment.dart';
import 'package:ms_salon_task/Saloon_Details_page/saloon_details_page.dart';
import 'package:ms_salon_task/Sidebar/reminder.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages1.dart';
import 'package:ms_salon_task/offers%20and%20membership/giftcard_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
// Assuming you have these pages defined somewhere
import 'package:ms_salon_task/Profile/about.dart';
import 'package:ms_salon_task/Profile/privacy.dart';
import 'package:ms_salon_task/Profile/profile.dart';
import 'package:ms_salon_task/Raise_Ticket/all_visits.dart';
import 'package:ms_salon_task/Raise_Ticket/your_tickets.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages.dart';
import 'package:ms_salon_task/offers%20and%20membership/membership.dart';
import 'package:ms_salon_task/offers%20and%20membership/offers.dart';
import 'package:ms_salon_task/terms&condi/terms_conditions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({Key? key}) : super(key: key);

  @override
  _SidebarDrawerState createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  String _storeName = 'Default Store Name';
  String _storeAddress = 'Default Store Address';
  String _storeNumber = 'Loading...';
  String _branchName = '';
  String _storeLogo = '';
  @override
  void initState() {
    super.initState();
    _loadStoreName();
    // _loadStoreNumber();
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
          // Debugging before setting state
          print(
              "Branch Name from response: ${responseData['data']['branch_name']}");
          print(
              "Store Logo from response: ${responseData['data']['store_logo']}");
          print(
              "Store Address from response: ${responseData['data']['address']}");

          setState(() {
            _branchName = responseData['data']['branch_name'] ?? '';
            _storeLogo = responseData['data']['store_logo'] ?? '';
            _storeNumber = responseData['data']['phone_number'] ?? '';
            _storeAddress =
                responseData['data']['address'] ?? 'Default Store Address';
          });
          print("Branch Name after setState: $_branchName");
          print("Store Logo after setState: $_storeLogo");
          print("Store Address after setState: $_storeAddress");
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

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('store_name') ?? 'Apple Saloon';
    final storedAddress =
        prefs.getString('store_address') ?? 'Address Not Available';
    setState(() {
      _storeName = storedName;
      _storeAddress = storedAddress;
    });
  }

  // Future<void> _loadStoreNumber() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // If you're storing branch_mobile as an integer, use getInt instead
  //   final storeNumber =
  //       prefs.getString('branch_mobile') ?? 'Default Store Name';

  //   // Print the retrieved store number
  //   print('Retrieved Store Number: $storeNumber');

  //   setState(() {
  //     _storeNumber = storeNumber;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchStoreProfile, // Method to refresh the data
      child: Drawer(
        child: Column(
          children: [
            Container(
              color: CustomColors.backgroundtext,
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Center the column content vertically
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Center the column content horizontally
                children: [
                  CircleAvatar(
                    radius: 30, // Adjust the radius as needed
                    backgroundImage: _storeLogo.isNotEmpty
                        ? NetworkImage(_storeLogo) // Use NetworkImage for URL
                        : const AssetImage('assets/applelogo.png')
                            as ImageProvider, // Fallback to default logo
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                      height: 15), // Space between logo and store name
                  Text(
                    _storeName,
                    style: GoogleFonts.lato(
                      // Use Google Fonts Lato
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _storeAddress, // Use dynamic address
                    textAlign: TextAlign.center, // Center align the text
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    iconPath: 'assets/application.svg',
                    text: 'About us',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SaloonDetails()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/crown.svg',
                    text: 'Membership',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Membership()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/crown.svg',
                    text: 'Packages',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerPackages1()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/giftcard.svg',
                    text: 'Giftcards',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GiftcardList()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/offer1.svg',
                    text: 'Offers & Deals',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Offers()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/clock2.svg',
                    text: 'Appointment Reminder',
                    onTap: () => _showReminderDialog(context),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/card3.svg',
                    text: 'Payment',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentPage()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/privacy2.svg',
                    text: 'Privacy Policy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/terms.svg',
                    text: 'Terms Condition',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsConditions()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/help3.svg',
                    text: 'Raise a Complaint',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllTicket()),
                    ),
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/user2.svg',
                    text: 'Profile',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    ),
                  ),
                  SizedBox(height: 70),
                ].map((item) {
                  return Container(
                    color: CustomColors
                        .backgroundLight, // Set background color to white
                    child: item,
                  );
                }).toList(),
              ),
            ),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16.0), // Add some padding for spacing
              decoration: BoxDecoration(
                color: CustomColors.backgroundLight
                    .withOpacity(0.8), // Set the background color with opacity
                border: Border(
                  top: BorderSide(
                    color: CustomColors.backgroundtext.withOpacity(
                        0.8), // Set the top border color with opacity
                    width: 1.0, // Set the border width
                  ),
                ),
                // borderRadius: BorderRadius.vertical(
                //     top: Radius.circular(8.0)), // Optional: rounded top corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SaloonDetails()),
                      );
                    },
                    child: Text(
                      'Contact Us',
                      style: GoogleFonts.lato(
                        fontSize: MediaQuery.of(context).size.width *
                            0.05, // Adjusting font size based on screen width
                        fontWeight: FontWeight.bold,
                        color: CustomColors.backgroundtext,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02), // Adjusting space based on screen height
                  Text(
                    'Mobile No:', // Label for the mobile number
                    style: GoogleFonts.lato(
                      fontSize: MediaQuery.of(context).size.width *
                          0.04, // Adjusting font size based on screen width
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.01), // Adjusting space based on screen height
                  GestureDetector(
                    onTap: () {
                      // Only attempt to launch the phone number if it's not empty
                      if (_storeNumber.isNotEmpty &&
                          _storeNumber != 'Not Available') {
                        _launchPhoneNumber(_storeNumber);
                      }
                    },
                    child: Text(
                      _storeNumber.isNotEmpty ? _storeNumber : 'Not Available',
                      style: GoogleFonts.lato(
                        fontSize: MediaQuery.of(context).size.width *
                            0.04, // Adjusting font size based on screen width
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        decoration: _storeNumber.isNotEmpty
                            ? TextDecoration.underline
                            : TextDecoration
                                .none, // Underline the number if available
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02), // Add some space before the footer text
                  Text(
                    'Powered by Schedule Savvy Solution Pvt. Ltd.',
                    style: GoogleFonts.lato(
                      fontSize: MediaQuery.of(context).size.width *
                          0.03, // Adjusting font size for footer
                      fontWeight: FontWeight.w400,
                      color:
                          Colors.black54, // Lighter color for minimal display
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReminderDialog();
      },
    );
  }

  void _launchPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      // Handle if the URL cannot be launched (for example, if the device doesn't support calling)
      print('Could not launch $phoneNumber');
    }
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate icon size based on screen width
    final double iconSize = screenWidth * 0.06;
    final double textSize = screenWidth * 0.04;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05, // Responsive horizontal padding
      ),
      leading: SvgPicture.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
        color: const Color(0xFF424752),
      ),
      title: Text(
        text,
        overflow: TextOverflow.ellipsis, // Handle text overflow
        style: GoogleFonts.lato(
          // Use Google Fonts Lato
          fontSize: textSize,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF424752),
          letterSpacing: 0.02,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: iconSize * 0.7, // Scale icon size based on screen size
        color: const Color(0xFF424752),
      ),
    );
  }
}
