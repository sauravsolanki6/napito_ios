import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';
import 'package:ms_salon_task/SignUp/SignUpOTPPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_crash/Crashannalytics.dart';
import '../main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isChecked = true; // Checkbox state
  bool isLoading = false; // Loading indicator state
  TextEditingController mobileNumberController =
      TextEditingController(); // Controller to store phone number

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    mobileNumberController.dispose();
    super.dispose();
  }

  void _navigateToOTPPage() async {
    final errorLogger = ErrorLogger();
    String phoneNumber = mobileNumberController.text.trim();

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your WhatsApp number'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else if (phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 10-digit WhatsApp number'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Fetch salon_id and branch_id from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salonId = prefs.getString('salon_id') ?? '';
    String branchId = prefs.getString('branch_id') ?? '';

    // Prepare the request body
    var requestBody = {
      "mobile_number": phoneNumber,
      "salon_id": salonId.toString(),
      "branch_id": branchId.toString(),
    };

    // API endpoint URL
    var url = Uri.parse('${MyApp.apiUrl}customer/login-otp/');

    try {
      // Make POST request to the API
      var response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Print the response body
        log('Response: ${response.body}');

        // Parse the JSON response
        var jsonResponse = jsonDecode(response.body);

        // Print salon_id and branch_id
        print('Salon ID: $salonId');
        print('Branch ID: $branchId');

        if (jsonResponse != null && jsonResponse['data'] != null) {
          await prefs.setString(
              'mobileNumber', phoneNumber); // Store mobile number

          // Example of safe accessing fields
          var data = jsonResponse['data'];
          var otp = data['otp'] != null ? data['otp'].toString() : '';
          var isNew = data['is_new'] ?? false; // Extract is_new field
          var isConnectStore = data['is_connect_store'] ??
              false; // Extract is_connect_store field

          await prefs.setString('otp', otp); // Store otp
          await prefs.setBool('is_new', isNew); // Store is_new as boolean

          // Clear the specific shared preference value after success
          await prefs.remove('is_store_selected');

          // Show success message in Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 200), // Set duration to 200ms
            ),
          );

          // Navigate based on the is_connect_store value
          if (isConnectStore) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QrCodePage(), // Ensure QrCodePage is defined
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpOTPPage(),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get OTP. Please try again later.'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get OTP. Please try again later.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e, stackTrace) {
      await errorLogger.setUserId(salonId);

      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "API's -> storefiledetailsInFirestore",
        userId: "user123",
        receiverId: "receiver456",
        // errorDetails: {"request": "fetchData", "responseCode": 500},
        stackTrace: stackTrace,
      );
      print("Error storing file details in Firestore: $e");
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred. Please try again later.'),
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrCodePage(),
          ),
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background images as overlays
            Positioned(
              top: 0,
              width: screenWidth,
              height: screenHeight * 0.6,
              child: Image.asset(
                'assets/signupback1.png', // Replace with your upper background image asset path
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              width: screenWidth,
              height: screenHeight * 0.6,
              child: Transform.rotate(
                angle: -180 *
                    (3.14 / 180), // Convert degrees to radians for rotation
                child: Image.asset(
                  'assets/signupback1.png', // Replace with your lower background image asset path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Main content
            Positioned(
              top: screenHeight * 0.1,
              left: screenWidth * 0.1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QrCodePage()),
                  );
                  // Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/back.png', // Replace with your image asset path
                  width: 24, // Width of the image
                  height: 24, // Height of the image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Text(
                      'Start Your Journey!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato', // Set font family
                        fontSize: 28, // Set font size
                        fontWeight: FontWeight.w800, // Set font weight
                        color: Color(0xFF353B43), // Set text color
                        height: 33.6 / 28, // Set line height
                        letterSpacing: 0.02, // Set letter spacing
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Text(
                      'Create a new account',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato', // Set font family
                        fontSize: 14, // Set font size
                        fontWeight: FontWeight.w500, // Set font weight
                        color: Color(0xFF353B43), // Set text color
                        height: 16.8 / 14, // Set line height
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Container(
                      height: 48, // Height of the container
                      decoration: BoxDecoration(
                        color: Colors.white, // Set background color to white
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              8), // Apply border radius to top left corner
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16), // Add horizontal padding
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.phone,
                              size: 20,
                              color: Colors.black,
                            ),
                            SizedBox(
                                width:
                                    10), // Space between the icon and the line
                            Container(
                              width: 1, // Width of the line
                              height: 24, // Height of the line
                              color: Color(0xFFC4C4C4), // Set line color
                            ),
                            SizedBox(
                                width:
                                    10), // Space between the line and the text field
                            Expanded(
                              child: TextField(
                                controller:
                                    mobileNumberController, // Assign the controller
                                decoration: InputDecoration(
                                  hintText: 'Enter your WhatsApp number',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFC4C4C4),
                                    height: 12 / 10,
                                    letterSpacing: 0.02,
                                  ),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType
                                    .phone, // Set keyboard type to phone
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits
                                  LengthLimitingTextInputFormatter(
                                      10), // Limit to 10 characters
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Row(
                      children: [
                        // GestureDetector(
                        //   onTap: () {
                        //     setState(() {
                        //       isChecked = !isChecked; // Toggle checkbox state
                        //     });
                        //   },
                        //   child: Container(
                        //     width: 20, // Width of the checkbox
                        //     height: 19, // Height of the checkbox
                        //     decoration: BoxDecoration(
                        //       color: Colors.white, // Background color
                        //       borderRadius: BorderRadius.only(
                        //         topLeft: Radius.circular(2),
                        //       ),
                        //       border: Border.all(
                        //         color: Color(0xFFD3D6DA), // Border color
                        //         width: 1, // Border width
                        //       ),
                        //     ),
                        //     child: isChecked
                        //         ? Icon(
                        //             Icons.check,
                        //             size: 14,
                        //             color: Colors.blue, // Checkbox check color
                        //           )
                        //         : null,
                        //   ),
                        // ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'A 6 digit security code will be sent via SMS to verify your mobile number!',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Lato', // Set font family
                              fontSize: 12, // Set font size
                              fontWeight: FontWeight.w400, // Set font weight
                              color: Color(0xFF3B4453), // Set text color
                              height: 12 / 10, // Set line height
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: GestureDetector(
                      onTap:
                          _navigateToOTPPage, // Navigate to Sign up OTP screen
                      child: Container(
                        height: 48, // Height of the container
                        decoration: BoxDecoration(
                          color:
                              CustomColors.backgroundtext, // Background color
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                                6), // Apply border radius to top left corner
                          ),
                        ),
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(
                                  // Show loader if isLoading is true
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  'Get OTP',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
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
}
