import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Profile/edit_profile_update.dart';
import 'package:ms_salon_task/Profile/profile.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String customerID = '';
  String branchID = '';
  String salonID = '';
  String fullName = '';
  String dateOfBirth = '';
  String dateOfAnniversary = '';
  String gender = '';
  String profilePicUrl = '';
  String mobileNumber = '';

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
    if (customerID2.isNotEmpty && customerID2 != customerID) {
      print('Using customer_id2: $customerID2');
      // Use customerID2 instead of customerID
      fetchProfileDetails(customerID2);
    } else {
      fetchProfileDetails(customerID);
    }
  }

  Future<void> fetchProfileDetails(String customerID) async {
    // Retrieve customer ID, branch ID, and salon ID
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');

    final String customerId = customerId1?.isNotEmpty == true
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

          // Save the full name to SharedPreferences
          await _saveFullNameToPreferences(fullName);
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

  Future<void> _saveFullNameToPreferences(String fullName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('full_name', fullName);
  }

  Future<void> _refreshProfileDetails() async {
    await fetchDataFromPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );

        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              Text(
                'Edit Profile',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2024),
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshProfileDetails,
          child: Container(
            color: CustomColors.backgroundPrimary,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 430,
                    height: 116,
                    color: Colors.blue.withOpacity(0),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  left: MediaQuery.of(context).size.width * 0.35,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width * 0.3,
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
                              cacheWidth: 183,
                              cacheHeight: 183,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Icon(
                                    Icons.account_circle,
                                    size:
                                        MediaQuery.of(context).size.width * 0.3,
                                    color: Colors.grey,
                                  );
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.account_circle,
                                  size: MediaQuery.of(context).size.width * 0.3,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : Icon(
                              Icons.account_circle,
                              size: MediaQuery.of(context).size.width * 0.3,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: MediaQuery.of(context).size.width * 0.31,
                  child: Container(
                    width: 138,
                    height: 28,
                    child: Center(
                      child: Text(
                        fullName,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: 0.02,
                          color: Color(0xFF1D2024),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 29,
                  child: Container(
                    width: 372.01,
                    height: 0,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFD3D6DA),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 220,
                  left: 47,
                  right: 47,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 336,
                        height: 48,
                        child:
                            _buildStaticField(context, 'Full Name*', fullName),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 336,
                        height: 48,
                        child: _buildStaticField(
                            context, 'Birthday Date*', dateOfBirth),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 336,
                        height: 48,
                        child: _buildStaticField(
                            context, 'Anniversary Date*', dateOfAnniversary),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 336,
                        height: 48,
                        child: _buildStaticField(context, 'Gender*', gender),
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: 336,
                              height: 48,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF000000).withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.phone,
                                    size: 20,
                                    // color: Color(0xFF000000),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: Color(0xFFC4C4C4), // Grey line color
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      mobileNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // SizedBox(width: 10),
                        ],
                      ),
                      // SizedBox(height: 10),
                      // _buildTermsAndConditions(),
                      SizedBox(height: 20),
                      _buildSubmitButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticField(BuildContext context, String label, String value) {
    return Container(
      width: 336,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 15, // font-size: 14px;
              fontWeight: FontWeight.w400, // font-weight: 400;
              height: 16.8 / 14, // line-height: 16.8px; (ratio to font size)
              color: const Color(0xFF353B43), // Set the color to #353B43
            ),
            textAlign: TextAlign.left, // text-align: left;
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      // Placeholder for terms and conditions widget
      child: Text('Terms and Conditions'),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfileUpdate()),
        );
        // Handle submit button press
      },
      child: Text('Edit Profile'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: CustomColors.backgroundtext,
        padding:
            EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
      ),
    );
  }
}
