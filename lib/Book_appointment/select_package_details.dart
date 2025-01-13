// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:ms_salon_task/My_Bookings/select_data_time.dart';

class SelectPackageDetailsPage extends StatefulWidget {
  @override
  _SelectPackagePageState createState() => _SelectPackagePageState();
}

class _SelectPackagePageState extends State<SelectPackageDetailsPage> {
  bool isSelected = false;
  bool showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0, // Remove elevation
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 358,
              height: 238,
              child: Image.asset(
                'assets/packdetails.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 30, // Adjusted to place the button at the bottom
            left: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SDateTime()),
                );
              },
              child: Container(
                width: 358,
                height: 48,
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x00000008),
                      offset: Offset(10, -2),
                      blurRadius: 75,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Book Now ₹5,000',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.02,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 290, // Adjust position based on your layout needs
            left: 30,
            child: Container(
              width: 358,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haircut & Hairstyle', // Replace with your actual text
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0.02,
                      color: Color(0xFF424752),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Special offer package, valid until May 10, 2024',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      letterSpacing: 0.02,
                      color: Color(0xFF424752),
                    ),
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Whether you\'re in need of a complete hair makeover or simply seeking inspiration for your next haircut, our hairstyle and haircut guide has everything you need to know to achieve the perfect look. ',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                        showFullDescription
                            ? TextSpan(
                                text: 'Read less...',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  letterSpacing: 0.02,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      showFullDescription = false;
                                    });
                                  },
                              )
                            : TextSpan(
                                text: 'Read more...',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  letterSpacing: 0.02,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      showFullDescription = true;
                                    });
                                  },
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  showFullDescription
                      ? Text(
                          'Explore our tips, tutorials, and trend reports to discover the hairstyle that best reflects your personality.',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        )
                      : Container(),
                  Text(
                    'Services', // Replace with your actual text
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0.02,
                      color: Color(0xFF424752),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 20),
                  Positioned(
                    top:
                        710, // Adjusted top position for the first additional row
                    left: 36,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.check_mark,
                          size: 17,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hair Coloring',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                        SizedBox(width: 50), // Adjust spacing as needed
                        Icon(
                          CupertinoIcons.check_mark,
                          size: 17,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Scalp Treatment',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Positioned(
                    top:
                        750, // Adjusted top position for the second additional row
                    left: 36,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.check_mark,
                          size: 17,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hair color',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                        SizedBox(width: 70), // Adjust spacing as needed
                        Icon(
                          CupertinoIcons.check_mark,
                          size: 17,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hair Spa',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Positioned(
                    top:
                        750, // Adjusted top position for the second additional row
                    left: 36,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.check_mark,
                          size: 17,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Corner Lashes',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                        SizedBox(width: 40), // Adjust spacing as needed
                        Icon(
                          CupertinoIcons.check_mark,
                          size: 17,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Haircut',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
