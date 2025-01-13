// ignore_for_file: prefer_const_constructors

import 'dart:async'; // Import async library for Timer

import 'package:flutter/material.dart';
import 'package:ms_salon_task/My_Bookings/my_bookings.dart';
import 'package:ms_salon_task/Raise_Ticket/ticket_details.dart';

import '../Colors/custom_colors.dart';

class CancelBooking extends StatefulWidget {
  @override
  _CancelBookingState createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking> {
  bool _isSubmitted = false;

  void _submitAppointmentCancellation() {
    // Perform submission logic here, if needed
    setState(() {
      _isSubmitted = true;
    });

    // Show dialog after submission
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog on tap outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            width: 280,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Done.png',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'Successful!',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF353B43),
                    height: 21.6 / 18,
                    letterSpacing: 0.02,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'You have successful canceled your Appointment. 80% fund will be returned to your account.',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF353B43),
                    height: 14.4 / 12,
                    letterSpacing: 0.02,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Automatically close dialog and navigate after 2 seconds
    Timer(Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/upcomingbooking',
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Cancel Appointment',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 38,
            child: Container(
              width: 250,
              height: 26,
              child: Center(
                child: Text(
                  'Reason for cancel appointment',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          content: Container(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    "Select Your Reason",
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF353B43),
                                      height: 16.8 / 14,
                                    ),
                                  ),
                                ),
                                buildHelpTypeItem("Salon not open", false),
                                Divider(
                                  height: 1,
                                  color: Color(0xFFF6F6F6),
                                ),
                                buildHelpTypeItem("Service delay", false),
                                Divider(
                                  height: 1,
                                  color: Color(0xFFF6F6F6),
                                ),
                                buildHelpTypeItem("Other issue", false),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 336,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 219, 220, 220),
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Your Reason',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF353B43),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF353B43),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 160,
            left: 40,
            child: Container(
              width: 336,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color.fromARGB(255, 219, 220, 220),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF353B43),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 660,
            left: 40,
            child: GestureDetector(
              onTap: () {
                _submitAppointmentCancellation(); // Call submit method
              },
              child: Container(
                width: 336,
                height: 50,
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color.fromARGB(255, 219, 220, 220),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Submit',
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
    );
  }

  Widget buildHelpTypeItem(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 16.8 / 14,
              color: Color(0xFF353B43),
            ),
          ),
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }
}
