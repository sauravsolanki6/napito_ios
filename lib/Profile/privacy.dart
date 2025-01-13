import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  late Future<List<String>> _privacyPolicyData;

  @override
  void initState() {
    super.initState();
    _privacyPolicyData = _fetchPrivacyPolicyData();
  }

  Future<List<String>> _fetchPrivacyPolicyData() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      final response = await http.post(
        Uri.parse('${Config.apiUrl}customer/privacy-policy/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'salon_id': salonID,
          'branch_id': branchID,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'true' && data['message'] == 'success') {
          return List<String>.from(data['data']);
        } else {
          throw Exception('Failed to load privacy policy');
        }
      } else {
        throw Exception('Failed to load privacy policy');
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
        errorLocation: "Function -> _fetchPrivacyPolicyData",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error in _fetchPrivacyPolicyData: $e');
      print('Stack Trace: $stackTrace');

      // Optionally, rethrow the exception or return an empty list
      throw Exception('Error during privacy policy API call: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _privacyPolicyData = _fetchPrivacyPolicyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.backgroundPrimary,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 8),
            Text(
              'Privacy Policy',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<String>>(
          future: _privacyPolicyData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: PrivacyPolicyItemShimmer(),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: PrivacyPolicyItem(
                                text: item,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // SizedBox(height: 20),
                    // Center(
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Navigator.pushNamed(
                    //         context,
                    //         '/profile', // Navigate to "Profile" screen
                    //       );
                    //     },
                    //     child: Container(
                    //       width: 360,
                    //       height: 38,
                    //       decoration: BoxDecoration(
                    //         color: CustomColors.backgroundtext,
                    //         borderRadius: BorderRadius.circular(6),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Color(0x00000008),
                    //             offset: Offset(10, -2),
                    //             blurRadius: 75,
                    //             spreadRadius: 4,
                    //           ),
                    //         ],
                    //       ),
                    //       child: Center(
                    //         child: Text(
                    //           'Accept and Continue',
                    //           style: TextStyle(
                    //             fontFamily: 'Lato',
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w600,
                    //             color: Colors.white,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20), // Space below the button
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class PrivacyPolicyItem extends StatelessWidget {
  final String text;

  const PrivacyPolicyItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // Split the text into the label (before the colon) and the description (after the colon)
    final parts = text.split(':');
    if (parts.length < 2) {
      // If there's no colon, just return the text as is
      return Text(
        text,
        textAlign: TextAlign.justify,
        style: GoogleFonts.lato(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      );
    }

    final label = parts[0].trim();
    final description = parts.sublist(1).join(':').trim();

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.lato(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: description,
            style: GoogleFonts.lato(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.justify,
    );
  }
}

class PrivacyPolicyItemShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            color: Colors.grey,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.grey,
                ),
                SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
