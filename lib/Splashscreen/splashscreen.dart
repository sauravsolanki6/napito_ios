import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Onboarding_Screen/onboardingscreen1.dart';
import 'package:ms_salon_task/Onboarding_Screen/onboardingscreen2.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';
import 'package:ms_salon_task/Scanner/scan_details.dart';
import 'package:ms_salon_task/SignUp/SignUpPage.dart';
import 'package:ms_salon_task/dummypage.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String mobileNumber = '';
  String isLoginFirst = '';
  String isOtpVerified = '';
  String updateStatus = 'Checking for updates...';
  String isStoreSelected = '';
  bool _isConnected = true; // Track internet connection status
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    checkForUpdate();
    getValuesFromSharedPref();
    // _initDeepLinkListener();
    initDeepLinkListener();
  }

  @override
  void dispose() {
    super.dispose();
    _sub?.cancel();
  }

  void initDeepLinkListener() async {
    try {
      uriLinkStream.listen((Uri? uri) async {
        if (uri != null) {
          String? giftcardCode = uri.queryParameters['giftcard_code'];
          String? saloonCode = uri.queryParameters['saloon_code'];

          if (giftcardCode != null && saloonCode != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('gift_card_code', giftcardCode);
            await prefs.setString('saloon_code', saloonCode);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ScanDetailsPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(title: 'Invalid Deep Link'),
              ),
            );
          }
        }
      }).onError((error) {
        print("Error in deep link listener: $error");
      });
    } catch (e) {
      print("Error in initDeepLinkListener: $e");
    }
  }

  // Future<void> _initDeepLinkListener() async {
  //   try {
  //     if (_sub == null) {
  //       // Get initial deep link if app was opened with one
  //       final initialLink = await getInitialLink();
  //       if (initialLink != null) {
  //         _handleDeepLink(initialLink);
  //       }

  //       // Listen for subsequent deep links (if the app is already running)
  //       _sub = linkStream.listen((String? link) {
  //         if (link != null) {
  //           _handleDeepLink(link);
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error initializing deep link listener: $e");
  //   }
  // }

  // void _handleDeepLink(String? link) async {
  //   print("Deep link received: $link");

  //   if (link == null || link.isEmpty) {
  //     print("Deep link is null or empty, calling getValuesFromSharedPref.");
  //     getValuesFromSharedPref();
  //     return;
  //   }

  //   try {
  //     Uri uri = Uri.parse(link);
  //     print("Parsed URI: $uri");

  //     // Check if the scheme and host match expected values
  //     if (uri.scheme == 'https' &&
  //         uri.host == 'staginglink.org' &&
  //         uri.path == '/saloon-new/phase-two') {
  //       print("Scheme, host, and path match expected values.");

  //       // Clear all previous preferences
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.clear();
  //       print("All previous preferences cleared.");

  //       // Extract 'saloon_code' from the URL
  //       String? saloonCode = uri.queryParameters['saloon_code'];
  //       print("Extracted saloon_code: $saloonCode");

  //       if (saloonCode != null && saloonCode.isNotEmpty) {
  //         print("Valid saloon_code found: $saloonCode");

  //         // Save saloon code to SharedPreferences
  //         await prefs.setString('scanned_code', saloonCode);
  //         print("Saloon code saved to SharedPreferences.");

  //         // Navigate to the ScanDetailsPage and clear previous routes
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => ScanDetailsPage()),
  //           (Route<dynamic> route) =>
  //               false, // This will remove all previous routes
  //         );
  //       } else {
  //         print("No saloon_code found in the deep link");
  //       }
  //     } else {
  //       print("Deep link host, scheme, or path does not match expected values");
  //     }
  //   } catch (e) {
  //     print("Error parsing deep link: $e");
  //   }
  // }

  //  void getValuesFromSharedPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   mobileNumber = prefs.getString('mobileNumber') ?? '';
  //   isLoginFirst = prefs.getString('isloginfirst') ?? '';
  //   isOtpVerified = prefs.getString('isOtpVerified') ?? '';
  //   setState(() {}); // Trigger rebuild with new values
  //   movenext();
  // }
  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Perform a test to check if the internet is reachable
    bool isConnected = false;

    if (connectivityResult == ConnectivityResult.none) {
      _isConnected = false;
      print("Internet is not connected.");
    } else {
      // Try pinging a known reliable host (Google DNS or any other public server)
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _isConnected = true;
          print("Internet is connected.");
        } else {
          _isConnected = false;
          print("No internet connection.");
        }
      } catch (e) {
        _isConnected = false;
        print("No internet connection.");
      }
    }

    setState(() {});
  }

  void checkForUpdate() async {
    print("Checking for updates...");

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showErrorSnackbar("No internet connection");
      return;
    }

    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      print("Update info: $updateInfo");

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        setState(() {
          updateStatus = 'An update is available!';
        });
        print("Update is available!"); // Debug print

        showUpdateDialog();
      } else {
        print("No update available."); // Debug print
      }
    } catch (e) {
      // Log the error to the console without updating the UI
      print("Error checking for update: $e");
    } finally {
      // Proceed with your future task without updating the UI
      await Future.delayed(
          Duration(seconds: 3)); // Wait for 3 seconds before proceeding
      getValuesFromSharedPref();
    }
  }

  void showUpdateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0), // Add some padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.backgroundtext,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Icon(
                Icons.system_update_alt,
                size: 60,
                color: CustomColors.backgroundtext,
              ),
              SizedBox(height: 20),
              Text(
                "A new version of the app is available. Please update to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: CustomColors.backgroundtext,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 24),
                  ),
                  child: Text("Update"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await InAppUpdate.performImmediateUpdate();
                    } catch (e) {
                      print("Error performing update: $e");
                      showErrorSnackbar(
                          'Error performing update: $e'); // Show error in UI
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void getValuesFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch values from SharedPreferences
    mobileNumber = prefs.getString('mobileNumber') ?? '';
    isLoginFirst = prefs.getString('isloginfirst') ?? '';
    isOtpVerified = prefs.getString('isOtpVerified') ?? '';
    isStoreSelected = prefs.getString('store_name') ?? '';

    // Print the values
    print('Mobile Number: $mobileNumber');
    print('Is Login First: $isLoginFirst');
    print('Is OTP Verified: $isOtpVerified');
    print('Store Selected: $isStoreSelected');

    if (mounted) {
      setState(() {}); // Update state after fetching shared preferences

      // Delay calling movenext() by 2.5 seconds
      Future.delayed(Duration(milliseconds: 2500), () {
        movenext();
      });
    }
  }

  void movenext() {
    if (isStoreSelected == null || isStoreSelected.isEmpty) {
      // If isStoreSelected is null or empty, navigate to the Onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnboardingScreen2(),
        ),
      );
    } else {
      if (isOtpVerified == "2") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(title: ''),
          ),
        );
      } else {
        if (isLoginFirst == "1" && isOtpVerified == "2") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QrCodePage(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnboardingScreen2(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundtext,
      body: Center(
        child: _isConnected
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/splash.png', width: 400, height: 104),
                    SizedBox(height: 20),
                    // Only show updateStatus when there's an update available
                    if (updateStatus != 'Checking for updates...')
                      Text(
                        updateStatus,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.all(20), // Optional padding around image
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image
                    Image.asset(
                      'assets/nointernet.png', // Replace with your image asset path
                      height: 300, // Set the height of the image
                      width: 300, // Set the width of the image
                    ),
                    SizedBox(height: 20), // Add space between image and button
                    // Retry Button
                    ElevatedButton(
                      onPressed: () async {
                        await _checkInternetConnection(); // Retry the internet connection check
                        if (_isConnected) {
                          Navigator.pushReplacementNamed(
                              context, '/'); // Navigate to homepage
                        }
                      },
                      child: Text('Retry', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: CustomColors.backgroundtext,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)), // Button color
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
