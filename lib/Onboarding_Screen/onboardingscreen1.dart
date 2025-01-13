import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:ms_salon_task/Onboarding_Screen/onboardingscreen2.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({Key? key}) : super(key: key);

  @override
  _OnboardingScreen1State createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  @override
  void initState() {
    super.initState();
    saveValueToSharedPreferences(); // Call the function to save value to SharedPreferences
  }

  // Function to save value to SharedPreferences
  saveValueToSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('isloginfirst', "1");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve screen size information
    final Size screenSize = MediaQuery.of(context).size;

    // Delayed navigation function
    // void navigateToNextScreen() {
    //   Future.delayed(const Duration(milliseconds: 2000), () {
    //     Get.to(const OnboardingScreen2(),
    //         transition: Transition
    //             .cupertino); // Navigate to OnboardingScreen2 with transition
    //   });
    // }

    // Call the delayed navigation function when the widget is built
    // navigateToNextScreen();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/woman-hairdresser-salon.png', // Replace with your image asset path
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay Image
            Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/Overlay.png', // Replace with your overlay image asset path
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            Positioned(
              top: screenSize.height * 0.65,
              left: 20,
              width: screenSize.width - 76,
              height: 200,
              child: Container(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: screenSize.width * 0.09,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ms Salon',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: screenSize.width * 0.09,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Find Your Barber',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: screenSize.width * 0.09,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Next Button
            Positioned(
              top: screenSize.height * 0.85,
              left: screenSize.width * 0.05,
              child: Container(
                width: screenSize.width * 0.37,
                height: screenSize.height * 0.05,
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(screenSize.height * 0.025),
                    right: Radius.circular(screenSize.height * 0.025),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    Get.to(const OnboardingScreen2(),
                        transition: Transition.cupertino);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Lato',
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Page Indicators
            Positioned(
              top: screenSize.height * 0.82,
              left: screenSize.width * 0.06,
              child: Row(
                children: [
                  Container(
                    width: screenSize.height * 0.01,
                    height: screenSize.height * 0.01,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.backgroundtext,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: screenSize.height * 0.01,
                    height: screenSize.height * 0.01,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: screenSize.height * 0.01,
                    height: screenSize.height * 0.01,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
