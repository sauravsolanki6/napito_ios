import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

// import '../RAise Ticket new/raise_ticket.dart';
import 'package:ms_salon_task/Raise_Ticket/raise_ticket.dart';

class SosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
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
              'Help',
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
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            width: 430,
            height: 490,
            child: Image.asset(
              'assets/signupback1.png', // Replace with your upper background image asset path
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 434,
            width: 430,
            height: 490,
            left: 0,
            child: Transform.rotate(
              angle: -180 * (3.14 / 180),
              child: Image.asset(
                'assets/signupback1.png', // Replace with your lower background image asset path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 60,
            child: Container(
              width: 272,
              height: 272,
              child: Image.asset(
                'assets/help.png', // Replace with your help.png image asset path
                width: 272, // Width of the help.png image
                height: 272, // Height of the help.png image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 430,
            left: 110,
            child: GestureDetector(
              onTap: () {
                // Navigate to Raise Ticket screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RaiseTicket(), // Replace with your Raise Ticket screen widget
                  ),
                );
              },
              child: Container(
                width: 185,
                height: 48,
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext, // Button background color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Raise Ticket',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
