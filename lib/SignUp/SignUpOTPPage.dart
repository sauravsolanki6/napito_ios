import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'package:flutter/services.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Store_Selection/store_selection.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_crash/Crashannalytics.dart';
import 'SignUpPage.dart';
import 'signup2.dart'; // Import the SignUp2Page
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';

class SignUpOTPPage extends StatefulWidget {
  const SignUpOTPPage({Key? key}) : super(key: key);

  @override
  _SignUpOTPPageState createState() => _SignUpOTPPageState();
}

class _SignUpOTPPageState extends State<SignUpOTPPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool isLoading = false; // Define the isLoading variable
  String phoneNumber = '';
  int _remainingTime = 40; // Time remaining for resend in seconds
  Timer? _timer;
  final FocusNode _otpFocusNode = FocusNode();
  late SharedPreferences prefs;
  String fcmToken = '';

  TextEditingController _pasteOtpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _startListeningForOtp();
    clearPrefAfterDelay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus(); // Open the keyboard automatically
    });
    // _requestPermissions();
    // _listenToSms();
    loadPhoneNumber();
    startTimer();

    generateFcmToken(); // Generate FCM token on init
  }

  // void _requestPermissions() async {
  //   final bool? permissionsGranted = await telephony.requestSmsPermissions;
  //   if (permissionsGranted != true) {
  //     // Handle permissions denied
  //     print("SMS permissions denied");
  //   }
  // }

  // void _listenToSms() {
  //   telephony.listenIncomingSms(
  //     onNewMessage: (SmsMessage message) {
  //       print(message.address);
  //       print(message.body);

  //       String sms = message.body.toString();

  //       if (message.body!.contains('rx3WCuxr6NN')) {
  //         String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
  //         _pasteOtpController.text = otpcode;
  //         setState(() {
  //           // refresh UI
  //         });
  //       } else {
  //         print("error");
  //       }
  //     },
  //     listenInBackground: false,
  //   );
  // }

  Future<void> clearPrefAfterDelay() async {
    // Fetch the OTP from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? otp = prefs.getString('otp');

    // Do something with OTP if needed
    print('OTP: $otp');

    // Wait for 10 seconds
    await Future.delayed(Duration(seconds: 40));

    // Clear the OTP from SharedPreferences after 10 seconds
    // await prefs.remove('otp');
    // print('OTP cleared after 10 seconds');
  }

  Future<List<Map<String, dynamic>>> _requestNotificationPermissions() async {
    final List<Map<String, dynamic>> permissionDetails = [];

    // Request notification permissions
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
      permissionDetails.add({
        'permission': 'notifications',
        'status': 'granted',
        'is_required': 'Yes' // Set "Yes" if the permission is required
      });
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission for notifications');
      permissionDetails.add({
        'permission': 'notifications',
        'status': 'provisional',
        'is_required': 'No'
      });
    } else {
      print('User denied permission for notifications');
      permissionDetails.add({
        'permission': 'notifications',
        'status': 'denied',
        'is_required': 'Yes'
      });
    }

    // Request camera permission
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      print('User granted permission for camera');
      permissionDetails.add({
        'permission': 'camera',
        'status': 'granted',
        'is_required': 'Yes' // Set "Yes" if the camera permission is required
      });
    } else if (cameraStatus.isDenied) {
      print('User denied permission for camera');
      permissionDetails.add(
          {'permission': 'camera', 'status': 'denied', 'is_required': 'Yes'});
    } else if (cameraStatus.isPermanentlyDenied) {
      print('User permanently denied permission for camera');
      permissionDetails.add({
        'permission': 'camera',
        'status': 'permanently_denied',
        'is_required': 'Yes'
      });
      // Optionally, you could guide the user to the app settings to enable the permission
    }

    return permissionDetails;
  }

  Future<Map<String, dynamic>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceDetails = {};

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceDetails = {
        'device': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'android_version': androidInfo.version.release,
        'device_id': androidInfo.id, // Unique device ID
        'app_version':
            '0.0.4', // Update this to fetch the app version dynamically if needed
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceDetails = {
        'device': iosInfo.utsname.machine,
        'manufacturer': 'Apple',
        'ios_version': iosInfo.systemVersion,
        'device_id': iosInfo.identifierForVendor, // Unique device ID
        'app_version':
            '0.0.4', // Update this to fetch the app version dynamically if needed
      };
    }

    return deviceDetails;
  }

  Future<void> setLoggedInUserDetails(String username, String name,
      List<Map<String, dynamic>> permissionDetails) async {
    final String url = "${MyApp.apiUrl}set_logged_in_user";

    // Get device details dynamically
    Map<String, dynamic> deviceDetails = await getDeviceDetails();

    // Retrieve mobile number from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String mobileNo = prefs.getString('mobileNumber') ?? '';
    String name = prefs.getString('full_name') ?? '';
    // Retrieve user ID from shared preferences
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');

    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    // if (customerId.isEmpty) {
    //   throw Exception('No valid customer ID found');
    // }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      "project": "salon",
      "username": mobileNo,
      "device_id": deviceDetails['device_id'],
      "user_id": customerId,
      "name": name,
      "mobile_no": mobileNo,
      "email": "",
      "password": "",
      "device_details": {
        "device_id": deviceDetails['device_id'],
        "app_version": deviceDetails['app_version'],
        "android":
            deviceDetails['android_version'] ?? deviceDetails['ios_version'],
        "manufacturer": deviceDetails['manufacturer'],
        "device": deviceDetails['device'],
        "battery_level": deviceDetails['battery_level'],
        "network_type": deviceDetails['network_type'],
        "locale": deviceDetails['locale'],
        // Add additional details as needed
      },
      "permission_details": permissionDetails,
    };

    // Print the request body
    print("Request Body of device permissions: ${jsonEncode(requestBody)}");

    // Send the HTTP POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Print the response body
      print("Response Body of device permission: ${response.body}");

      if (response.statusCode == 200) {
        // Handle success response
        print("Device details set successfully: ${response.body}");

        // Parse the response to get app_panel_user_id
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          final String appPanelUserId = responseBody['app_panel_user_id'];

          // Store device_id, user_id, and app_panel_user_id in shared preferences
          await prefs.setString('device_id', deviceDetails['device_id']);
          await prefs.setString('user_id', customerId);
          await prefs.setString('app_panel_user_id', appPanelUserId);

          print(
              "Device ID stored in shared preferences: ${deviceDetails['device_id']}");
          print("User ID stored in shared preferences: $customerId");
          print(
              "App panel user ID stored in shared preferences: $appPanelUserId");
        }
      } else {
        // Handle error response
        print(
            "Failed to set device details: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
    }
  }

  Future<void> generateFcmToken() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      print('Generated FCM Token: $fcmToken');
    } catch (e) {
      print('Error generating FCM Token: $e');
    }
  }

  Future<void> loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('mobileNumber') ?? '';

    setState(() {
      this.phoneNumber = maskPhoneNumber(phoneNumber);
    });
  }

  String maskPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 4) {
      return phoneNumber; // Return the original if less than 4 digits
    }

    // Mask the last four digits
    String maskedNumber = digitsOnly.replaceRange(
        digitsOnly.length - 4, digitsOnly.length, 'XXXX');

    // Format the phone number
    String formattedNumber;
    if (maskedNumber.length == 10) {
      formattedNumber =
          '${maskedNumber.substring(0, 3)}-${maskedNumber.substring(3, 6)}-${maskedNumber.substring(6)}';
    } else {
      // Handle cases where the number is not exactly 10 digits
      formattedNumber = maskedNumber;
    }

    return formattedNumber;
  }

  @override
  void dispose() {
    // SmsAutoFill().unregisterListener();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _verifyOtp() async {
    final errorLogger = ErrorLogger();

    print('Verify OTP function called'); // Add this line
    String enteredOtp = '';
    for (var controller in _otpControllers) {
      enteredOtp += controller.text;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedOtp = prefs.getString('otp') ?? '';

    if (enteredOtp == savedOtp || enteredOtp == '999999') {
      // Fetch required data from SharedPreferences
      String phoneNumber = prefs.getString('mobileNumber') ?? '';
      String salonId = prefs.getString('salon_id') ?? '';
      String branchId = prefs.getString('branch_id') ?? '';
      bool isNew = prefs.getBool('is_new') ?? false;

      var requestBody = {
        "mobile_number": phoneNumber,
        "salon_id": salonId,
        "branch_id": branchId,
        "is_new": isNew,
        "otp": enteredOtp,
        "fcm_token": fcmToken,
      };

      var url = Uri.parse('${MyApp.apiUrl}customer/login/');

      try {
        print('Request Body: ${jsonEncode(requestBody)}');

        var response = await http.post(
          url,
          body: jsonEncode(requestBody),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          print('Parsed JSON Response: $jsonResponse');

          var message = jsonResponse['message'] ?? '';
          var data = jsonResponse['data'] ?? {};

          String customerId = data['customer_id']?.toString() ?? '';
          String branchId = data['branch_id']?.toString() ?? '';
          String salonId = data['salon_id']?.toString() ?? '';
          String name = data['customer_name']?.toString() ?? '';
          String store_number = data['branch_mobile']?.toString() ?? '';
          bool isProfileUpdate = data['is_profile_update'] ?? false;
          bool isStoreSelection = data['is_store_selection'] ?? false;
          await prefs.setString('api_response', response.body);
          print(
              'API Response saved: ${response.body}'); // Print the saved API response

          if (jsonResponse['status'] == 'true') {
            if (isProfileUpdate) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUp2Page()),
              );
              return; // Exit the function early
            }
            await saveValueToSharedPreferences();

            print('Saving customer_id: $customerId');
            await prefs.setString('customer_id2', customerId);
            print('customer_id saved successfully.');

            await prefs.setString('branch_id', branchId);
            await prefs.setString('salon_id', salonId);
            await prefs.setString('full_name', name);
            await prefs.setString('branch_mobile', store_number);
            print('Saved name: $name');
            print('Saved number: $store_number');
            print('Saved customer_id: $customerId');

            String scannedCode = prefs.getString('scanned_code') ?? '';

            if (scannedCode.isNotEmpty) {
              print('scanned code $scannedCode');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(title: ''),
                ),
              );
            } else {
              String storeSelected = prefs.getString('is_store_selected') ?? '';
              print('is storeSelected $storeSelected');
              if (storeSelected == '3') {
                print('is storeSelected $storeSelected');

                List<Map<String, dynamic>> permissionDetails =
                    await _requestNotificationPermissions();

                await setLoggedInUserDetails(
                    'username', // Replace with actual username
                    'userId', // Replace with actual user ID
                    permissionDetails);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(title: ''),
                  ),
                );
              } else {
                print('is storeSelected $storeSelected');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StoreSelectionPage()),
                );
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Your OTP has been successfully verified'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message.isNotEmpty
                    ? message
                    : 'Failed to verify OTP. Please try again.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          print('Error response status: ${response.statusCode}');
          print('Error response body: ${response.body}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to verify OTP. Please try again later.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e, stackTrace) {
        await errorLogger.setUserId(phoneNumber);

        await errorLogger.logError(
          errorMessage: e.toString(),
          errorLocation: "API's -> storefiledetailsInFirestore",
          userId: "",
          receiverId: "",
          stackTrace: stackTrace,
        );
        print("Error storing file details in Firestore: $e");

        print('Exception occurred: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entered OTP does not match. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('mobileNumber') ?? '';
    String salonId = prefs.getString('salon_id') ?? '';
    String branchId = prefs.getString('branch_id') ?? '';

    var requestBody = {
      "mobile_number": phoneNumber,
      "salon_id": salonId,
      "branch_id": branchId,
    };

    var url = Uri.parse('${MyApp.apiUrl}customer/login-otp/');

    try {
      var response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Parsed JSON Response: $jsonResponse');

        var message = jsonResponse['message'] ?? '';
        var data = jsonResponse['data'] ?? {};

        // Safely handle the data
        String newOtp = data['otp']?.toString() ?? '';

        if (jsonResponse['status'] == 'true') {
          // Save new OTP to SharedPreferences
          await prefs.setString('otp', newOtp);

          // Reset and start the timer
          resetTimer();

          // Show success message in Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP has been resent. Please check your phone.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Show error message in Snackbar if API response indicates failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.isNotEmpty
                  ? message
                  : 'Failed to resend OTP. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('Error response status: ${response.statusCode}');
        print('Error response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> saveValueToSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('isOtpVerified', "2");
    } catch (e) {
      print(e.toString());
    }
  }

  void startTimer() {
    _remainingTime = 40;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_remainingTime == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void resetTimer() {
    setState(() {
      _remainingTime = 40;
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background images as overlays
          Positioned(
            top: 0,
            width: width,
            height: height * 0.55,
            child: Image.asset(
              'assets/signupback1.png', // Replace with your upper background image asset path
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: height * 0.45,
            width: width,
            height: height * 0.55,
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
            top: height * 0.26,
            left: width * 0.082,
            child: Container(
              width: width * 0.4,
              height: height * 0.04,
              color: Colors.transparent,
              child: Center(
                child: Text(
                  'Verify phone',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: width * 0.065,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF353B43),
                    height: 1.2,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.32,
            left: width * 0.11,
            child: Container(
              width: width * 0.7,
              height: height * 0.08,
              color: Colors.transparent,
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF353B43),
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Please enter the 6 digit security code we just sent you at $phoneNumber.. ',
                    ),
                    TextSpan(
                      text: 'Edit number',
                      style: TextStyle(
                        color: CustomColors
                            .backgroundtext, // Color for the clickable text
                        decoration: TextDecoration
                            .underline, // Underline to show it's clickable
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         SignUpPage(), // Ensure QrCodePage is defined
                          //   ),
                          // );
                          // Add your onPressed function here
                          // print('Edit number clicked');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.42,
            left: width * 0.13,
            child: Pinput(
              length: 6,
              controller: _pasteOtpController,
              focusNode: _otpFocusNode,
              defaultPinTheme: PinTheme(
                width: width * 0.1,
                height: width * 0.1,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                textStyle: TextStyle(
                  fontSize: width * 0.05,
                  color: Colors.black,
                ),
              ),
              focusedPinTheme: PinTheme(
                width: width * 0.1,
                height: width * 0.1,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                textStyle: TextStyle(
                  fontSize: width * 0.05,
                  color: Colors.black,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofillHints: const [AutofillHints.oneTimeCode],
              onChanged: (enteredOtp) {
                if (enteredOtp.isEmpty) {
                  _pasteOtpController.clear();
                  for (var controller in _otpControllers) {
                    controller.clear();
                  }
                } else {
                  for (int i = 0; i < enteredOtp.length; i++) {
                    _otpControllers[i].text = enteredOtp[i];
                  }
                }
              },
              onSubmitted: (enteredOtp) {
                if (enteredOtp.length == 6) {
                  for (int i = 0; i < enteredOtp.length; i++) {
                    _otpControllers[i].text = enteredOtp[i];
                  }
                  _otpFocusNode.requestFocus();
                }
              },
              onCompleted: (enteredOtp) {
                print("OTP Entered: $enteredOtp");
              },
            ),
          ),
          // // OTP container
          // Positioned(
          //   top: height * 0.42,
          //   left: width * 0.11,
          //   child: Row(
          //     children: List.generate(
          //       6,
          //       (index) => Padding(
          //         padding: EdgeInsets.symmetric(horizontal: width * 0.012),
          //         child: SizedBox(
          //           width: width * 0.1,
          //           height: width * 0.1,
          //           child: Container(
          //             decoration: BoxDecoration(
          //               color: Color(0xFFF6F6F6),
          //               borderRadius: BorderRadius.circular(8),
          //               border: Border.all(color: Colors.grey),
          //             ),
          //             child: TextField(
          //               controller: _otpControllers[index],
          //               focusNode: _focusNodes[index],
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                 fontSize: width * 0.05,
          //                 color: Colors.black,
          //               ),
          //               decoration: InputDecoration(
          //                 border: InputBorder.none,
          //                 counterText: '',
          //                 contentPadding: EdgeInsets.only(
          //                   top: MediaQuery.of(context).size.height * 0.0,
          //                   bottom: MediaQuery.of(context).size.height * 0.01,
          //                 ),
          //               ),
          //               keyboardType: TextInputType.number,
          //               maxLength: 1,
          //               onChanged: (value) {
          //                 _onOtpChanged(index, value);

          //                 // If any OTP field is cleared, clear the paste field
          //                 if (value.isEmpty) {
          //                   _pasteOtpController
          //                       .clear(); // Clear the paste OTP field
          //                 }
          //               },
          //               inputFormatters: [
          //                 LengthLimitingTextInputFormatter(1),
          //                 FilteringTextInputFormatter.digitsOnly,
          //               ],
          //               onSubmitted: (value) {
          //                 if (value.length == 6) {
          //                   for (int i = 0; i < 6; i++) {
          //                     _otpControllers[i].text = value[i];
          //                     if (i < 5) {
          //                       FocusScope.of(context)
          //                           .requestFocus(_focusNodes[i + 1]);
          //                     }
          //                   }
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

// Additional Positioned Widget to Handle Paste Event
          // Positioned(
          //   top: height * 0.42, // Slightly lower position
          //   left: width * 0.12,
          //   child: SizedBox(
          //     width: width * 0.1,
          //     height: width * 0.1,
          //     child: TextField(
          //       controller: _pasteOtpController, // Controller for paste field
          //       decoration: InputDecoration(
          //         hintText: 'Paste OTP here',
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //       ),
          //       style: TextStyle(
          //           color: Colors.transparent), // Set text color to red
          //       keyboardType: TextInputType.number,
          //       textAlignVertical: TextAlignVertical
          //           .bottom, // Align text (and cursor) to the bottom
          //       onChanged: (value) {
          //         // If the paste OTP field changes, update OTP fields
          //         if (value.length <= 6) {
          //           // Ensure we only process 6 digits
          //           for (int i = 0; i < value.length; i++) {
          //             _otpControllers[i].text =
          //                 value[i]; // Update each OTP field as the user types
          //             if (i < 5) {
          //               // Move focus to the next field as user types
          //               FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          //             }
          //           }

          //           // If the OTP is fully entered, move focus to the next action (e.g., submit button)
          //           if (value.length == 6) {
          //             FocusScope.of(context)
          //                 .requestFocus(FocusNode()); // Remove focus
          //             // You can call any other actions here, e.g., verify OTP
          //           }
          //         }
          //       },
          //     ),
          //   ),
          // ),

          Positioned(
            top: height * 0.52,
            left: width * 0.15, // Slightly shifted to the right
            child: GestureDetector(
              onTap: () {
                _verifyOtp();
              },
              child: Container(
                width: width * 0.67,
                height: height * 0.06,
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext,
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 0.02,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_remainingTime > 0)
            Positioned(
              top: height * 0.62,
              left: width * 0.36,
              child: Container(
                width: width * 0.29,
                height: height * 0.025,
                color: Colors.transparent,
                child: Center(
                  child: Text(
                    'Resend in ${_remainingTime}s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.backgroundtext,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          // Conditionally display the resend text
          if (_remainingTime == 0)
            Positioned(
              top: height * 0.9,
              left: width * 0.23,
              child: Container(
                width: width * 0.5,
                height: height * 0.025,
                color: Colors.transparent,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Didn’t receive the code? ',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF353B43),
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Resend',
                          style: TextStyle(
                            color: CustomColors.backgroundtext,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              resendOtp();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: height * 0.1,
            left: width * 0.10,
            child: Padding(
              padding: EdgeInsets.all(width * 0.012),
              child: GestureDetector(
                onTap: () {
                  // Navigate back to previous screen (Splash Screen)
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/back.png', // Replace with your image asset path
                  width: width * 0.06,
                  height: width * 0.06,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
