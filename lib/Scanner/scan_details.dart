import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';
import 'package:ms_salon_task/SignUp/SignUpPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart'; // Import the package

class ScanDetailsPage extends StatefulWidget {
  @override
  _ScanDetailsPageState createState() => _ScanDetailsPageState();
}

class _ScanDetailsPageState extends State<ScanDetailsPage> {
  String scannedCode = '';
  String salonName = '';
  String description = '';
  String address = '';
  String photo = '';
  String rating = '';
  bool isLoading = true;
  late String branchId;
  late String salonId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      scannedCode = prefs.getString('scanned_code') ?? '';

      if (scannedCode.isEmpty) {
        scannedCode = prefs.getString('manual_code') ?? '';
      }

      final url = Uri.parse('${MyApp.apiUrl}customer/get-store/');
      final body = jsonEncode({"store_code": scannedCode});

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        if (data.isNotEmpty) {
          setState(() {
            salonName = data[0]['branch_name'];
            address = data[0]['address'];
            photo = data[0]['store_logo'];
            branchId = data[0]['branch_id'];
            salonId = data[0]['salon_id'];
            description = data[0]['description']; // Save description globally
            var fetchedRating = data[0]['rating'];
            rating = fetchedRating != null && fetchedRating is int
                ? fetchedRating.toString()
                : '0'; // Default to '0' if null
            prefs.setString('branch_id', branchId);
            prefs.setString('salon_id', salonId);
            prefs.setString('store_name', salonName);
            prefs.setString('store_address', address);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('No data available');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookAppointmentPage(),
        //   ),
        // );
        // Navigate to SDateTime when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QrCodePage(),
          ),
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  // Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrCodePage(),
                    ),
                  );
                },
              ),
              Text(
                'Connect Us',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: Colors.transparent,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            photo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              salonName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: 0.02,
                                color: Color(0xFF1D2024),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: index < int.parse(rating)
                                      ? Colors.yellow
                                      : Colors.grey, // Set stars color
                                  size: screenWidth * 0.04,
                                );
                              }),
                            ),
                            SizedBox(height: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/locationpin.png',
                                      width: 12,
                                      height: 12,
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        address,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lato(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                          letterSpacing: 0.02,
                                          color: Color(0xFF1D2024),
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handles long text gracefully
                                        maxLines: 2, // Limits to 2 lines
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              description,
                              // 'Welcome to $salonName, where sophistication, style, and innovation converge to redefine your beauty experience. "Exceptional service, luxurious atmosphere, and talented staff! $salonName truly sets the standard for excellence in beauty and wellness. Highly recommended!"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                color: Color(0xFF1D2024),
                              ),
                            ),
                            SizedBox(height: 200),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        content: Container(
                                          width: screenWidth * 0.65,
                                          height: screenWidth * 0.65,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/Done.png',
                                                width: screenWidth * 0.25,
                                                height: screenWidth * 0.25,
                                              ),
                                              SizedBox(
                                                  height: screenWidth * 0.05),
                                              Text(
                                                'Success!',
                                                style: GoogleFonts.lato(
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF353B43),
                                                  height: 1.2,
                                                  letterSpacing: 0.02,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenWidth * 0.025),
                                              Text(
                                                'Congratulations you have onboarded at $salonName',
                                                style: GoogleFonts.lato(
                                                  fontSize: screenWidth * 0.036,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF353B43),
                                                  height: 1.2,
                                                  letterSpacing: 0.02,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                  height: screenWidth *
                                                      0.05), // Add some spacing before the button
                                              TextButton(
                                                onPressed: () {
                                                  // Navigator.of(context)
                                                  //     .pop(); // Close the dialog
                                                  // Navigator
                                                  //     .pushNamedAndRemoveUntil(
                                                  //   context,
                                                  //   '/signup',
                                                  //   (route) => false,
                                                  // );
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignUpPage(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'Close',
                                                  style: GoogleFonts.lato(
                                                    fontSize:
                                                        screenWidth * 0.036,
                                                    fontWeight: FontWeight.w600,
                                                    color: CustomColors
                                                        .backgroundtext, // Change to your desired color
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  Future.delayed(Duration(seconds: 2), () {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/signup',
                                      (route) => false,
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.backgroundtext,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Container(
                                  width: screenWidth * 0.5,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Connect',
                                    style: GoogleFonts.lato(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
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
}
