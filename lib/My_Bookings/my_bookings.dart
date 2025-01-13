import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_services.dart';
import 'package:flutter_svg/svg.dart';

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  int _selectedIndex = 0; // Track the selected index
  OverlayEntry? _overlayEntry; // Track the overlay entry
  bool _isSwitchOn = false; // Track the switch state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFAFAFA),
        child: Stack(
          children: [
            // Background components
            Positioned(
              top: 175,
              left: 15,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 384,
                height: 250,
                transform: Matrix4.translationValues(
                  _selectedIndex == 0 ? 0.0 : 400.0,
                  0.0,
                  0.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x08000000),
                      offset: Offset(10, -2),
                      blurRadius: 75,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: _buildUpcomingContent(), // Your upcoming content widget
              ),
            ),

            Positioned(
              top: 175,
              left: 15,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 384,
                height: 220,
                transform: Matrix4.translationValues(
                  _selectedIndex == 1 ? 0.0 : 400.0,
                  0.0,
                  0.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x08000000),
                      offset: Offset(10, -2),
                      blurRadius: 75,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child:
                    _buildCompletedContent(), // Your completed content widget
              ),
            ),

            Positioned(
              top: 175,
              left: 15,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 384,
                height: 220,
                transform: Matrix4.translationValues(
                  _selectedIndex == 2 ? 0.0 : 400.0,
                  0.0,
                  0.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x08000000),
                      offset: Offset(10, -2),
                      blurRadius: 75,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child:
                    _buildCancelledContent(), // Your cancelled content widget
              ),
            ),

            // Your existing UI components here
            Positioned(
              top: 110,
              left: -90,
              child: Container(
                width: 600,
                height: 60,
                padding: EdgeInsets.fromLTRB(36, 20, 36, 11),
                color: Color(0xFFFAFAFA),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem(0, 'Upcoming'),
                    _buildTabItem(1, 'Completed'),
                    _buildTabItem(2, 'Cancelled'),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 72,
              left: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Transform.rotate(
                  angle: -360 * 3.14159 / 180, // Convert degrees to radians
                  child: Container(
                    width: 32, // Increase the width to make the image bigger
                    height: 32, // Increase the height to make the image bigger
                    padding: EdgeInsets.fromLTRB(1, 5.01, 1, 5.01),
                    child: Image.asset(
                      'assets/back.png', // Make sure this path is correct
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 75,
              left: 77,
              child: Text(
                'My Booking',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: Color(0xFF1D2024),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                        width: 1.0,
                        color: Colors
                            .grey[300]!), // Adjust color and width as needed
                  ),
                ),
                height: 82,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildButton(context, '/home', 'Home', 'assets/hut.svg'),
                    _buildButton(context, '/book_appointment',
                        'Book Appointment', 'assets/check-mark.svg'),
                    _buildButton(context, '/upcomingbooking', 'My Bookings',
                        'assets/schedule3.svg'),
                    _buildButton(context, '/saloon_details_page',
                        'Salon Details', 'assets/store.svg'),
                    _buildButton(
                        context, '/profile', 'Profile', 'assets/user2.svg'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: 75,
            height: 2,
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                _buildBookingCard(
                  '574827389273', // Order ID instead of dateTime
                  '2 March, 2024 - 3:00 PM', // Date instead of orderId
                  'John Doe',
                  '+91 9876543210',
                  'Massage',
                  'Sarah (Therapist)',
                ),
                // SizedBox(height: 8), // Increased space after booking card
              ],
            ),
            Positioned(
              top: 180,
              right: 95,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RescheduleServicesPage()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 6, horizontal: 8), // Adjust padding for size
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(
                        5), // Adjust border radius for rounded corners
                  ),
                  child: Text(
                    'Reschedule',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16, // Increase font size for better visibility
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  _showCancelOverlay();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 6, horizontal: 8), // Adjust padding for size
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(
                        5), // Adjust border radius for rounded corners
                  ),
                  child: Text(
                    'Cancel Appointment',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16, // Increase font size for better visibility
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, // Position the switch at the top right
              right: 0, // Position the switch at the top right
              child: Row(
                children: [
                  Text(
                    'Remind me',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D2024),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7, // Scale down the switch
                    child: Switch(
                      value: _isSwitchOn,
                      onChanged: (value) {
                        setState(() {
                          _isSwitchOn = value;
                        });
                      },
                      activeColor: Colors.blue, // Active thumb color
                      activeTrackColor:
                          Colors.blue.withOpacity(0.5), // Active track color
                      inactiveThumbColor: Colors.grey, // Inactive thumb color
                      inactiveTrackColor:
                          Colors.grey.withOpacity(0.5), // Inactive track color
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

  void _showCancelOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Container(
            width: 430,
            height: 931,
            color: Color(0xFF3B4453).withOpacity(0.5),
          ),
          Positioned(
            top: 610,
            left: 0,
            right: 0,
            child: Container(
              width: 400,
              height: 264,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(49),
                  topRight: Radius.circular(49),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Cancel Booking',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: CustomColors.backgroundtext,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 320,
                    height: 1,
                    color: Color(0xFFD9D9D9),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      text:
                          'Are you sure you want to cancel your\nBooking/Appointment?',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      // You can add more TextSpans here if needed
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Changed to center
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/cancel_booking');
                          _overlayEntry?.remove();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.backgroundtext,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Added SizedBox for spacing
                      ElevatedButton(
                        onPressed: () {
                          _overlayEntry?.remove();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  Widget _buildCompletedContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: Colors.white, // Set background color to white
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  _buildBookingCard(
                    '574827389273',
                    '2 March, 2024 - 3:00 PM',
                    'John Doe',
                    '+91 9876543210',
                    'Massage',
                    'Sarah (Therapist)',
                  ),
                ],
              ),
              Positioned(
                top: 20,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelledContent() {
    return Container(
      // Set the background color of the container to white
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  _buildBookingCard(
                    '364827364872',
                    '1 March, 2024 - 1:30 PM',
                    'Jane Smith',
                    '+91 8765432109',
                    'Facial',
                    'Michael (Esthetician)',
                  ),
                ],
              ),
              Positioned(
                top: 20,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'Cancelled',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(String orderId, String dateTime, String customerName,
      String phoneNumber, String services, String specialist) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(10, -2),
            blurRadius: 75,
            spreadRadius: 4,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Card(
        color: Colors.white,
        elevation: 0, // Remove Card's elevation to avoid double shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'ORDER ID:', orderId), // Display orderId with label
              SizedBox(height: 4),
              Divider(color: Colors.grey[400]),
              _buildDetailRow('Date:', dateTime), // Display dateTime
              SizedBox(height: 4),
              _buildDetailRow('Customer Name:', customerName),
              SizedBox(height: 4),
              _buildDetailRow('Phone Number:', phoneNumber),
              SizedBox(height: 4),
              _buildDetailRow('Services:', services),
              SizedBox(height: 4),
              _buildDetailRow('Specialist:', specialist),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D2024),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D2024),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String routeName, String label, String svgPath) {
    bool isMyBookingsPage = routeName ==
        '/my_bookings_page'; // Check if this is the My Bookings button

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              color: isMyBookingsPage ? Colors.blue : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
              color: isMyBookingsPage ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }
}
