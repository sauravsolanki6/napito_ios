import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer for 4 seconds
    Timer(Duration(seconds: 3), () {
      // After 4 seconds, navigate to the homepage
      Navigator.pushReplacementNamed(
          context, '/home'); // Replace '/home' with your actual homepage route
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  right: screenSize.width * 0.02), // Adjust the right padding
              child: Image.asset(
                'assets/loader.gif', // Replace with your actual GIF path
                width: screenSize.width * 0.4, // Adjust size as needed
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please Wait',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize:
                    screenSize.width * 0.06, // Example responsive font size
                fontWeight: FontWeight.w500,
                height: 1.2, // Adjusted line height
                letterSpacing: 0.02,
                color: CustomColors.backgroundtext,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'We Are Onboarding At Apple Saloon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize:
                    screenSize.width * 0.05, // Example responsive font size
                fontWeight: FontWeight.w500,
                height: 1.2, // Adjusted line height
                letterSpacing: 0.02,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
