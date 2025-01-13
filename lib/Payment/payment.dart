import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart'; // Import Shimmer package

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String apiUrl = '${MyApp.apiUrl}customer/payments/';
  List paymentData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchPaymentData();
    });
    _fetchPaymentData();
  }

  Future<void> _fetchPaymentData() async {
    setState(() {
      isLoading = true; // Show loading indicator when fetching data
    });
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
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
        print('No valid customer ID found');
        return;
      }

      final body = jsonEncode({
        "salon_id": salonID,
        "branch_id": branchID,
        "customer_id": customerId,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          paymentData = responseData['data'];
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      // Log error with Crashlytics and error logger
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
      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> _fetchPaymentData",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );
      print('Error in _fetchPaymentData: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    return WillPopScope(
        onWillPop: () async {
          // This will navigate back to the first occurrence of `HomePage` in the stack
          // Navigator.of(context).pop((route) => route.isFirst);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      title: '',
                    )),
          );
          return false; // Prevent the default back navigation
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
                  icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    // Navigator.of(context).pop((route) => route.isFirst);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          title: '',
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'Payment History',
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
            onRefresh: _fetchPaymentData,
            child: isLoading
                ? _buildSkeletonLoader(isLargeScreen)
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            isLargeScreen ? screenSize.width * 0.1 : 16.0,
                        vertical: 10.0),
                    child: ListView.builder(
                      itemCount: paymentData.length,
                      itemBuilder: (context, index) {
                        final payment = paymentData[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8C75F5).withOpacity(0.9),
                                  Color(0xFF5C4BC4).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        payment['payment_for'],
                                        style: GoogleFonts.lato(
                                          fontSize: isLargeScreen ? 22 : 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.white, height: 20),
                                  SizedBox(height: 10),
                                  _buildInfoRow(
                                    Icons.date_range,
                                    payment['payment_date'],
                                    isLargeScreen,
                                  ),
                                  _buildInfoRow(
                                    Icons.payment,
                                    payment['payment_mode'],
                                    isLargeScreen,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Amount:',
                                            style: GoogleFonts.lato(
                                              fontSize: isLargeScreen ? 22 : 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '₹${payment['paid_amount']}',
                                            style: GoogleFonts.lato(
                                              fontSize: isLargeScreen ? 22 : 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (payment['receipt'] != null)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              _launchUrl(payment['receipt']);
                                            },
                                            child: Text(
                                              'View Receipt',
                                              style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    isLargeScreen ? 16 : 14,
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
                        );
                      },
                    ),
                  ),
          ),
        ));
  }

  Widget _buildInfoRow(IconData icon, String text, bool isLargeScreen) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: isLargeScreen ? 18 : 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Function to build the skeleton loader
  Widget _buildSkeletonLoader(bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 50 : 16),
      child: ListView.builder(
        itemCount: 5, // Number of skeleton loaders to show
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 100, // Height of each skeleton card
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
