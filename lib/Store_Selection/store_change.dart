import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/SignUp/signup2.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

// Define the Store model
class Store {
  final String branchId;
  final String salonId;
  final String branchName;
  final String customerName;
  final String salonMobileNumber;
  final String storeLogo;
  final String address;
  final String customerId;
  final bool isProfileUpdate; // New parameter added

  Store({
    required this.branchId,
    required this.salonId,
    required this.branchName,
    required this.customerName,
    required this.salonMobileNumber,
    required this.storeLogo,
    required this.address,
    required this.customerId,
    required this.isProfileUpdate, // Initialize new parameter
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      branchId: json['branch_id'] ?? '',
      salonId: json['salon_id'] ?? '',
      branchName: json['branch_name'] ?? '',
      salonMobileNumber: json['salon_mobile_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      storeLogo: json['store_logo'] ?? '',
      address: json['address'] ?? '',
      customerId: json['customer_id'] ?? '',
      isProfileUpdate:
          json['is_profile_update'] ?? false, // Parse new parameter
    );
  }
}

// Define the StoreCard widget
class StoreCard extends StatelessWidget {
  final Store store;
  final bool isSelected;
  final VoidCallback onChanged;

  StoreCard({
    required this.store,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? CustomColors.backgroundtext : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(store.storeLogo),
            radius: 30,
          ),
          title: Text(
            store.branchName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Text(
                store.address,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontFamily: 'Lato',
                ),
              )

              // SizedBox(height: 6),
              // Text(
              //   store.salonMobileNumber,
              //   style: TextStyle(fontSize: 14, color: Colors.blueAccent),
              // ),
            ],
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              onChanged();
            },
            checkColor: Colors.white,
            activeColor: CustomColors.backgroundtext,
            side: BorderSide(color: CustomColors.backgroundtext, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// Define the StoreSelectionPage widget
class StoreSwitch extends StatefulWidget {
  @override
  _StoreSwitchState createState() => _StoreSwitchState();
}

class _StoreSwitchState extends State<StoreSwitch> {
  List<Store> stores = [];
  Store? selectedStore;
  String? mobileNumber;
  String? selectedStoreName;

  @override
  void initState() {
    super.initState();
    getStoredValues();
    _requestNotificationPermissions();
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

  Future<void> getStoredValues() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMobileNumber = prefs.getString('mobileNumber');
    final storedStoreName =
        prefs.getString('store_name'); // Retrieve store name

    setState(() {
      mobileNumber = storedMobileNumber;
      selectedStoreName = storedStoreName; // Set the retrieved store name
    });

    print('Stored Mobile Number: $storedMobileNumber');
    print('Stored Store Name: $storedStoreName');

    if (mobileNumber != null) {
      await fetchStores(); // Fetch stores only if mobileNumber is not null
    }
  }

  Future<void> fetchStores() async {
    if (mobileNumber == null) {
      return;
    }

    const url = '${MyApp.apiUrl}customer/stores-list/';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'mobile_number': mobileNumber}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        print('Response JSON: $responseData');

        if (responseData['status'] == 'true') {
          final data = responseData['data'] as List;
          if (data.isNotEmpty) {
            final firstStore = data[0];
            final prefs = await SharedPreferences.getInstance();

            await prefs.setString('branch_id', firstStore['branch_id'] ?? '');
            await prefs.setString('salon_id', firstStore['salon_id'] ?? '');

            // Set the store address and print it
            // final storeAddress =
            //     firstStore['address'] ?? 'No address Available';
            // await prefs.setString('store_address', storeAddress);
            // print('Stored Address: $storeAddress'); // Print the address here

            final customerId =
                int.tryParse(firstStore['customer_id'] ?? '0') ?? 0;
            await prefs.setString('customer_id', customerId.toString());

            setState(() {
              stores = data.map((json) => Store.fromJson(json)).toList();
            });
          } else {
            print('No stores found.');
            setState(() {
              stores = [];
            });
          }
        } else {
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void toggleSelection(Store store) async {
    setState(() {
      if (selectedStore == store) {
        selectedStore = null;
      } else {
        selectedStore = store;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    if (selectedStore != null) {
      await prefs.setString('branch_id', selectedStore!.branchId);
      await prefs.setString('salon_id', selectedStore!.salonId);
      await prefs.setString('customer_id',
          (int.tryParse(selectedStore!.customerId) ?? 0).toString());
      await prefs.setString(
          'store_name', selectedStore!.branchName); // Save store name
      await prefs.setString(
          'branch_mobile', selectedStore!.salonMobileNumber); // Save store name
    } else {
      await prefs.remove('store_name'); // Remove store name if no selection
    }
  }

  void handleSubmit() async {
    if (selectedStore != null) {
      final prefs = await SharedPreferences.getInstance();

      // Save selected store details
      await prefs.setString('store_address', selectedStore!.address);
      await prefs.setString('branch_id', selectedStore!.branchId);
      await prefs.setString('salon_id', selectedStore!.salonId);
      await prefs.setString('customer_id',
          (int.tryParse(selectedStore!.customerId) ?? 0).toString());
      await prefs.setString('store_name', selectedStore!.branchName);
      await prefs.setString('branch_mobile', selectedStore!.salonMobileNumber);
      await prefs.setString('full_name', selectedStore!.customerName);

      // Indicate that a store has been selected
      await prefs.setString('is_store_selected', '3'); // Storing string value

      // Print selected store details
      print('Selected Store Details:');
      print('Branch ID: ${selectedStore!.branchId}');
      print('Salon ID: ${selectedStore!.salonId}');
      print('Customer ID: ${selectedStore!.customerId}');
      print('Store Name: ${selectedStore!.branchName}');
      print('Branch Mobile: ${selectedStore!.salonMobileNumber}');
      print('Full Name: ${selectedStore!.customerName}');
      print('address ${selectedStore!.address}');

      // Request notification permissions and print results
      List<Map<String, dynamic>> permissionDetails =
          await _requestNotificationPermissions();

      print('Notification Permission Details:');
      print(permissionDetails);

      // Call the second function to store user data or any other operation
      await setLoggedInUserDetails(
        'username', // Replace with actual username
        'userId', // Replace with actual user ID
        permissionDetails, // Replace with actual permission details if needed
      );

      // Print confirmation of user details being set
      print('User details set for username: username, userId: userId');

      // Print the value of isProfileUpdate
      print('isProfileUpdate: ${selectedStore?.isProfileUpdate ?? false}');

      // Navigate based on profile update status
      if (selectedStore?.isProfileUpdate ?? false) {
        // Navigate to Signup2Page if profile update is true
        print('$selectedStore?.isProfileUpdate profile update');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUp2Page()),
        );
      } else {
        // Navigate to HomePage if profile update is false
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(title: '')),
        );
      }
    } else {
      // Show error if no store is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a store before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Selection'),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Column(
        children: [
          if (selectedStoreName != null) // Display store name if it exists
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CustomColors.backgroundtext,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Previously Selected Saloon: $selectedStoreName',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.backgroundtext,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: stores.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return StoreCard(
                          store: store,
                          isSelected: selectedStore == store,
                          onChanged: () => toggleSelection(store),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: selectedStore != null ? handleSubmit : null,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: CustomColors.backgroundtext,
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 35),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Define the HomePage widget (Placeholder)

// Function to store phone number in SharedPreferences (example usage)
void storePhoneNumber(String phoneNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('mobileNumber', phoneNumber);
}
