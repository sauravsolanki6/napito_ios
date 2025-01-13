import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: CustomColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.backgroundPrimary,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'About App',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20), // Adjust top padding here
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                'About Apple Salon',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.35, // Approximately 29.92px line height
                ),
              ),

              SizedBox(height: 20), // Space between title and content chunks
              Text(
                'A data privacy policy is a legal document that lives on your website and details all the ways in which a website visitors’ personal data may be used. At the very least, it needs to explain how your website collects data, what data you collect, and what you plan to do with that data.',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  height: 1.32, // Approximately 16.32px line height
                ),
              ),
              SizedBox(height: 20), // Space between chunks
              Text(
                'In addition to living on your website, your data privacy policy also should be easily accessible to website visitors from any page they visit. That’s why you often see it in the footer of every page on a website, including our own There are a number of laws that require data privacy policies.',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  height: 1.32, // Approximately 16.32px line height
                ),
              ),
              SizedBox(height: 20), // Space between chunks
              Text(
                'Chances are one of the laws applies to your company. If, for some reason, none of the laws apply to you, you still might be required to have a privacy policy because of the analytics tools, email tools, or advertising platforms that your company uses. Legislation that requires a privacy policy The legal landscape around privacy is constantly evolving. The GDPR is one of the most recent privacy laws to take effect, and the CCPA is going to take effect in just a few months. All information processed by us may be transferred, processed, and stored anywhere in the world, which may have data protection laws that are different from the laws where you live.',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  height: 1.32, // Approximately 16.32px line height
                ),
              ),
              // SizedBox(height: 190), // Space before the button
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushNamed(
              //         context, '/profile'); // Navigate to "Profile" screen
              //   },
              //   child: Container(
              //     width: 370,
              //     height: 38,
              //     margin: EdgeInsets.only(),
              //     decoration: BoxDecoration(
              //       color: CustomColors.backgroundtext,
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(6),
              //         bottomLeft: Radius.circular(6),
              //         topRight: Radius.circular(6),
              //         bottomRight: Radius.circular(6),
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Color(0x00000008),
              //           offset: Offset(10, -2),
              //           blurRadius: 75,
              //           spreadRadius: 4,
              //         ),
              //       ],
              //     ),
              //     child: Center(
              //       child: Text(
              //         'Accept and Continue',
              //         style: TextStyle(
              //           fontFamily: 'Lato',
              //           fontSize: 16,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
