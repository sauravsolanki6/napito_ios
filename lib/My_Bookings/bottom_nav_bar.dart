import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFFFAFAFA),
      child: Container(
        color: Color(0xFFFAFAFA),
        height: 60.0, // Adjust height as necessary
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  '/home',
                  'Home',
                  'assets/hut.svg',
                ),
                SizedBox(width: 20), // Increased width for more gap
                _buildButton(
                  context,
                  '/book_appointment',
                  'Book Appointment',
                  'assets/check-mark.svg',
                ),
                SizedBox(width: 20), // Increased width for more gap
                _buildButton(
                  context,
                  '/upcomingbooking',
                  'My Bookings',
                  'assets/schedule3.svg',
                ),
                SizedBox(width: 20), // Increased width for more gap
                _buildButton(
                  context,
                  '/saloon_details_page',
                  'Salon Details',
                  'assets/store.svg',
                ),
                SizedBox(width: 20), // Increased width for more gap
                _buildButton(
                  context,
                  '/profile',
                  'Profile',
                  'assets/user2.svg',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String routeName, String label, String svgPath) {
    bool isCurrentPage = ModalRoute.of(context)?.settings.name == routeName;

    // Specific color logic for "Home" and "My Bookings"
    Color? iconColor;
    Color textColor;

    if (routeName == '/home') {
      iconColor = const Color.fromARGB(178, 0, 0, 0);
      textColor = Colors.black87;
    } else if (routeName == '/upcomingbooking') {
      iconColor = CustomColors.backgroundtext;
      textColor = CustomColors.backgroundtext;
    } else {
      iconColor = isCurrentPage ? Colors.black87 : null;
      textColor = isCurrentPage ? Colors.black87 : Colors.black;
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      borderRadius: BorderRadius.circular(8.0),
      splashColor: CustomColors.backgroundtext, // Added opacity for splash
      highlightColor:
          CustomColors.backgroundtext, // Added opacity for highlight
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
              color: iconColor,
            ),
            const SizedBox(height: 8), // Increased height for more space
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10, // Font size
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
