import 'dart:ui'; // Import this for the BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class BottomNavBar2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Container(
            height: 60.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Ensure minimal width for the Row
                children: [
                  _buildBlurredButton(),
                  SizedBox(width: 10),
                  _buildButton(
                    context,
                    '/book_appointment',
                    'Book Appointment',
                    'assets/check-mark.svg',
                  ),
                  _buildBlurredButton(),
                  _buildBlurredButton(),
                  _buildBlurredButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Function to create a blurred button
Widget _buildBlurredButton() {
  return Opacity(
    opacity: 0.0,
    child: Container(
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/hut.svg',
            width: 18,
            height: 18,
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          Text(
            'Blurred',
            style: TextStyle(color: Colors.black, fontSize: 8),
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
    splashColor: CustomColors.backgroundtext,
    highlightColor: CustomColors.backgroundtext,
    child: Container(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 25,
              height: 25,
              color: routeName == '/home'
                  ? Color(0xFF424752)
                  : (isCurrentPage ? CustomColors.backgroundtext : null),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color:
                    isCurrentPage ? CustomColors.backgroundtext : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
