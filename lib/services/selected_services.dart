import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/services/special_services.dart';

class SelectedServicesPage extends StatefulWidget {
  @override
  _SelectPackagePageState createState() => _SelectPackagePageState();
}

class _SelectPackagePageState extends State<SelectedServicesPage> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0, // Remove elevation
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Selected Services',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenSize.width,
            height: 122,
            margin: EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: screenSize.width * 0.46,
                    height: 24,
                    child: Text(
                      'You Have Selected',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      // Handle edit action
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      decoration: BoxDecoration(
                        color: CustomColors.backgroundtext,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    width: screenSize.width * 0.7,
                    height: 19,
                    child: Text(
                      '1 Package, 3 Services, and 2 Products',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: CustomColors.backgroundtext,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Package',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 19.2 / 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected = !isSelected;
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        height: 154,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x00000008),
                              offset: Offset(15, 15),
                              blurRadius: 90,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 11,
                              left: 15,
                              child: Text(
                                'Head massage',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF424752),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              left: 15,
                              child: Text(
                                'Special package, valid until May 10, 2024',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                  color: Color(0xFF424752),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 70,
                              left: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Help relieve stress and reduce tension',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      color: Color(0xFF424752),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 120,
                              left: 15,
                              child: Row(
                                children: [
                                  Text(
                                    '₹150',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424752),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Image.asset(
                                    'assets/shampoo.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Shampoo',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(172, 161, 161, 161),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: screenSize.width * 0.8 - 0,
                              child: Container(
                                width: 45,
                                height: 154,
                                decoration: BoxDecoration(
                                  color: Color(0xC40056D0),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/stopwatch1.png',
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Schedule',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 6,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                        letterSpacing: 0.02,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Service Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Service',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 19.2 / 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected = !isSelected;
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        height: 154,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x00000008),
                              offset: Offset(15, 15),
                              blurRadius: 90,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 11,
                              left: 15,
                              child: Text(
                                'Face massage (फेस मसाज)',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF424752),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              left: 15,
                              child: Text(
                                'Helps promote healthy skin while relaxing facial muscles.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                  color: Color(0xFF424752),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Help relieve stress and reduce tension',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      color: Color(0xFF424752),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 120,
                              left: 15,
                              child: Row(
                                children: [
                                  Text(
                                    '₹100',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424752),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Image.asset(
                                    'assets/shampoo.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Face Cream',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(172, 161, 161, 161),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: screenSize.width * 0.8 - 0,
                              child: Container(
                                width: 45,
                                height: 154,
                                decoration: BoxDecoration(
                                  color: Color(0xC40056D0),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/stopwatch1.png',
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Schedule',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 6,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                        letterSpacing: 0.02,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Next Step and Back Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SpecialServicesPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: CustomColors.backgroundtext, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.backgroundtext,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle next step action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.backgroundtext,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Next Step',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
