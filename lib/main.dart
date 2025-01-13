import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Book_appointment/select_package.dart';
import 'package:ms_salon_task/Book_appointment/select_package_details.dart';
import 'package:ms_salon_task/Booking%20Details/bookingdetailspending.dart';
import 'package:ms_salon_task/Hairstyles/hairstyles.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/My_Bookings/CancelledPage.dart';
import 'package:ms_salon_task/My_Bookings/cancel_booking.dart';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:ms_salon_task/My_Bookings/select_data_time.dart';
import 'package:ms_salon_task/Payment/payment.dart';
import 'package:ms_salon_task/Payment/review_summary.dart';
import 'package:ms_salon_task/Profile/about.dart';
import 'package:ms_salon_task/Profile/edit_profile.dart';
import 'package:ms_salon_task/Profile/edit_profile_update.dart';
import 'package:ms_salon_task/Profile/invite_friends.dart';
import 'package:ms_salon_task/Profile/notification.dart';
import 'package:ms_salon_task/Profile/privacy.dart';
import 'package:ms_salon_task/Profile/profile.dart';
import 'package:ms_salon_task/Raise_Ticket/sos.dart';
import 'package:ms_salon_task/Raise_Ticket/ticket_details.dart';
import 'package:ms_salon_task/Raise_Ticket/your_tickets.dart';
import 'package:ms_salon_task/Onboarding_Screen/onboardingscreen3.dart';
import 'package:ms_salon_task/Saloon_Details_page/saloon_details_page.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';
import 'package:ms_salon_task/Scanner/scan_details.dart';
import 'package:ms_salon_task/Scanner/scanner.dart';
import 'package:ms_salon_task/SignUp/SignUpOTPPage.dart';
import 'package:ms_salon_task/SignUp/SignUpPage.dart';
import 'package:ms_salon_task/Store_Selection/store_selection.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/intcheck.dart';
import 'package:ms_salon_task/offers%20and%20membership/membership.dart';
import 'package:ms_salon_task/offers%20and%20membership/offers.dart';
import 'package:ms_salon_task/services/color_service.dart';
import 'package:ms_salon_task/services/facial_service.dart';
import 'package:ms_salon_task/services/haircut_service.dart';
import 'package:ms_salon_task/services/keratin_service.dart';
import 'package:ms_salon_task/services/selected_services.dart';
import 'package:ms_salon_task/services/spa_service.dart';
import 'package:ms_salon_task/services/special_services.dart';
import 'package:ms_salon_task/shoecaseexp.dart';
import 'SignUp/signup2.dart';
import 'Splashscreen/splashscreen.dart';
import 'Onboarding_Screen/onboardingscreen1.dart';
import 'Onboarding_Screen/onboardingscreen2.dart';
import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

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
  final String url = "https://napit.in/set_logged_in_user";

  // Get device details dynamically
  Map<String, dynamic> deviceDetails = await getDeviceDetails();

  // Retrieve mobile number from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String mobileNo = prefs.getString('mobileNumber') ?? '';

  // Retrieve user ID from shared preferences
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    String? token = await FirebaseMessaging.instance.getAPNSToken();
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('Token saved to Shared Preferences: $token');
      await _setFcmToken(token);
      // Call setLoggedInUserDetails here
      await setLoggedInUserDetails(
          'username', // Replace with actual username
          'userId', // Replace with actual user ID
          [] // Replace with actual permission details if needed
          );
    }
  } catch (e) {
    print('Error getting or saving FCM token: $e');
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Initialize notifications
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');
  final DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS, // Added iOS initialization
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final String? payload = response.payload;
      if (payload != null) {
        print('Notification response payload: $payload');
        _handleNotificationClick(payload);
      }
    },
  );

  // Create notification channel
  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showNotification(message, flutterLocalNotificationsPlugin);
  });

  // Handle background and terminated messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle notification tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final payload = jsonEncode(message.data);
    print('Notification opened with payload: $payload');
    _handleNotificationClick(payload);
  });

  // Print FCM token
  runApp(const MyApp());
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



  return permissionDetails;
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@drawable/ic_notification',
        ),
      ),
    );
  }
}

void _showNotification(RemoteMessage message,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  final errorLogger = ErrorLogger();
  try {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: null,
    );

    // Use a unique notification ID if needed
    await flutterLocalNotificationsPlugin.show(
      message.hashCode, // Use message.hashCode or another unique identifier
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  } catch (e, stackTrace) {
    final payload =
        jsonEncode(message.data); // Get the payload from the message data

    await errorLogger.setUserId(payload);

    await errorLogger.logError(
      errorMessage: e.toString(),
      errorLocation: "API's -> storefiledetailsInFirestore",
      userId: "",
      receiverId: "",
      // errorDetails: {"request": "fetchData", "responseCode": 500},
      stackTrace: stackTrace,
    );
    print("Error storing file details in Firestore: $e");
    print('Error showing notification: $e');
  }
}

void _handleNotificationClick(String payload) async {
  print('Notification clicked with payload: $payload');

  try {
    final Map<String, dynamic> data = jsonDecode(payload);
    print('Parsed data: $data');

    final String landingPage = data['landing_page']?.toLowerCase() ?? '';
    print('Landing page: $landingPage');

    final String redirectId = data['redirect_id'] ?? '';

    switch (landingPage) {
      case 'offers_list':
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => Offers()),
        );
        break;
      case 'cancelled_list':
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => CancelledPage()),
        );
        break;
      case 'booking_details':
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_booking_id', redirectId);

        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => BookingDetailsPendingPage()),
        );
        break;
      case 'query_details':
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_ticket_id', redirectId);

        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => TicketDetails()),
        );
        break;

      default:
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
        break;
    }
  } catch (e) {
    print('Error handling notification click: $e');
  }
}

class Config {
  static const String apiUrl = 'https://napito.in/phase-two/';
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  static const String apiUrl = 'https://napito.in/phase-two/';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Napito App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        // GetPage(name: '/', page: () => InternetCheckPage()),
        // GetPage(
        //     name: '/',
        //     page: () => HomePage2(
        //           title: '',
        //         )),
        GetPage(name: '/onboarding1', page: () => const OnboardingScreen1()),
        GetPage(name: '/onboarding2', page: () => const OnboardingScreen2()),
        GetPage(name: '/onboarding3', page: () => OnboardingScreen3()),
        GetPage(name: '/haircut_service', page: () => HaircutServicePage()),
        GetPage(name: '/facial_service', page: () => FacialServicePage()),
        GetPage(name: '/spa_service', page: () => SpaServicePage()),
        GetPage(name: '/keratin_service', page: () => KeratinServicePage()),
        GetPage(name: '/color_service', page: () => ColorServicePage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/edit_profile', page: () => EditProfilePage()),
        GetPage(name: '/book_appointment', page: () => BookAppointmentPage()),
        GetPage(name: '/select_package', page: () => SelectPackagePage()),
        GetPage(name: '/special_services', page: () => SpecialServicesPage()),
        GetPage(name: '/selected_services', page: () => SelectedServicesPage()),
        GetPage(name: '/sos', page: () => SosPage()),
        GetPage(name: '/your_tickets', page: () => YourTicketsPage()),
        GetPage(name: '/sign2', page: () => const SignUp2Page()),
        // GetPage(name: '/my_bookings_page', page: () => MyBookingsPage()),SignUp2Page
        GetPage(name: '/cancel_booking', page: () => CancelBooking()),
        GetPage(name: '/select_date_time', page: () => SelectDateTime()),
        GetPage(name: '/saloon_details_page', page: () => SaloonDetails()),
        GetPage(name: '/scanner', page: () => ScannerPage()),
        GetPage(name: '/pay', page: () => PaymentPage()),
        GetPage(name: '/scandetails', page: () => ScanDetailsPage()),
        GetPage(name: '/review_summary', page: () => ReviewSummary()),
        GetPage(name: '/notification', page: () => NotificationPage()),
        GetPage(name: '/privacy_policy', page: () => PrivacyPolicy()),
        GetPage(name: '/invite_friends', page: () => InviteFriends()),
        GetPage(name: '/about', page: () => About()),
        GetPage(name: '/payment', page: () => SelectDateTime()),
        GetPage(name: '/membership', page: () => Membership()),
        GetPage(name: '/offers', page: () => Offers()),
        GetPage(name: '/hairstyles', page: () => HairstylesPage()),
        GetPage(name: '/qr', page: () => QrCodePage()),
        GetPage(name: '/dt', page: () => SDateTime()),
        GetPage(name: '/signup', page: () => SignUpPage()),
        GetPage(name: '/upcomingbooking', page: () => UpcomingPage()),
        GetPage(name: '/signupotp', page: () => SignUpOTPPage()),
        GetPage(name: '/editprofileupdate', page: () => EditProfileUpdate()),
        GetPage(name: '/storeselection', page: () => StoreSelectionPage()),
        GetPage(
            name: '/select_package_details',
            page: () => SelectPackageDetailsPage()),
        GetPage(name: '/home', page: () => HomePage(title: 'MS SALOON')),
      ],
    );
    //tested
  }
}
