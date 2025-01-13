import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Onboarding_Screen/onboardingscreen2.dart';
import 'package:ms_salon_task/Scanner/qr_code.dart';

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

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
                    'assets/onboarding3.png', // Replace with your image asset path
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay Image
            Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: BoxDecoration(
                color: CustomColors.backgroundtext
                    .withOpacity(0.1), // Adjust opacity (0.0 to 1.0)
              ),
            ),
            // Content
            Positioned(
              top: screenSize.height * 0.67,
              left: screenSize.width * 0.05,
              width: screenSize.width * 0.8,
              height: screenSize.height * 0.2,
              child: Container(
                padding: EdgeInsets.zero,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enjoy your salon services without waiting..',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 52.8 / 44,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            // Skip Button
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
                  // onPressed: () {
                  //   Get.to(QrCodePage(), transition: Transition.cupertino);
                  // },
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/qr');
                  },

                  child: const Padding(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      'Get Started',
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
            // Scroll Dots
            Positioned(
              top: screenSize.height * 0.82,
              left: screenSize.width * 0.06,
              child: Row(
                children: [
                  Container(
                    width: screenSize.height * 0.01, // Smaller width for dots
                    height: screenSize.height * 0.01, // Smaller height for dots
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: screenSize.height * 0.01, // Smaller width for dots
                    height: screenSize.height * 0.01, // Smaller height for dots
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.backgroundtext,
                    ),
                  ),
                  // SizedBox(width: 8),
                  // Container(
                  //   width: screenSize.height * 0.01, // Smaller width for dots
                  //   height: screenSize.height * 0.01, // Smaller height for dots
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
