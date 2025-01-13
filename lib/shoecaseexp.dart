import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/bottom_nav_bar.dart';
import 'package:ms_salon_task/My_Bookings/bottomnav.dart';
import 'package:ms_salon_task/Profile/notification.dart';
import 'package:ms_salon_task/Raise_Ticket/sos.dart';
import 'package:ms_salon_task/Sidebar/sidebar_drawer.dart';
import 'package:ms_salon_task/botom3.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/traingle.dart';
import 'package:ms_salon_task/triangle_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage2 extends StatefulWidget {
  final String title;

  HomePage2({Key? key, required this.title}) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  bool _isSidebarOpen = false;
  bool _isThirdDialogVisible = false; // Flag for the third dialog

  String customerID = '';
  bool _isUsingThirdNavBar = false;
  String branchID = '';
  String salonID = '';
  String mobileNumber = '';
  String _storeName = 'Default Store Name';
  bool _isDialogVisible = true; // Set to true to show the dialog by default
  bool _isUsingSecondNavBar =
      false; // Flag to determine which bottom nav bar to show
  int _selectedIndex = 0;
  bool _isSecondDialogVisible = false; // Flag for the second dialog

  @override
  void initState() {
    super.initState();
    _loadStoreName(); // Load the store name during initialization
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you really want to exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('store_name') ?? 'Default Store Name';
    setState(() {
      _storeName = storedName;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
      if (_isSecondDialogVisible) {
        _isUsingSecondNavBar =
            true; // Show the second nav bar when the second dialog is open
      }
    });
  }

  Widget _buildBlurBackground() {
    return Container(
      decoration: BoxDecoration(
        // color: CustomColors.backgroundtext
        //     .withOpacity(0.5),
        color: Colors.black.withOpacity(0.5),
        // Apply opacity to the custom color
        // borderRadius: BorderRadius.circular(8.0), // Set the border radius
      ),
    );
  }

  Widget _buildBlurBackground2() {
    return Stack(
      children: [
        Container(
          // color: CustomColors.backgroundtext
          //     .withOpacity(0.5), // Apply opacity to the custom color
          color: Colors.black.withOpacity(0.5),
        ),
        // Positioned(
        //   bottom: 15, // Adjust this value to position the arrow
        //   left: MediaQuery.of(context).size.width * 0.28, // Center the arrow
        //   child: Icon(
        //     Icons.arrow_upward, // Use an upward arrow icon
        //     size: 30, // Adjust size as needed
        //     color: Colors.white, // Change color as desired
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: 120, // You might consider making this responsive as well
      right: screenWidth * 0.05, // Position from the right
      left: screenWidth * 0.1, // Keep the left margin
      child: Material(
        color: Colors.transparent, // Set the material color to transparent
        child: Stack(
          clipBehavior:
              Clip.none, // Allow the triangle to go outside the bounds
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors
                    .transparent, // Make the dialog background transparent
                borderRadius:
                    BorderRadius.circular(16.0), // Increase border radius
                border:
                    Border.all(color: Colors.white, width: 2), // White border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Subtle shadow
                    blurRadius: 10, // Softens the shadow
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Click here to scan the QR code and add a salon.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set the text color to white
                      shadows: [],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // Distribute buttons evenly
                    children: [
                      // TextButton(
                      //   onPressed: () {
                      //     // Navigate to HomePage when Skip button is pressed
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => HomePage(title: ''),
                      //       ),
                      //     );
                      //   },
                      //   child: Text(
                      //     "Skip",
                      //     style: TextStyle(
                      //       color: Colors.white, // Keep the text color white
                      //       shadows: [],
                      //     ),
                      //   ),
                      // ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isDialogVisible = false; // Hide the first dialog
                            _isSecondDialogVisible =
                                true; // Show the second dialog
                            _isUsingSecondNavBar =
                                true; // Show the second nav bar
                          });
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            color: CustomColors
                                .backgroundLight, // Set the text color to your desired color
                            shadows: [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Triangle at the top
            Positioned(
              // top: screenWidth * 0.15,
              top: -10, // You can adjust this value for responsiveness
              right: screenWidth * 0.16, // Use MediaQuery for right position
              child: CustomPaint(
                size: Size(20, 10), // Size of the triangle
                painter: TrianglePainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dialogWidth =
        screenWidth * 0.7; // Dialog width relative to screen width
    final double dialogPadding =
        screenWidth * 0.05; // Padding as a percentage of screen width
    final double borderRadius =
        screenWidth * 0.04; // Border radius relative to screen width
    final double boxShadowBlurRadius = screenWidth * 0.02; // Shadow blur radius
    final double triangleSizeWidth = screenWidth * 0.05; // Triangle width
    final double triangleSizeHeight = screenHeight * 0.025; // Triangle height
    final double bottomPosition =
        screenHeight * 0.1; // Position from the bottom
    final double leftPosition = screenWidth * 0.1; // Position from the left
    final double textFontSize =
        screenWidth * 0.045; // Font size relative to screen width
    final double spaceBetweenTextAndButtons =
        screenHeight * 0.025; // Space between text and buttons

    return Positioned(
      bottom: bottomPosition, // Position it in the bottom right
      left: leftPosition, // Position it from the left
      child: Material(
        color: Colors.transparent, // Ensure the material is transparent
        child: Stack(
          clipBehavior:
              Clip.none, // Allow the triangle to go outside the bounds
          children: [
            Container(
              width: dialogWidth, // Set the width of the dialog
              padding: EdgeInsets.all(dialogPadding), // Proportional padding
              decoration: BoxDecoration(
                color: Colors
                    .transparent, // Set the background color to transparent
                borderRadius:
                    BorderRadius.circular(borderRadius), // Rounded corners
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2, // Border width
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1), // Subtle shadow for a softer look
                    blurRadius: boxShadowBlurRadius,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Click here to book an appointment.",
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set the text color to white
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height:
                          spaceBetweenTextAndButtons), // Space between text and buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSecondDialogVisible =
                                false; // Hide the second dialog
                            _isDialogVisible = true; // Show the first dialog
                            _isUsingSecondNavBar = false; // Hide BottomNavBar3
                            _isUsingThirdNavBar =
                                false; // Ensure third nav bar is hidden
                            _isThirdDialogVisible =
                                false; // Ensure third dialog is hidden
                          });
                        },
                        child: Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.white, // Keep the text color white
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSecondDialogVisible =
                                false; // Hide the second dialog
                            _isUsingThirdNavBar = true; // Show BottomNavBar3
                            _isThirdDialogVisible =
                                true; // Show the third dialog
                          });
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white, // Keep the text color white
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Triangle on the left side
            Positioned(
              left: screenWidth * 0.22, // Position relative to screen width
              top: screenHeight * 0.21, // Position relative to screen height
              child: CustomPaint(
                size: Size(triangleSizeWidth,
                    triangleSizeHeight), // Adjust triangle size proportionally
                painter:
                    TrianglePainter2(), // Use your existing TrianglePainter
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThirdDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dialogWidth =
        screenWidth * 0.6; // Adjust dialog width relative to screen width
    final double dialogPadding =
        screenWidth * 0.04; // Adjust padding as a percentage of screen width
    final double borderRadius =
        screenWidth * 0.04; // Border radius as a percentage of screen width
    final double boxShadowBlurRadius = screenWidth * 0.02; // Shadow blur radius
    final double triangleSizeWidth =
        screenWidth * 0.05; // Triangle width relative to screen width
    final double triangleSizeHeight =
        screenWidth * 0.025; // Triangle height relative to screen width
    final double bottomPosition =
        screenHeight * 0.07; // Position from the bottom
    final double leftPosition = screenWidth * 0.31; // Position from the left
    final double textFontSize =
        screenWidth * 0.045; // Font size relative to screen width

    return Positioned(
      bottom: bottomPosition, // Position it in the bottom right
      left: leftPosition, // Use MediaQuery for left position
      child: Material(
        color: Colors.transparent, // Ensure the material is transparent
        child: Stack(
          clipBehavior:
              Clip.none, // Allow the triangle to go outside the bounds
          children: [
            Container(
              width: dialogWidth, // Set the width of the dialog
              padding: EdgeInsets.all(dialogPadding),
              decoration: BoxDecoration(
                color: Colors
                    .transparent, // Set the background color to transparent
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white, // Set the border color to white
                  width: 2, // Width of the border
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1), // Subtle shadow for a softer look
                    blurRadius: boxShadowBlurRadius,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Click here to reschedule or cancel an appointment.",
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set the text color to white
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height: screenHeight *
                          0.025), // Space between text and buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSecondDialogVisible =
                                true; // Hide the second dialog
                            _isUsingSecondNavBar = true; // Show BottomNavBar3
                            _isUsingThirdNavBar = false;
                            _isThirdDialogVisible = false;
                          });
                        },
                        child: Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.white, // Keep the text color white
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to HomePage when Finish button is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(title: ''),
                            ),
                          );
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: Colors
                                .white, // Set the button text color to white
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Triangle on the left side
            Positioned(
              left: leftPosition -
                  screenWidth *
                      0.09, // Adjust position relative to screen width
              bottom: 0,
              top: screenHeight *
                  0.23, // Adjust top position relative to screen height
              child: CustomPaint(
                size: Size(triangleSizeWidth,
                    triangleSizeHeight), // Size of the triangle
                painter:
                    TrianglePainter2(), // Use your existing TrianglePainter
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: CustomColors.backgroundLight,
        drawer: SidebarDrawer(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/back4.png'), // Replace with your image path
              fit: BoxFit.fill, // Adjust the image to cover the whole container
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    automaticallyImplyLeading: true,
                    title: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _storeName,
                                    style: GoogleFonts.lato(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      letterSpacing: 0.02,
                                      color: Color(0xFF1D2024),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDialogVisible =
                                          true; // Show the dialog
                                    });
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    child: SvgPicture.asset(
                                      'assets/scanner11.svg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    child: SvgPicture.asset(
                                      'assets/notif.svg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SosPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    child: SvgPicture.asset(
                                      'assets/exclamation.svg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Overlay for the dialog and blur effect
              if (_isDialogVisible) _buildBlurBackground(),
              // Your dialog
              if (_isDialogVisible) _buildDialog(context),
              // Positioned second scanner icon
              if (_isSecondDialogVisible) _buildBlurBackground2(),
              if (_isSecondDialogVisible) _buildSecondDialog(context),
              if (_isThirdDialogVisible) _buildBlurBackground2(),
              if (_isThirdDialogVisible) _buildThirdDialog(context),

              if (_isDialogVisible)
                Positioned(
                  top: MediaQuery.of(context).size.width *
                      0.16, // Same top position as the first scanner icon
                  right: MediaQuery.of(context).size.width *
                      0.23, // Adjust as needed
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDialogVisible =
                            true; // Show the dialog again if needed
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: _isUsingThirdNavBar
            ? BottomNavBar3() // Show BottomNavBar3 when the flag is true
            : _isUsingSecondNavBar
                ? BottomNavBar2()
                : BottomNavBar(), // Conditional rendering
      ),
    );
  }
}
