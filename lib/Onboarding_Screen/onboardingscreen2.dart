import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Onboarding_Screen/onboardingscreen3.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to the next screen after a delay
    // Future.delayed(const Duration(milliseconds: 3000), () {
    //   Get.to(OnboardingScreen3(),
    //       transition: Transition
    //           .cupertino); // Swap overlay to "Onboarding screen 3" with Smart animate
    // });

    // Retrieve screen size information
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
                    'assets/brutal-guy-modern-barber-shop-hairdresser-makes-hairstyle-man-master-hairdresser-does-hairstyle-with-hair-clipper-concept-barbershop.png', // Replace with your image asset path
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
              top: screenSize.height * 0.7,
              left: screenSize.width * 0.05,
              width: screenSize.width * 0.8,
              height: screenSize.height * 0.2,
              child: Container(
                padding: EdgeInsets.zero,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience the Future\nof salon booking, now!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 29,
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
                  onPressed: () {
                    Get.to(OnboardingScreen3(),
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
            // Scroll Dots
            Positioned(
              top: screenSize.height * 0.82,
              left: screenSize.width * 0.06,
              child: Row(
                children: [
                  // Container(
                  //   width: screenSize.height * 0.01, // Smaller width for dots
                  //   height: screenSize.height * 0.01, // Smaller height for dots
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // SizedBox(width: 8),
                  Container(
                    width: screenSize.height * 0.01, // Smaller width for dots
                    height: screenSize.height * 0.01, // Smaller height for dots
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.backgroundtext,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: screenSize.height * 0.01, // Smaller width for dots
                    height: screenSize.height * 0.01, // Smaller height for dots
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
