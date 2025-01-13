import 'dart:ui'; // Import this for the BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class BottomNavBar3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // ClipRect to ensure the blur effect is contained
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity here
        child: BottomAppBar(
          color: Colors.transparent, // Make the BottomAppBar transparent
          child: Container(
            height: 60.0, // Adjust height as necessary
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBlurredButton(), // Blurred button for Home

                    SizedBox(width: 20),
                    _buildBlurredButton(), // Blurred button for My Bookings

                    SizedBox(width: 20),
                    _buildButton(
                      context,
                      '/upcomingbooking',
                      'My Bookings',
                      'assets/schedule3.svg',
                    ),
                    _buildBlurredButton(), // Blurred button for Salon Details

                    SizedBox(width: 20),
                    _buildBlurredButton(), // Blurred button for Profile
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Function to create a blurred button
  Widget _buildBlurredButton() {
    return Opacity(
      opacity: 0.0, // Completely transparent for the blur effect
      child: Container(
        width: 50, // Set a fixed width for consistency
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/hut.svg', // Placeholder icon for blurred buttons
              width: 22,
              height: 22,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              'Blurred',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String routeName, String label, String svgPath) {
    bool isCurrentPage = ModalRoute.of(context)?.settings.name == routeName;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      borderRadius: BorderRadius.circular(5),
      splashColor: CustomColors.backgroundtext, // Added opacity for splash
      highlightColor:
          CustomColors.backgroundtext, // Added opacity for highlight
      child: Container(
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     color: isCurrentPage
        //         ? CustomColors.backgroundtext
        //         : Colors.grey, // Change color based on current page
        //     width: 1.0, // Adjust border width
        //   ),
        //   borderRadius:
        //       BorderRadius.circular(8.0), // Match with InkWell's border radius
        // ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 4.0), // Adjust padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 22, // Adjusted width for larger icons
                height: 22, // Adjusted height for larger icons
                color: routeName == '/home'
                    ? Color(0xFF424752)
                    : (isCurrentPage ? CustomColors.backgroundtext : null),
              ),
              const SizedBox(height: 8), // Increased height for more space
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 10, // Font size
                  fontWeight: FontWeight.w500,
                  color: isCurrentPage
                      ? CustomColors.backgroundtext
                      : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
