import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming you have these pages defined somewhere
import 'package:ms_salon_task/Profile/about.dart';
import 'package:ms_salon_task/Profile/privacy.dart';
import 'package:ms_salon_task/Profile/profile.dart';
import 'package:ms_salon_task/Raise_Ticket/all_visits.dart';
import 'package:ms_salon_task/Raise_Ticket/your_tickets.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages.dart';
import 'package:ms_salon_task/offers%20and%20membership/membership.dart';
import 'package:ms_salon_task/offers%20and%20membership/offers.dart';
import 'package:ms_salon_task/terms&condi/terms_conditions.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final bool isOpen;

  const Sidebar({
    Key? key,
    required this.onMenuTap,
    required this.isOpen,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _storeName = 'Default Store Name';

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('store_name') ?? 'Default Store Name';
    setState(() {
      _storeName = storedName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: 0,
      bottom: 0,
      left: widget.isOpen ? 0 : -350,
      right: widget.isOpen ? 0 : 350,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2, 0),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              color: CustomColors.backgroundtext,
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _storeName,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Sky Max Mall, Viman Nagar,\nPune, 411001',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem(
                      iconPath: 'assets/application.svg',
                      text: 'About us',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => About()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/crown.svg',
                      text: 'Membership',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Membership()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/crown.svg',
                      text: 'Packages',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomerPackagesPage()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/offer1.svg',
                      text: 'Offers & Deals',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Offers()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/tutorial.svg',
                      text: 'Application Tutorial',
                      onTap: () => print('Application Tutorial tapped'),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/privacy2.svg',
                      text: 'Privacy Policy',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicy()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/terms.svg',
                      text: 'Terms Condition',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsConditions()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/help3.svg',
                      text: 'Raise a Complaint',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllTicket()),
                      ),
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/user2.svg',
                      text: 'Profile',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate icon size based on screen width
    final double iconSize = screenWidth * 0.06;
    final double textSize = screenWidth * 0.04;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // Responsive horizontal padding
              vertical: screenWidth * 0.03, // Responsive vertical padding
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Push items to edges
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      width: iconSize,
                      height: iconSize,
                      color: const Color(0xFF424752),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      text,
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF424752),
                        letterSpacing: 0.02,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: iconSize * 0.7, // Scale icon size based on screen size
                  color: const Color(0xFF424752),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8), // Add spacing between menu items
      ],
    );
  }
}
