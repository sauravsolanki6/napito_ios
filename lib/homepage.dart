import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Hairstyles/hairstyles.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/Profile/notification.dart';
import 'package:ms_salon_task/Raise_Ticket/sos.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';
import 'package:ms_salon_task/Scanner/qr_code_home.dart';
import 'package:ms_salon_task/Sidebar/sidebar.dart';
import 'package:ms_salon_task/Sidebar/sidebar_drawer.dart';
import 'package:ms_salon_task/banner_section.dart';
import 'package:ms_salon_task/homepageapi_models/banner_service.dart';
import 'package:ms_salon_task/homepageapi_models/facility_service.dart';
import 'package:ms_salon_task/homepageapi_models/health_tips.dart';
import 'package:ms_salon_task/homepageapi_models/products.dart';
import 'package:ms_salon_task/homepageapi_models/store_services.dart';
import 'package:ms_salon_task/main.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages1.dart';
import 'package:ms_salon_task/offers%20and%20membership/membership.dart';
import 'package:ms_salon_task/offers%20and%20membership/offers.dart';
import 'package:ms_salon_task/service_detail_page.dart';
import 'package:ms_salon_task/shoecaseexp.dart';
import 'package:ms_salon_task/tip_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  bool _isSidebarOpen = false;
  String customerID = '';
  List<Map<String, dynamic>> _permissions = [];
  String branchID = '';
  String salonID = '';
  int _backPressCount = 0;
  DateTime? _lastBackPressTime;
  String mobileNumber = '';
  final ApiService apiService = ApiService();
  late Future<List<ServiceCategory>> _serviceCategories;
  late Future<List<Products>> _productsFuture;
  late Future<List<TipModel>> _healthModel;
  String _storeName = 'Default Store Name';
  String _name = '';
  late Future<List<String>> _bannersFuture;
  int _currentPage = 0;
  String _storeNumber = 'Default Store Number';
  String _instagramLink = '';
  String _facebookLink = '';
  String _youtubeLink = '';
  String _websiteLink = '';
  bool _isConnected = true; // Track internet connection status
  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        // Optionally set some loading state here
      });

      _serviceCategories = ServiceCategory.fetchServiceCategories();
      _healthModel = TipModel.fetchTips() as Future<List<TipModel>>;
      // Fetch all necessary data during refresh
      // _serviceCategories = await ServiceCategory.fetchServiceCategories();
      _loadStoreName();
      _loadName();
      _checkFirstLaunch();
      checkNetworkConnection();
      _bannersFuture = _loadBanners();
      _productsFuture = fetchProducts();
      _fetchStoreSocials();
      _fetchStoreProfile();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      setState(() {
        _productsFuture = fetchProducts();
        _bannersFuture = _loadBanners(); // Ensure banners are loaded
      });
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    _initializePermissions();
    _checkInternetConnection();
    _serviceCategories = ServiceCategory.fetchServiceCategories();
    _loadStoreName();
    _loadName();
    _checkFirstLaunch();

    checkNetworkConnection();
    _bannersFuture = _loadBanners();
    _productsFuture = fetchProducts();
    // _loadStoreNumber();
    _fetchStoreSocials();
    getFcmTokenAndSetDetails();
    _fetchStoreProfile();
    _fetchBookings();
  }

  Future<void> _initializePermissions() async {
    // Request permissions and update state
    final permissions = await _requestNotificationPermissions();
    setState(() {
      _permissions = permissions;
    });
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
    // PermissionStatus cameraStatus = await Permission.camera.request();

    // if (cameraStatus.isGranted) {
    //   print('User granted permission for camera');
    //   permissionDetails.add({
    //     'permission': 'camera',
    //     'status': 'granted',
    //     'is_required': 'Yes' // Set "Yes" if the camera permission is required
    //   });
    // } else if (cameraStatus.isDenied) {
    //   print('User denied permission for camera');
    //   permissionDetails.add(
    //       {'permission': 'camera', 'status': 'denied', 'is_required': 'Yes'});
    // } else if (cameraStatus.isPermanentlyDenied) {
    //   print('User permanently denied permission for camera');
    //   permissionDetails.add({
    //     'permission': 'camera',
    //     'status': 'permanently_denied',
    //     'is_required': 'Yes'
    //   });
    //   // Optionally, you could guide the user to the app settings to enable the permission
    // }

    return permissionDetails;
  }

  Future<void> _fetchBookings() async {
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
        'offset': '0', // Static offset set to 0
      });

      // Print the request body for debugging
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/pending-bookings/'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Print the response body for debugging
      print('Response Body of upcoming: ${response.body}');

      // Parse the response and extract booking date and time
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'true' && responseData['data'] != null) {
        final bookingData = responseData['data']
            [0]; // Assuming you're handling the first booking

        final bookingDate = bookingData['booking_date']; // e.g., "27 Nov, 2024"
        final fromTime = bookingData['from']; // e.g., "11:45 AM"

        // Convert the date and time to a DateTime object
        final dateFormatter = DateFormat('d MMM, yyyy');
        final timeFormatter = DateFormat('h:mm a');

        final date = dateFormatter.parse(bookingDate);
        final time = timeFormatter.parse(fromTime);

        // Combine date and time into a DateTime object
        final appointmentTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Store the appointment time in SharedPreferences
        prefs.setString('appointment_time', appointmentTime.toIso8601String());

        print('Appointment Time: $appointmentTime');
      }
    } catch (e) {
      print('Error in _fetchBookings: $e');
    }
  }

  Future<void> getFcmTokenAndSetDetails() async {
    try {
      // Get the FCM token from FirebaseMessaging
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Save the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        print('Token saved to Shared Preferences: $token');

        // Call the method to set the FCM token on your backend server
        await _setFcmToken(token);

        // Call setLoggedInUserDetails with actual data (replace with real values)
      }
    } catch (e) {
      print('Error getting or saving FCM token: $e');
    }
  }

  Future<void> _setFcmToken(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    final String url = '${MyApp.apiUrl}customer/set-fcm-token';
    final Map<String, dynamic> requestBody = {
      'customer_id': customerId,
      'salon_id': salonID,
      'branch_id': branchID,
      'fcm_token': fcmToken,
    };
    print('Sending request to $url');
    print('Request body: ${jsonEncode(requestBody)}');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        print('FCM token sent successfully: ${response.body}');
      } else {
        print(
            'Failed to send FCM token: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token: $e');
    }
  }

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

  // Show SnackBar when there's no internet

  Future<void> _fetchStoreProfile() async {
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
            _storeNumber = responseData['data']['phone_number'] ?? '';
          });
        } else {
          print("Error: ${responseData['message']}");
        }
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error occurred: $error");
    }
  }

  Future<void> _fetchStoreSocials() async {
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

      // Send POST request to store socials endpoint
      final response = await http.post(
        Uri.parse("${MyApp.apiUrl}customer/store-socials/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Debugging output
      print("Response status: ${response.statusCode}");
      print("Response body of store socials: ${response.body}");

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Check the response status as a string
        if (responseData['status'] == "true") {
          // Set values to global variables
          setState(() {
            _instagramLink = responseData['data']['instagram_link'] ?? '';
            _facebookLink = responseData['data']['facebook_link'] ?? '';
            _youtubeLink = responseData['data']['youtube_link'] ?? '';
            _websiteLink = responseData['data']['website_link'] ?? '';
          });

          // Debugging output to confirm values are set
          print("Instagram Link: $_instagramLink");
          print("Facebook Link: $_facebookLink");
          print("YouTube Link: $_youtubeLink");
          print("Website Link: $_websiteLink");
        } else {
          print("Error: ${responseData['message']}");
        }
      } else {
        print(
            "Failed to load social data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error occurred: $error");
    }
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

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch == null || isFirstLaunch) {
      // Navigate to the onboarding or welcome page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage2(
                  title: '',
                )), // Replace with your welcome page
      );

      // Set the isFirstLaunch to false after navigating
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  Future<void> checkNetworkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showSnackbar("No internet connection");
    }
  }

  void showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<List<String>> _loadBanners() async {
    final errorLogger = ErrorLogger(); // Initialize your error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Fetch the banner images
      return await fetchBannerImages(salonID, branchID);
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Log branch and salon IDs if error occurs
      await errorLogger.setBranchId(branchID);
      await errorLogger.setSalonId(salonID);

      // Log the error with stack trace
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> _loadBanners",
        userId: "Unknown User", // Replace with actual user ID if available
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print error details for debugging
      print('Error occurred in _loadBanners: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception if needed
      throw Exception('Failed to load banners: $e');
    }
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 3)) {
      // First back press
      _lastBackPressTime = now;

      // Show the customized SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/napito.jpg', // Replace with your image asset path
                    width: 24.0,
                    height: 24.0,
                  ),
                  const SizedBox(width: 8.0), // Space between image and text
                  const Text(
                    'Press "BACK" again to exit.',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 2),
        ),
      );

      return false; // Prevent exiting by default
    } else {
      // Exit on the second back press within 3 seconds
      SystemNavigator.pop();
      return true;
    }
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('store_name') ?? 'Default Store Name';
    setState(() {
      _storeName = storedName;
    });
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('full_name') ?? 'Default Store Name';
    setState(() {
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: true,
          title: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width *
                    0.02), // Adjust horizontal padding based on screen width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0), // Ensure no extra left padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Align items to the start (left)
                      children: [
                        Text(
                          _storeName, // Store name
                          style: GoogleFonts.lato(
                            fontSize: 22, // Font size
                            fontWeight: FontWeight.w800, // Font weight
                            height: 1.2, // Line height
                            letterSpacing: 0.02, // Letter spacing
                            color: Color(0xFF1D2024), // Hex color for #1D2024
                          ),
                          textAlign: TextAlign.center, // Added text alignment
                        ),
                      ],
                    ),
                  ),
                ),

                // Wrap icon row in Flexible to handle overflow
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // QR Code Button
                      GestureDetector(
                        onTap: _isConnected
                            ? () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrCodeHomePage()),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No internet connection'),
                                    backgroundColor:
                                        Colors.red, // Red background
                                  ),
                                );
                              }, // Show SnackBar if no internet
                        child: Container(
                          width: 25,
                          height: 25,
                          child: SvgPicture.asset(
                            'assets/scanner11.svg', // Replace with your SVG file path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Notification Button
                      GestureDetector(
                        onTap: _isConnected
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NotificationPage()),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No internet connection'),
                                    backgroundColor:
                                        Colors.red, // Red background
                                  ),
                                );
                              }, // Show SnackBar if no internet
                        child: Container(
                          width: 25,
                          height: 25,
                          child: SvgPicture.asset(
                            'assets/notif.svg', // Replace with your SVG file path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // SOS Button
                      GestureDetector(
                        onTap: _isConnected
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SosPage()),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No internet connection'),
                                    backgroundColor:
                                        Colors.red, // Red background
                                  ),
                                );
                              }, // Show SnackBar if no internet
                        child: Container(
                          width: 25,
                          height: 25,
                          child: SvgPicture.asset(
                            'assets/exclamation.svg', // Replace with your SVG file path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: CustomColors.backgroundLight,
        // drawer: SidebarDrawer(),
        drawer: _isConnected ? SidebarDrawer() : null,
        body: Center(
            child: _isConnected
                ? Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              color: const Color(0xFFFAFAFA),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: _refreshData,
                                      child: ListView(
                                        padding: EdgeInsets.zero,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            height: 150,
                                            child: BannerSection(
                                              // pageController: _pageController,
                                              bannersFuture: _bannersFuture,
                                              // onPageChanged: (index) {
                                              //   setState(() {
                                              //     _currentPage = index;
                                              //   });
                                              // },
                                              // currentPage: _currentPage,
                                            ),
                                          ),

// Add the text below the banner
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Hi $_name',
                                                  style: GoogleFonts.lato(
                                                    // Use Google Fonts Lato here
                                                    fontSize: 20, // Font size
                                                    fontWeight: FontWeight
                                                        .w700, // Font weight
                                                    height: 1.2, // Line height
                                                    color: Color(
                                                        0xFF1D2024), // Hex color for #1D2024
                                                  ),
                                                ),
                                                Text(
                                                  DateTime.now().hour < 12
                                                      ? 'Good morning'
                                                      : DateTime.now().hour < 17
                                                          ? 'Good afternoon'
                                                          : 'Good evening',
                                                  style: GoogleFonts.lato(
                                                    fontSize: 12, // Font size
                                                    fontWeight: FontWeight
                                                        .w600, // Font weight
                                                    height: 1.2, // Line height
                                                    color: Color(
                                                        0xFF424752), // Hex color for #424752
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Container(
                                                  height: 90,
                                                  child: FutureBuilder<
                                                      List<ServiceCategory>>(
                                                    future:
                                                        _serviceCategories, // Use the cached future
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        // Show shimmer while loading
                                                        return Shimmer
                                                            .fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child:
                                                              ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemCount:
                                                                3, // Number of placeholder items
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                margin: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                width: 100,
                                                                color: Colors
                                                                    .white,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Center(
                                                            child: Text(
                                                                'Error: ${snapshot.error}'));
                                                      } else if (!snapshot
                                                              .hasData ||
                                                          snapshot
                                                              .data!.isEmpty) {
                                                        return const Center(
                                                            child: Text(
                                                                'No services available'));
                                                      } else {
                                                        // Create a ScrollController to control the scroll position
                                                        ScrollController
                                                            _scrollController =
                                                            ScrollController();

                                                        // Function to automatically scroll every 2 seconds
                                                        Timer.periodic(
                                                            const Duration(
                                                                seconds: 2),
                                                            (timer) {
                                                          if (_scrollController
                                                              .hasClients) {
                                                            // Check if we've reached the end of the list
                                                            if (_scrollController
                                                                    .offset >=
                                                                _scrollController
                                                                    .position
                                                                    .maxScrollExtent) {
                                                              // Scroll back to the start if at the end
                                                              _scrollController
                                                                  .animateTo(
                                                                0,
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                curve: Curves
                                                                    .easeInOut,
                                                              );
                                                            } else {
                                                              // Scroll right by a fixed amount
                                                              _scrollController
                                                                  .animateTo(
                                                                _scrollController
                                                                        .offset +
                                                                    100, // Adjust the scroll distance
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                curve: Curves
                                                                    .easeInOut,
                                                              );
                                                            }
                                                          }
                                                        });

                                                        return ListView.builder(
                                                          controller:
                                                              _scrollController,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemCount: snapshot
                                                              .data!.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final category =
                                                                snapshot.data![
                                                                    index];
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child:
                                                                  _buildHairItem(
                                                                category
                                                                    .imageUrl,
                                                                category.name,
                                                                () => Navigator
                                                                    .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ServiceDetailPage(
                                                                      categoryId:
                                                                          category
                                                                              .id,
                                                                      categoryName:
                                                                          category
                                                                              .name,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // const SizedBox(height: 2),
                                          Container(
                                            width: double.infinity,
                                            height: 1,
                                            color: const Color(0xFFD3D6DA),
                                          ),
                                          const SizedBox(
                                              height:
                                                  20), // Adjust spacing as needed
                                          Column(
                                            children: [
                                              // First Row
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _buildRectangleContainer(
                                                    'Gallery',
                                                    'assets/hairstyleanimation.gif',
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              HairstylesPage(),
                                                        ),
                                                      );
                                                      print(
                                                          'Hairstyle container tapped');
                                                    },
                                                  ),
                                                  _buildRectangleContainer(
                                                    'Book Appointment',
                                                    'assets/bookaapp.png',
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BookAppointmentPage(),
                                                        ),
                                                      );
                                                      print(
                                                          'Book Appointment container tapped');
                                                    },
                                                  ),
                                                  _buildRectangleContainer(
                                                    'Packages', // Placeholder for the new item
                                                    'assets/package.png', // Replace with your actual image path
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerPackages1(),
                                                        ),
                                                      );
                                                      print(
                                                          'New Item 1 container tapped');
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                      20), // Adjust spacing as needed
                                              // Second Row
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _buildRectangleContainer(
                                                    'My Booking',
                                                    'assets/mybook.png',
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UpcomingPage(),
                                                        ),
                                                      );
                                                      print(
                                                          'My Booking container tapped');
                                                    },
                                                  ),
                                                  _buildRectangleContainer(
                                                    'Offers',
                                                    'assets/giftshome.gif',
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Offers(),
                                                        ),
                                                      );
                                                      print(
                                                          'Offers container tapped');
                                                    },
                                                  ),
                                                  _buildRectangleContainer(
                                                    'Membership', // Placeholder for the new item
                                                    'assets/member.png', // Replace with your actual image path
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Membership(),
                                                        ),
                                                      );
                                                      print(
                                                          'New Item 2 container tapped');
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                      10), // Adjust spacing as needed
                                            ],
                                          ),
                                          // Grey line height adjustment
                                          Container(
                                            height: 1,
                                            color: const Color(
                                                0xFFD3D6DA), // Grey line color
                                          ),
                                          // Text container for 'Product'
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: Text(
                                              'Product',
                                              textAlign: TextAlign
                                                  .start, // Keep the alignment as start
                                              style: GoogleFonts.lato(
                                                // Use Google Fonts Lato here
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                height:
                                                    1.2, // This corresponds to a line height of 21.6px assuming 18px font size
                                                color: const Color(
                                                    0xFF1D2024), // Updated color to match #1D2024
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          // Horizontal scrolling for product containers
                                          Container(
                                            height: 210,
                                            child:
                                                FutureBuilder<List<Products>>(
                                              future:
                                                  _productsFuture, // Use the cached future
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // Show shimmer while loading
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      itemCount:
                                                          3, // Number of placeholder items
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          width: 120,
                                                          color: Colors.white,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'));
                                                } else if (!snapshot.hasData ||
                                                    snapshot.data!.isEmpty) {
                                                  return const Center(
                                                      child: Text(
                                                          'No products found'));
                                                } else {
                                                  // Build your actual product list
                                                  return ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final product =
                                                          snapshot.data![index];
                                                      return _buildProductContainer(
                                                        product.name,
                                                        product.image,
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: Text(
                                              // Remove const to allow GoogleFonts
                                              'Health Tips',
                                              textAlign: TextAlign
                                                  .start, // Keep the alignment as start
                                              style: GoogleFonts.lato(
                                                // Use Google Fonts Lato here
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                height:
                                                    1.2, // This corresponds to a line height of 21.6px assuming 18px font size
                                                color: const Color(
                                                    0xFF1D2024), // Updated color to match #1D2024
                                              ),
                                            ),
                                          ),
                                          // Horizontal scrolling for health tips
                                          FutureBuilder<TipModel>(
                                            future: TipModel
                                                .fetchTips(), // Fetch tips from the API
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                // Show shimmer while loading
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    height:
                                                        210, // Adjust height as needed
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      itemCount:
                                                          3, // Number of placeholder items
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 10),
                                                          child: Container(
                                                            width:
                                                                150, // Adjust width as needed
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Error: ${snapshot.error}'));
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.data.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        'No tips available.'));
                                              }
                                              final tips = snapshot.data!.data;
                                              return Container(
                                                height:
                                                    210, // Adjust height as needed
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  itemCount: tips.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final tip = tips[index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                TipDetailPage(
                                                                    tip: tip),
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child:
                                                            _buildHealthContainer(
                                                          Colors
                                                              .white, // Adjust color if needed
                                                          tip.title,
                                                          tip.bannerImage,
                                                          [
                                                            const LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Color(
                                                                    0x00F5F5F5),
                                                                Color(
                                                                    0x2E033B89),
                                                                Color(
                                                                    0x2E033B89),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 30),
                                          Container(
                                            // Remove the fixed height
                                            child:
                                                FutureBuilder<FacilityResponse>(
                                              future:
                                                  apiService.fetchFacilities(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // Show shimmer while loading
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: ListView.builder(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      itemCount:
                                                          5, // Number of placeholder items
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10),
                                                          height:
                                                              120, // Adjust height as needed
                                                          color: Colors.white,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'));
                                                } else if (snapshot.hasData) {
                                                  // Calculate height based on data length
                                                  final itemCount = snapshot
                                                      .data!.data.length;

                                                  return ListView(
                                                    shrinkWrap:
                                                        true, // Make ListView take only the necessary height
                                                    physics:
                                                        const NeverScrollableScrollPhysics(), // Disable scrolling
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    children: [
                                                      _buildFacilitiesContainer(
                                                        const Color(0xFFEEF2FE),
                                                        'Facilities',
                                                        snapshot.data!.data,
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return const Center(
                                                      child: Text(
                                                          'No data found'));
                                                }
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 20),
                                          // Container(
                                          //   padding: const EdgeInsets.all(16.0),
                                          //   // decoration: BoxDecoration(
                                          //   //   border: Border.all(
                                          //   //       color: Colors.blue, width: 2.0),
                                          //   //   borderRadius: BorderRadius.circular(12.0),
                                          //   // ),
                                          //   child: Row(
                                          //     crossAxisAlignment:
                                          //         CrossAxisAlignment.center,
                                          //     children: [
                                          //       // Image
                                          //       Image.asset('assets/refer2.png',
                                          //           width: 236,
                                          //           height:
                                          //               181), // Adjust width and height as needed

                                          //       // Spacer
                                          //       const SizedBox(width: 16.0),

                                          //       // Column for Text and Button
                                          //       Column(
                                          //         crossAxisAlignment:
                                          //             CrossAxisAlignment.start,
                                          //         children: [
                                          //           // Text: Refer and Earn
                                          //           const Text(
                                          //             'Refer & Earn',
                                          //             style: TextStyle(
                                          //               fontFamily: 'Lato',
                                          //               fontSize: 24.0,
                                          //               fontWeight: FontWeight.w600,
                                          //               color: Color(
                                          //                   0xFF1D2024), // Assuming #424752 is too dark for black text
                                          //               height:
                                          //                   1.2, // Line height in Flutter adjusts with height factor
                                          //             ),
                                          //           ),

                                          //           const Text(
                                          //             'Lorem ipsum dummy text',
                                          //             style: TextStyle(
                                          //               fontFamily: 'Lato',
                                          //               fontSize: 10.0,
                                          //               fontWeight: FontWeight.w500,
                                          //               color: Color(
                                          //                   0xFF424752), // Using #424752 color
                                          //               height:
                                          //                   1.2, // Line height in Flutter adjusts with height factor
                                          //             ),
                                          //           ),

                                          //           // Spacer
                                          //           const SizedBox(height: 8.0),

                                          //           // Blue Button
                                          //           ElevatedButton(
                                          //             onPressed: () {
                                          //               // Add your button logic here
                                          //             },
                                          //             style: ElevatedButton.styleFrom(
                                          //               backgroundColor:
                                          //                   const CustomColors.backgroundtext,
                                          //               padding:
                                          //                   const EdgeInsets.symmetric(
                                          //                       vertical: 12.0,
                                          //                       horizontal: 24.0),
                                          //               shape: RoundedRectangleBorder(
                                          //                 borderRadius:
                                          //                     BorderRadius.circular(
                                          //                         4.0),
                                          //               ),
                                          //             ),
                                          //             child: const Text(
                                          //               'Read More',
                                          //               style: TextStyle(
                                          //                 fontSize: 16.0,
                                          //                 color: Colors.white,
                                          //               ),
                                          //             ),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          Container(
                                            width: 430,
                                            decoration: BoxDecoration(
                                              color:
                                                  CustomColors.backgroundtext,
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 10),
                                                // Create a list of available icons
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center, // Center the row
                                                  children: [
                                                    // Use _buildIcon method for each icon and URL
                                                    _buildIcon(
                                                        'assets/instagram.svg',
                                                        _instagramLink),
                                                    _buildIcon(
                                                        'assets/facebook1.svg',
                                                        _facebookLink),
                                                    _buildIcon(
                                                        'assets/whatsapp.svg',
                                                        _youtubeLink), // Example for YouTube link
                                                    _buildIcon(
                                                        'assets/email.svg',
                                                        _websiteLink),
                                                  ],
                                                ),
                                                const SizedBox(height: 30.0),

                                                // Wrap the contact number in a GestureDetector or InkWell
                                                GestureDetector(
                                                  onTap: () {
                                                    _launchPhoneNumber(
                                                        '$_storeNumber'); // Call the phone number when clicked
                                                  },
                                                  child: Text(
                                                    'Contact Us | $_storeNumber',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      height: 1.21,
                                                      letterSpacing: 0.02,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(height: 30.0),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 82,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                                width: 1.0,
                                color: Colors.grey[
                                    300]!), // Adjust color and width as needed
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildButton(
                                context, '/home', 'Home', 'assets/hut.svg'),
                            _buildButton(context, '/book_appointment',
                                'Book Appointment', 'assets/check-mark.svg'),
                            _buildButton(context, '/upcomingbooking',
                                'My Bookings', 'assets/schedule3.svg'),
                            _buildButton(context, '/saloon_details_page',
                                'Salon Details', 'assets/store.svg'),
                            _buildButton(context, '/profile', 'Profile',
                                'assets/user2.svg'),
                          ],
                        ),
                      )
                    ],
                  )
                : Padding(
                    padding:
                        EdgeInsets.all(20), // Optional padding around image
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
                        SizedBox(
                            height: 20), // Add space between image and button
                        // Retry Button
                        ElevatedButton(
                          onPressed: () async {
                            await _checkInternetConnection(); // Retry the internet connection check
                            if (_isConnected) {
                              Navigator.pushReplacementNamed(
                                  context, '/home'); // Navigate to homepage
                            }
                          },
                          child: Text('Retry',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor: CustomColors.backgroundtext,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)), // Button color
                          ),
                        ),
                      ],
                    ),
                  )),
      ),
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

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

// Widget to build an icon with a URL
  Widget _buildIcon(String assetPath, String url) {
    return url.isNotEmpty
        ? GestureDetector(
            onTap: () => _launchURL(url),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal:
                      5.5), // 5 px gap between icons (2.5 px on each side)
              child: Container(
                width: 50.0, // Diameter of the circle
                height: 50.0, // Diameter of the circle
                decoration: BoxDecoration(
                  color: Colors.white, // Circle color
                  shape: BoxShape.circle, // Make it circular
                ),
                child: Center(
                  child: SvgPicture.asset(
                    assetPath,
                    width: 30.0, // Adjust icon size
                    height: 30.0, // Adjust icon size
                    color: CustomColors.backgroundtext, // Blue icon color
                  ),
                ),
              ),
            ),
          )
        : SizedBox.shrink(); // Hide if URL is empty
  }

  Widget _buildHairItem(String imagePath, String name, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Show a scissors icon if the image fails to load
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200], // Background color
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.cut,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name.split(' ').length > 2 ? '${name.split(' ').first}...' : name,
              style: GoogleFonts.lato(
                fontSize: 12, // 12px font size
                fontWeight: FontWeight.w500, // Font weight 500
                height: 1.2, // Line height 14.4px (12 * 1.2)
                letterSpacing: 0.02, // Letter spacing 0.02em
                color: const Color(0xFF3B4453), // Hex color #3B4453
                // textAlign: TextAlign.center, // Text align center
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildButton(
    BuildContext context, String routeName, String label, String svgPath) {
  bool isCurrentPage = ModalRoute.of(context)?.settings.name == routeName;

  // If the route is 'home', force the icon color to black
  Color? iconColor = routeName == '/home'
      ? CustomColors.backgroundtext
      : (isCurrentPage ? CustomColors.backgroundtext : null);

  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, routeName);
    },
    borderRadius: BorderRadius.circular(8.0),
    splashColor: CustomColors.backgroundtext,
    highlightColor: CustomColors.backgroundtext,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 24,
            height: 24,
            color: iconColor, // Set the color to the new iconColor variable
          ),
          const SizedBox(height: 4), // Space between icon and text
          Text(
            label,
            style: GoogleFonts.lato(
              // Use Google Fonts Lato here
              fontSize: 10, // Font size
              fontWeight: FontWeight.w500,
              color: isCurrentPage ? CustomColors.backgroundtext : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildRectangleContainer(
    String text, String imagePath, VoidCallback onPressed) {
  return Column(
    children: [
      InkWell(
        onTap: onPressed, // Call the onPressed callback when tapped
        child: Container(
          width: 110,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEDED), // Grey background color
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5, // Adjust top positioning as needed
                left: 0,
                right: 0,
                child: Center(
                  child: imagePath.endsWith('.gif') ||
                          imagePath.endsWith('.jpg') ||
                          imagePath.endsWith('.png')
                      ? Image.asset(
                          imagePath,
                          width: 70, // Increased width
                          height: 70, // Increased height
                          fit: BoxFit.cover,
                        )
                      : SvgPicture.asset(
                          imagePath,
                          width: 70, // Increased width
                          height: 70, // Increased height
                          // ignore: deprecated_member_use
                          color: const Color(
                              0xFF353B43), // Change color to #353B43 for SVG
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8), // Adjust spacing between container and text
      Text(
        text,
        style: GoogleFonts.lato(
          // Use Google Fonts Lato here
          fontSize: 12, // 12px font size
          fontWeight: FontWeight.w600, // Font weight 600
          height: 1.2, // Line height 14.4px (12 * 1.2)
          color: const Color(0xFF424752), // Hex color #424752
        ),
        textAlign: TextAlign.center, // Text align center
      ),
      const SizedBox(height: 10), // Optional additional spacing
    ],
  );
}

Widget _buildProductContainer(String name, String imageUrl) {
  // Create a random number generator
  final Random random = Random();

  // Generate a random number between 0 and 1
  final int gradientType = random.nextInt(2); // This will give either 0 or 1

  // Define the gradients based on the random number
  List<Gradient> gradients = [
    const LinearGradient(
      colors: [
        Color.fromRGBO(0, 86, 208, 0.17), // rgba(0, 86, 208, 0.17)
        Color.fromRGBO(245, 245, 245, 0), // rgba(245, 245, 245, 0)
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    const LinearGradient(
      colors: [
        Color.fromRGBO(0, 86, 208, 0.17), // rgba(0, 86, 208, 0.17)
        Color.fromRGBO(245, 245, 245, 0), // rgba(245, 245, 245, 0)
        // Color.fromRGBO(232, 180, 42, 0.17), // rgba(232, 180, 42, 0.17)
        // Color.fromRGBO(245, 245, 245, 0), // rgba(245, 245, 245, 0)
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  return Container(
    width: 150, // Adjust width as needed
    margin: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.transparent, // Transparent border
        width: 1, // Border width
      ),
    ),
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center, // Center the text horizontally
              child: Text(
                name,
                textAlign:
                    TextAlign.center, // Center the text within the container
                style: GoogleFonts.lato(
                  // Use Google Fonts Lato here
                  fontSize: 12, // Font size as specified
                  fontWeight: FontWeight.w700, // Font weight as specified
                  height: 1.2, // Line height equivalent to 14.4px
                  color: const Color(
                      0xFF424752), // Changed to the specified hex color
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double
                      .infinity, // Ensure the image covers the container width
                ),
              ),
            ),
          ],
        ),
        // Use the randomly selected gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: gradients[
                  gradientType], // Choose gradient based on random number
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildHealthContainer(
    Color color, String text, String gifPath, List<LinearGradient> gradients) {
  return Container(
    width: 368,
    height: 246,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color,
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              gifPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: gradients.isNotEmpty ? gradients[0] : null,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              // Use Google Fonts Lato here
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFacilitiesContainer(
  Color color,
  String text,
  List<FacilityModel> facilities,
) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color,
    ),
    child: Column(
      mainAxisSize: MainAxisSize
          .min, // Ensures the container sizes itself based on content
      children: [
        // Text layer
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 16, top: 16),
          child: Text(
            text,
            textAlign: TextAlign.left, // Left alignment
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: const Color(0xFF1D2024), // Text color
            ),
          ),
        ),
        // Facilities list
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: facilities
                .map((facility) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildFacilityWithImage(
                          facility.title, facility.icon),
                    ))
                .toList(),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFacilityWithImage(String facilityName, String imagePath) {
  // Removed truncation logic to show full name
  String getFullName(String name) {
    return name; // Simply return the full name without truncation
  }

  return Row(
    children: [
      // Image container
      Container(
        width: 20,
        height: 20,
        child: Image.network(
          imagePath,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.error, color: Colors.red)),
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      const SizedBox(width: 10),
      // Full Facility Name without truncation
      Expanded(
        child: Text(
          getFullName(facilityName),
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Color(0xFF1D2024),
          ),
          maxLines: null, // Allow unlimited lines
          overflow:
              TextOverflow.visible, // Make sure the text can overflow if needed
        ),
      ),
    ],
  );
}

Widget _buildIcon(String assetPath) {
  return Container(
    width: 40.0,
    height: 40.0,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
    ),
    child: Center(
      child: SvgPicture.asset(
        assetPath,
        width: 24.0,
        height: 24.0,
        color: CustomColors.backgroundtext, // Icon color (blue)
      ),
    ),
  );
}
