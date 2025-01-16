import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/payment.dart';
import 'package:ms_salon_task/Payment/payment2.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';
import 'package:ms_salon_task/SignUp/SignUpPage.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isOverlayVisible = false; // Track if overlay is visible
  String customerID = '';
  String branchID = '';
  String salonID = '';
  String fullName = '';
  String dateOfBirth = '';
  String dateOfAnniversary = '';
  String gender = '';
  String profilePicUrl = '';
  String mobileNumber = '';
  bool isMember = false;
  String customerId = '';
  String membershipName = '';
  String membershipReceipt = '';
  @override
  void initState() {
    super.initState();
    fetchDataFromPreferences();
  }

  Future<void> fetchDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerID = prefs.getString('customer_id') ?? '';
      branchID = prefs.getString('branch_id') ?? '';
      salonID = prefs.getString('salon_id') ?? '';
      mobileNumber = prefs.getString('mobileNumber') ?? '';
    });

    print('Branch ID: $branchID');
    print('Salon ID: $salonID');
    print('Customer ID: $customerID');
    print('Mobile Number: $mobileNumber');

    // Check if there's another customer ID
    String customerID2 = prefs.getString('customer_id2') ?? '';
    String customerId = customerID2.isNotEmpty && customerID2 != customerID
        ? customerID2
        : customerID;

    if (customerId.isNotEmpty) {
      // Fetch profile details
      fetchProfileDetails(customerId);

      // Fetch membership details
      fetchMembershipDetails(customerId);
    } else {
      print('Customer ID is empty.');
    }
  }

  Future<void> fetchProfileDetails(String customerId) async {
    // Retrieve customer ID, branch ID, and salon ID
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');

    customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    branchID = prefs.getString('branch_id') ?? '';
    salonID = prefs.getString('salon_id') ?? '';

    if (customerId.isEmpty || branchID.isEmpty || salonID.isEmpty) {
      print('Missing required parameters');
      return;
    }

    String url = '${MyApp.apiUrl}customer/profile-details/';
    Map<String, String> requestBody = {
      "customer_id": customerId,
      "branch_id": branchID,
      "salon_id": salonID,
    };
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data'].isNotEmpty) {
          var profileData = responseData['data'][0];
          setState(() {
            fullName = profileData['full_name']?.toString() ?? '';
            dateOfBirth = profileData['date_of_birth']?.toString() ?? '';
            dateOfAnniversary =
                profileData['date_of_anniversary']?.toString() ?? '';
            gender = profileData['gender']?.toString() ?? '';
            profilePicUrl = profileData['profile_pic']?.toString() ?? '';
          });
          print('Profile Details Response: $responseData');
        } else {
          print('No profile data available');
        }
      } else {
        print(
            'Failed to load profile details with status code: ${response.statusCode}');
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
        errorLocation: "Function -> fetchProfileDetails",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error in fetchProfileDetails: $e');
      print('Stack Trace: $stackTrace');

      // Optionally, rethrow the exception or return an empty list
      throw Exception('Error during fetchProfileDetails API call: $e');
    }
  }

  Future<void> logOutUserFromDevice() async {
    final String url = "${MyApp.apiUrl}set_user_logout";

    // Retrieve stored values from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    String? userId = prefs.getString('user_id');
    String? appPanelUserId = prefs.getString('app_panel_user_id');

    // Check if required values are available
    // if (deviceId == null || userId == null || appPanelUserId == null) {
    //   print('Error: One or more required values are missing');
    //   return;
    // }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "app_panel_user_id": appPanelUserId,
      "project": "salon", // Static project name
      "device_id": deviceId,
    };

    // Print the request body for debugging
    print("Request Body for logout: ${jsonEncode(requestBody)}");

    // Send the HTTP POST request to the API
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Print the response body for debugging
      print("Response Body of logout: ${response.body}");

      if (response.statusCode == 200) {
        // Handle success response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          print(
              "Successfully logged out from device: ${responseBody['message']}");
        } else {
          print("Failed to log out: ${responseBody['message']}");
        }
      } else {
        // Handle non-200 response
        print("Failed to log out: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      print("Error: $e");
    }
  }

  Future<void> fetchMembershipDetails(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('branch_id') ?? '';
    final salonId = prefs.getString('salon_id') ?? '';

    if (customerId.isEmpty || branchId.isEmpty || salonId.isEmpty) {
      print('Missing required parameters.');
      return;
    }

    String url = '${MyApp.apiUrl}customer/membership/';
    Map<String, String> requestBody = {
      "salon_id": salonId,
      "branch_id": branchId,
      "customer_id": customerId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('Decoded Response Data: $responseData');

        if (responseData != null && responseData['status'] == "true") {
          var data = responseData['data'];
          if (data != null && data['is_member'] == "1") {
            var membershipDetails = data['membership_details'];
            if (membershipDetails != null) {
              setState(() {
                isMember = true;
                membershipName = membershipDetails['name']?.toString() ?? '';
                membershipReceipt =
                    membershipDetails['receipt']?.toString() ?? '';
              });

              print('Membership Details: $membershipDetails');
            } else {
              print('No membership details available');
            }
          } else {
            setState(() {
              isMember = false;
              membershipName = '';
              membershipReceipt = '';
            });

            print(
                'User is not a member or membership details are not available');
          }
        } else {
          print('Failed to fetch membership details or status is false');
        }
      } else {
        print(
            'Failed to load membership details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching membership details: $e');
    }
  }

  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return RefreshIndicator(
      onRefresh: () async {
        await fetchProfileDetails(customerId);
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                title: '',
              ),
            ),
          );

          return false;
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
                  icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(title: ''),
                      ),
                    );
                  },
                ),
                Text(
                  'Profile',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2024),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Container(
                color: CustomColors.backgroundLight,
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.02),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.06),
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenSize.width * 0.26,
                                height: screenSize.width * 0.26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CustomColors.backgroundtext,
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: profilePicUrl.isNotEmpty
                                      ? Image.network(
                                          profilePicUrl,
                                          fit: BoxFit.cover,
                                          cacheWidth:
                                              (screenSize.width * 0.26).toInt(),
                                          cacheHeight:
                                              (screenSize.width * 0.26).toInt(),
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child; // Image is fully loaded
                                            } else if (loadingProgress
                                                    .cumulativeBytesLoaded ==
                                                0) {
                                              // Image is still loading, show an image icon
                                              return const Center(
                                                child: Icon(
                                                  Icons.image,
                                                  size: 50,
                                                  color: Colors.black,
                                                ),
                                              );
                                            } else {
                                              // Show progress indicator while loading
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null, // Show a progress indicator if total bytes are available
                                                ),
                                              );
                                            }
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.account_circle,
                                                size: 50,
                                                color: Colors.black,
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.account_circle,
                                            size: 50,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              Center(
                                child: Text(
                                  fullName,
                                  style: GoogleFonts.lato(
                                    fontSize: screenSize.width * 0.05,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: 0.02,
                                    color: const Color(0xFF1D2024),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.015),
                              if (membershipName.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenSize.width * 0.02),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: screenSize.width * 0.04,
                                        color: Colors.amber[700],
                                      ),
                                      SizedBox(width: screenSize.width * 0.01),
                                      Flexible(
                                        child: Text(
                                          membershipName,
                                          style: GoogleFonts.lato(
                                            fontSize: screenSize.width * 0.04,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.amber[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: screenSize.height * 0.04),
                              ProfileMenuItem(
                                svgPath: 'assets/edit4.svg',
                                label: 'Edit Profile',
                                routeName: '/edit_profile',
                              ),
                              SizedBox(height: screenSize.height * 0.001),
                              ProfileMenuItem(
                                svgPath: 'assets/notif.svg',
                                label: 'Notification',
                                routeName: '/notification',
                              ),
                              SizedBox(height: screenSize.height * 0.001),
                              ProfileMenuItem(
                                svgPath: 'assets/pay.svg',
                                label: 'Payment',
                                targetPage: PaymentPageMember(),
                              ),
                              SizedBox(height: screenSize.height * 0.001),
                              ProfileMenuItem(
                                svgPath: 'assets/privacy2.svg',
                                label: 'Privacy Policy',
                                routeName: '/privacy_policy',
                              ),
                              SizedBox(height: screenSize.height * 0.001),
                              ProfileMenuItem(
                                svgPath: 'assets/application.svg',
                                label: 'About App',
                                routeName: '/saloon_details_page',
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              GestureDetector(
                                onTap: () {
                                  _showLogoutOverlay(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      CupertinoIcons.power,
                                      size: screenSize.width * 0.05,
                                      color: CustomColors.backgroundtext,
                                    ),
                                    SizedBox(
                                        width: screenSize.width *
                                            0.02), // Reduced space
                                    Flexible(
                                      child: Text(
                                        'Logout',
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: CustomColors.backgroundtext,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(width: 1.0, color: Colors.grey[300]!),
                        ),
                      ),
                      height: screenSize.height * 0.1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildButton(
                            context,
                            '/home',
                            'Home',
                            'assets/hut.svg',
                            iconColor: Color(0xFF424752),
                          ),
                          _buildButton(context, '/book_appointment',
                              'Book Appointment', 'assets/check-mark.svg'),
                          _buildButton(context, '/upcomingbooking',
                              'My Bookings', 'assets/schedule3.svg'),
                          _buildButton(context, '/saloon_details_page',
                              'Salon Details', 'assets/store.svg'),
                          _buildButton(
                            context,
                            '/profile',
                            'Profile',
                            'assets/user1.svg',
                            iconColor: CustomColors.backgroundtext,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String routeName, String label, String svgPath,
      {Color iconColor = Colors.black}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SvgPicture.asset(
              svgPath,
              width: 23,
              height: 23,
              color: iconColor, // Set icon color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: iconColor,
              // Remove fontFamily, as it's now handled by GoogleFonts
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutOverlay(BuildContext context) {
    OverlayEntry? _overlayEntry;

    Widget _buildLogoutOverlay(BuildContext context) {
      return GestureDetector(
        onTap: () {
          _overlayEntry?.remove();
        },
        child: Stack(
          children: [
            Container(
              color: const Color.fromRGBO(59, 68, 83, 0.5),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.76,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.92,
                height: MediaQuery.of(context).size.height * 0.24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(49),
                    topRight: Radius.circular(49),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    RichText(
                      text: TextSpan(
                        text: 'Logout',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: CustomColors.backgroundtext,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFD9D9D9),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    RichText(
                      text: TextSpan(
                        text: 'Are you sure you want to logout?',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: const Color(0xFF424752),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _overlayEntry?.remove();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.22,
                                MediaQuery.of(context).size.height * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                color: CustomColors.backgroundtext,
                              ),
                            ),
                            shadowColor: const Color(0x08000000),
                            elevation: 10,
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Cancel',
                              style: TextStyle(
                                color: CustomColors.backgroundtext,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await logOutUserFromDevice();

                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            await pref.clear();
                            Navigator.pop(context);

                            // Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const SignUpPage()),
                            //   (Route<dynamic> route) => false,
                            // );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QrCodePage()),
                              (Route<dynamic> route) => false,
                            );
                            _overlayEntry
                                ?.remove(); // Remove overlay on Yes press
                            setState(() {
                              _isOverlayVisible =
                                  false; // Set overlay flag to false
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.backgroundtext,
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.22,
                                MediaQuery.of(context).size.height * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            shadowColor: const Color(0x08000000),
                            elevation: 10,
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Yes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildLogoutOverlay(context),
    );

    Overlay.of(context)?.insert(_overlayEntry);

    setState(() {
      _isOverlayVisible = true;
    });
  }

  void _dismissOverlay(BuildContext context) {
    setState(() {
      _isOverlayVisible = false;
    });
  }
}

class ProfileHeader extends StatelessWidget {
  final String title;
  final Function()? onBackTap;

  const ProfileHeader({
    Key? key,
    required this.title,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.087,
          left: MediaQuery.of(context).size.width * 0.09,
          child: GestureDetector(
            onTap: onBackTap ??
                () {
                  Navigator.pop(context);
                },
            child: Transform.rotate(
              angle: -360 * 3.14159 / 180,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.09,
                height: MediaQuery.of(context).size.height * 0.04,
                padding: const EdgeInsets.fromLTRB(0, 5.01, 1, 5.01),
                child: Image.asset(
                  'assets/back.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.095,
          left: MediaQuery.of(context).size.width * 0.18,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: const Color(0xFF1D2024),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final String? routeName; // Route name for named navigation
  final Widget? targetPage; // Target page for direct navigation

  const ProfileMenuItem({
    Key? key,
    required this.svgPath,
    required this.label,
    this.routeName, // Make routeName optional
    this.targetPage, // Make targetPage optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (targetPage != null) {
          // Navigate to the target page if provided
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage!),
          );
        } else if (routeName != null && routeName!.isNotEmpty) {
          // Navigate using the route name if provided
          Navigator.pushNamed(context, routeName!);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.015),
        child: Row(
          children: [
            // Icon container
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              height: MediaQuery.of(context).size.width * 0.05,
              child: SvgPicture.asset(
                svgPath,
                width: 24,
                height: 24,
                color: const Color(0xFF353B43),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            // Flexible text container
            Expanded(
              child: Container(
                child: Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    letterSpacing: 0.02,
                    color: const Color(0xFF424752),
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: MediaQuery.of(context).size.width * 0.066,
              color: const Color(0xFF424752),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String routeName;
  final String label;
  final String imagePath;

  const ProfileButton({
    Key? key,
    required this.routeName,
    required this.label,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: MediaQuery.of(context).size.width * 0.048,
            height: MediaQuery.of(context).size.width * 0.048,
            color:
                routeName == '/profile' ? Colors.blue : const Color(0xFF353B43),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.024),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: MediaQuery.of(context).size.width * 0.024,
              fontWeight: FontWeight.w500,
              color: routeName == '/profile'
                  ? Colors.blue
                  : const Color(0xFF353B43),
            ),
          ),
        ],
      ),
    );
  }
}
