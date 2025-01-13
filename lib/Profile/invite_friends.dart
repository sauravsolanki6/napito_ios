import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class NotificationItem1 extends StatefulWidget {
  final String name;
  final String mobile;
  final VoidCallback onInvitePressed; // Callback for the invite button

  NotificationItem1({
    required this.name,
    required this.mobile,
    required this.onInvitePressed,
  });

  @override
  _NotificationItem1State createState() => _NotificationItem1State();
}

class _NotificationItem1State extends State<NotificationItem1> {
  bool invited = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: screenHeight * 0,
        bottom: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.8,
            color: Colors.white,
          ),
        ),
      ),
      child: SizedBox(
        height: screenHeight * 0.1,
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.02,
              left: screenWidth * 0,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/profile2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 0.02,
                          color: Color(0xFF424752),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.mobile,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: 0.02,
                          color: Color(0xFF424752),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              right: screenWidth * 0.04,
              child: SizedBox(
                width: 70,
                height: 36,
                child: ElevatedButton(
                  onPressed: invited
                      ? null
                      : () {
                          setState(() {
                            invited = true;
                          });
                          widget.onInvitePressed();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: invited
                        ? Color(0xFFfafafa)
                        : CustomColors.backgroundtext,
                    side: BorderSide(
                      width: 1.0,
                      color: CustomColors
                          .backgroundtext, // Border color when not invited
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    minimumSize: Size(80, 36),
                  ),
                  child: Center(
                    child: Text(
                      invited ? 'Invited' : 'Invite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: invited
                            ? CustomColors.backgroundtext
                            : Colors
                                .white, // Blue text when invited, white when not
                      ),
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

class InviteFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

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
              'Invite Friends',
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
      body: Container(
        width: double.infinity,
        color: Color(0xFFFAFAFA),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            NotificationItem1(
              name: 'Shri Aurobindo Ghosh',
              mobile: '9876543210',
              onInvitePressed: () {
                // Handle invite button press
                print('Invite button pressed');
              },
            ),
            NotificationItem1(
              name: 'Another Name',
              mobile: '1234567890',
              onInvitePressed: () {
                // Handle invite button press
                print('Invite button pressed');
              },
            ),
            // Add more NotificationItem widgets as needed
          ],
        ),
      ),
    );
  }
}
