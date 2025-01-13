// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Profile/about.dart';
import 'package:ms_salon_task/Profile/invite_friends.dart';
import 'package:ms_salon_task/Profile/privacy.dart';
import 'package:ms_salon_task/Profile/profile.dart';
import 'package:ms_salon_task/Raise_Ticket/all_visits.dart';
import 'package:ms_salon_task/Raise_Ticket/sos.dart';
import 'package:ms_salon_task/Raise_Ticket/your_tickets.dart';
import 'package:ms_salon_task/offers%20and%20membership/customer_packages.dart';
import 'package:ms_salon_task/offers%20and%20membership/membership.dart';
import 'package:ms_salon_task/offers%20and%20membership/offers.dart';
import 'package:ms_salon_task/offers%20and%20membership/store_packages.dart';
import 'package:ms_salon_task/terms&condi/terms_conditions.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Make sure to import the SosPage

class Sidebar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final bool isOpen;

  // ignore: use_super_parameters
  const Sidebar({
    Key? key,
    required this.onMenuTap,
    required this.isOpen,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isReviewExpanded = false;
  bool isSettingsExpanded = false;
  String _storeName = 'Default Store Name'; // Add this line

  @override
  void initState() {
    super.initState();
    _loadStoreName(); // Load store name when the widget initializes
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
        left: widget.isOpen ? 0 : -276,
        right: widget.isOpen ? 0 : 276,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CustomColors.backgroundtext,
            border: Border(
              right: BorderSide(
                color: Colors.grey.withOpacity(0.5), // Adjust color as needed
                width: .0, // Adjust width as needed
              ),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CustomColors.backgroundtext,
              border: Border(
                right: BorderSide(
                  color: Colors.grey.withOpacity(0.5), // Adjust color as needed
                  width: 1.0, // Adjust width as needed
                ),
              ),
            ),
            child: Container(
              color: CustomColors.backgroundtext,
              width: 255,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with Apple salon and image
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(90, 80, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Use the maxLines and overflow properties for truncation
                              Text(
                                _storeName, // Use the dynamic store name here
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1, // Limits the text to one line
                                overflow: TextOverflow
                                    .ellipsis, // Adds "..." if the text overflows
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Sky Max Mall, Viman Nagar,\nPune, 411001',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: 0.0168,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 70,
                          left: 20,
                          child: Image.asset(
                            'assets/apple.png', // Replace with your image path
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 92),
                    // White container below Sky Max Mall text for About Us
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => About()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/application.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'About us',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    110), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // // Other sections with GestureDetector for tapping
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => InviteFriends()),
                    //     );
                    //   },
                    //   child: Container(
                    //     color: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 20),
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: SvgPicture.asset(
                    //             'assets/gift.svg',
                    //             width: 20,
                    //             height: 20,
                    //             color: const Color(0xFF353B43),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 10),
                    //         const Text(
                    //           'Refer & Earn',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Lato',
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //             height: 16.8 / 14,
                    //             letterSpacing: 0.02,
                    //             color: Color(0xFF424752),
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //             width:
                    //                 85), // Adjust spacing between text and icon
                    //         const Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: Colors.black,
                    //           size: 16,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // Repeat the above GestureDetector and Container for other sections as needed

                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle the tap action here
                    //     print('Review tapped');
                    //   },
                    //   child: Container(
                    //     color: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 20),
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: SvgPicture.asset(
                    //             'assets/review1.svg',
                    //             width: 20,
                    //             height: 20,
                    //             color: const Color(0xFF353B43),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 10),
                    //         const Text(
                    //           'Review',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Lato',
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //             height: 16.8 / 14,
                    //             letterSpacing: 0.02,
                    //             color: Color(0xFF424752),
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //             width:
                    //                 125), // Adjust spacing between text and icon
                    //         const Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: Colors.black,
                    //           size: 16,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Membership()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/crown.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Membership',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    85), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerPackagesPage()),
                          //  builder: (context) => StorePackagePage()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/crown.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Packages     ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    85), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Offers()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/offer1.svg',
                                width: 20,
                                height: 20,
                                // ignore: duplicate_ignore
                                // ignore: deprecated_member_use
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Offers & Deals',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    72), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle the tap action here
                    //     print('Settings tapped');
                    //   },
                    //   child: Container(
                    //     color: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 20),
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: SvgPicture.asset(
                    //             'assets/settings.svg',
                    //             width: 20,
                    //             height: 20,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 10),
                    //         const Text(
                    //           'Settings',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Lato',
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //             height: 16.8 / 14,
                    //             letterSpacing: 0.02,
                    //             color: Color(0xFF424752),
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //             width:
                    //                 118), // Adjust spacing between text and icon
                    //         const Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: Colors.black,
                    //           size: 16,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        // Handle the tap action here
                        print('Application Tutorial tapped');
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/tutorial.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Application Tutorial',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    33), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicy()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/privacy2.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Privacy Policy',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    75), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermsConditions()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/terms.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Terms Condition',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    55), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle the tap action here
                    //     print('Refer & Earn tapped');
                    //   },
                    //   child: Container(
                    //     color: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 20),
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: SvgPicture.asset(
                    //             'assets/exclamation.svg',
                    //             width: 20,
                    //             height: 20,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 10),
                    //         const Text(
                    //           'Report an Issue',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Lato',
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //             height: 16.8 / 14,
                    //             letterSpacing: 0.02,
                    //             color: Color(0xFF424752),
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //             width:
                    //                 62), // Adjust spacing between text and icon
                    //         const Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: Colors.black,
                    //           size: 16,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllTicket()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/help3.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Raise a Complaint',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    145), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => AllTicket()),
                    //     );
                    //   },
                    //   child: Container(
                    //     color: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 20),
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: SvgPicture.asset(
                    //             'assets/help3.svg',
                    //             width: 20,
                    //             height: 20,
                    //             color: const Color(0xFF424752),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 10),
                    //         const Text(
                    //           'Your Tickets',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Lato',
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //             height: 16.8 / 14,
                    //             letterSpacing: 0.02,
                    //             color: Color(0xFF424752),
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //             width:
                    //                 145), // Adjust spacing between text and icon
                    //         const Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: Colors.black,
                    //           size: 16,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SvgPicture.asset(
                                'assets/user2.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Profile',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 16.8 / 14,
                                letterSpacing: 0.02,
                                color: Color(0xFF424752),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    130), // Adjust spacing between text and icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
