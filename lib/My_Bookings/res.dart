import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/my_bookings.dart';
import 'package:ms_salon_task/My_Bookings/select_data_time.dart';

class RescheduleServicesPage extends StatefulWidget {
  @override
  _RescheduleSerciceState createState() => _RescheduleSerciceState();
}

class _RescheduleSerciceState extends State<RescheduleServicesPage> {
  bool isSelected = false;
  bool _isSubmitted = false;

  void _submitReschedule() {
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
              height: 450,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/reschedule.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/rescheduling1.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rescheduling Success!!',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF353B43),
                      height: 21.6 / 18,
                      letterSpacing: 0.02,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Appointment successfully changed. You will receive a notification.',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF353B43),
                      height: 14.4 / 12,
                      letterSpacing: 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Spacer between buttons

                  // View Appointment Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40), // Adjust margins as needed
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to MyBookingsPage on button press
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MyBookingsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            CustomColors.backgroundtext, // Background color
                        shadowColor: const Color(0x0A000000), // Shadow color
                        elevation: 5, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 8), // Adjust padding as needed
                      ),
                      child: const Text(
                        'View Appointment',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15, // Adjust font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Spacer between buttons

                  // Cancel Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40), // Adjust margins as needed
                    child: TextButton(
                      onPressed: () {
                        // Navigate to MyBookingsPage on button press
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MyBookingsPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: CustomColors.backgroundtext,
                            width: 1), // Border color and width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 8), // Adjust padding as needed
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15, // Adjust font size
                          fontWeight: FontWeight.bold,
                          color: CustomColors.backgroundtext, // Blue text color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0, // Remove elevation
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Reschedule Your Services',
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
        children: [
          Container(
            width: 430,
            height: 60,
            margin: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 20,
                  child: Container(
                    width: 200,
                    height: 24,
                    child: const Text(
                      'You Have Selected',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: Colors.black, // Adjust color as needed
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 20, // Align to the right side of the screen
                  child: GestureDetector(
                    onTap: () {
                      // Handle edit action
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: CustomColors.backgroundtext, // Blue color
                        borderRadius: BorderRadius.circular(5), // Rounded edges
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: Colors.white, // White text
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    width: 300,
                    height: 19,
                    child: const Text(
                      '1 Package, 3 Services, and 2 Products',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: CustomColors.backgroundtext, // #0056D0
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
                ServiceItem(
                  serviceName: 'Head massage',
                  packageValidity: 'Special package, valid until May 10, 2024',
                  description: 'Help relieve stress and reduce tension',
                  price: '₹150',
                  product: 'Shampoo',
                  timeSlot: '10:00 AM to 12:00 AM',
                  stylist: 'Priyanka',
                ),
                SizedBox(height: 10),
                ServiceItem(
                  serviceName: 'Body massage',
                  packageValidity: 'Special package, valid until May 10, 2024',
                  description: 'Help relieve stress and reduce tension',
                  price: '₹150',
                  product: 'Shampoo',
                  timeSlot: '10:00 AM to 12:00 AM',
                  stylist: 'Priyanka',
                ),
                // Add more ServiceItem widgets as needed
              ],
            ),
          ),

          // Next Step and Back Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyBookingsPage()),
                    // );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: CustomColors.backgroundtext, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text(
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
              Container(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: ElevatedButton(
                  onPressed: () {
                    _submitReschedule(); // Call _submitReschedule function on button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.backgroundtext,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text(
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
        ],
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String serviceName;
  final String packageValidity;
  final String description;
  final String price;
  final String product;
  final String timeSlot;
  final String stylist;

  const ServiceItem({
    Key? key,
    required this.serviceName,
    required this.packageValidity,
    required this.description,
    required this.price,
    required this.product,
    required this.timeSlot,
    required this.stylist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
      child: Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
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
                serviceName,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424752),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 15,
              child: Text(
                packageValidity,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15,
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
                    description,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Color(0xFF424752),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 110,
              left: 15,
              child: Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424752),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Image.asset(
                    'assets/shampoo.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(172, 161, 161, 161),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    timeSlot,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 112, 112, 112),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Image.asset(
                    'assets/dot.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    stylist,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 107, 107, 107),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 140,
              left: 10,
              child: Container(
                width: 90,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SelectDateTime()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.backgroundtext,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Reschedule',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
