import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/offers%20and%20membership/membership_details_page.dart';
import 'package:ms_salon_task/offers%20and%20membership/membershippayment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../main.dart';
import 'membershipcontroller.dart'; // Import the membership controller file
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for handling URLs
import 'dart:convert';
import 'package:http/http.dart' as http;

class Membership extends StatefulWidget {
  @override
  _MembershipState createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  final MembershipController _membershipController = MembershipController();
  List<dynamic> _memberships = [];
  Map<String, dynamic>? _membershipDetails;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _hasMembershipDetails = false; // Flag to track membership details

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchMembershipDetails();
  }

  void _fetchData() async {
    await _membershipController.fetchMembershipData().then((_) {
      setState(() {
        _memberships = _membershipController.memberships;
      });
    });
  }

  void _showSuccessDialog() {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           SvgPicture.asset(
    //             'assets/crown.svg', // Path to your crown SVG file
    //             width: 100,
    //             height: 100,
    //             color: const CustomColors.backgroundtext,
    //           ),
    //           SizedBox(height: 20),
    //           Text('Membership purchased successfully!'),
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           child: Text('OK'),
    //           onPressed: () {
    //             // Navigator.of(context).pop();
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => Membership(),
    //               ),
    //             );
    //             _onRefresh(); // Refresh the page
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void _fetchMembershipDetails() async {
    try {
      final response = await _membershipController.fetchMembershipDetails();

      if (response != null) {
        // Check if the response is valid and contains data
        if (response.isNotEmpty) {
          setState(() {
            _membershipDetails = response;
            _hasMembershipDetails =
                true; // Set flag to true if details are fetched
          });
        } else {
          // Data is empty but response is not null
          setState(() {
            _membershipDetails = {}; // Clear or set empty map if needed
            _hasMembershipDetails =
                false; // Set flag to false if no details are found
          });
        }
      } else {
        // Response is null
        setState(() {
          _membershipDetails = {}; // Clear or set empty map if needed
          _hasMembershipDetails =
              false; // Set flag to false if no details are found
        });
      }
    } catch (e) {
      print('Error fetching membership details: $e');
      setState(() {
        _membershipDetails = {}; // Clear or set empty map if needed
        _hasMembershipDetails = false; // Set flag to false if there is an error
      });
    }
  }

  void _onRefresh() async {
    _fetchData();
    _fetchMembershipDetails();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // This will navigate back to the first occurrence of `HomePage` in the stack
        // Navigator.of(context).pop((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    title: '',
                  )),
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop((route) => route.isFirst);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        title: '',
                      ),
                    ),
                  );
                },
              ),
              Text(
                'Membership',
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
          color: CustomColors.backgroundPrimary,
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Conditionally display Current Membership section
                  if (_hasMembershipDetails && _membershipDetails != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Current Membership',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    MembershipDetailsCard(
                      details: _membershipDetails!,
                    ),
                    SizedBox(height: 20),
                  ],

                  // Display Buy Memberships label
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 16.0, vertical: 8.0),
                  //   child: Text(
                  //     'Buy Membership',
                  //     style: GoogleFonts.lato(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),

                  // Display shimmer effect or membership cards
                  _memberships.isEmpty
                      ? ListView.builder(
                          itemCount: 5, // Number of shimmer placeholders
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                height: 150,
                              ),
                            );
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Buy Memberships label
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Buy Membership',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: 10, // Reduced vertical padding
                              ),
                            ),
                            ..._memberships.map((membership) {
                              final backgroundColor = Color(int.parse(
                                  membership['background_color']
                                      .replaceFirst('#', '0xff')));
                              final textColor = Color(int.parse(
                                  membership['text_color']
                                      .replaceFirst('#', '0xff')));
                              return MembershipCard(
                                backgroundColor: backgroundColor,
                                title: membership['name'],
                                validity: membership['duration_text'],
                                description: membership['discount_text'],
                                price: '₹${membership['price']}',
                                membershipId:
                                    membership['membership_id'].toString(),
                                onPressed: (membershipId) async {
                                  await _membershipController
                                      .buyMembership(membershipId);
                                  _showSuccessDialog();
                                },
                                onCardTap: () {
                                  print(
                                      'Card tapped for membership ID: ${membership['membership_id']}');
                                },
                                onShowSuccessDialog: _showSuccessDialog,
                                gstAmount:
                                    _convertToDouble(membership['gst_amount']),
                                gstRate: _convertToDouble(
                                    membership['salon_gst_rate']),
                                isGstApplicable:
                                    membership['is_gst_applicable'] == '1',
                                regPrice: _convertToDouble(
                                    membership['original_price']),
                              );
                            }).toList(),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double? _convertToDouble(dynamic value) {
  if (value is String) {
    return double.tryParse(value);
  } else if (value is num) {
    return value.toDouble();
  }
  return null;
}

class MembershipCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String validity;
  final String description;
  final String price;
  final String membershipId;
  final Function(String) onPressed;
  final Function() onCardTap;
  final double? gstAmount;
  final double? gstRate;
  final bool? isGstApplicable;
  final double? regPrice;
  final VoidCallback onShowSuccessDialog;
  const MembershipCard({
    Key? key,
    required this.backgroundColor,
    required this.title,
    required this.validity,
    required this.description,
    required this.price,
    required this.membershipId,
    required this.onPressed,
    required this.onCardTap,
    required this.onShowSuccessDialog,
    this.gstAmount,
    this.gstRate,
    this.isGstApplicable,
    this.regPrice,
  }) : super(key: key);

  Future<void> _handleCardTap(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_membership_id', membershipId);

    print('Selected Membership ID: $membershipId');
    print('Membership Title: $title');
    print('Validity: $validity');
    print('Description: $description');
    print('Price: $price');
    print('GST Amount: ${gstAmount?.toString() ?? 'N/A'}');
    print('GST Rate: ${gstRate?.toString() ?? 'N/A'}');
    print(
        'Is GST Applicable: ${isGstApplicable != null ? (isGstApplicable! ? 'Yes' : 'No') : 'N/A'}');
    print('Registration Price: ${regPrice?.toString() ?? 'N/A'}');

    onCardTap();
  }

  void _showConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Purchase'),
          content: Text('Are you sure you want to buy this membership?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();

                onPressed(membershipId);

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('membershipId', membershipId);
                await prefs.setString('membershipTitle', title);
                await prefs.setString('membershipValidity', validity);
                await prefs.setString('membershipDescription', description);
                await prefs.setString('membershipPrice', price);

                if (gstRate != null) {
                  await prefs.setString('gstRate', gstRate.toString());
                } else {
                  await prefs.setString('gstRate', 'null');
                }

                if (gstAmount != null) {
                  await prefs.setString('gstAmt', gstAmount.toString());
                } else {
                  await prefs.setString('gstAmt', 'null');
                }

                if (regPrice != null) {
                  await prefs.setString('regPrice', regPrice.toString());
                } else {
                  await prefs.setString('regPrice', 'null');
                }
                if (isGstApplicable != null) {
                  await prefs.setString(
                      'isGstApplicable', isGstApplicable.toString());
                } else {
                  await prefs.setString('isGstApplicable', 'null');
                }

                onShowSuccessDialog();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MembershipPayment(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _buyMembership(String membershipId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('branch_id') ?? '';
    final salonId = prefs.getString('salon_id') ?? '';
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');

    final customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty || branchId.isEmpty || salonId.isEmpty) {
      print('Missing required parameters.');
      return;
    }
    final errorLogger = ErrorLogger();
    const membershipDetailsUrl = '${MyApp.apiUrl}customer/membership/';
    try {
      final response = await http.post(
        Uri.parse(membershipDetailsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'salon_id': salonId,
          'branch_id': branchId,
          'customer_id': customerId,
          'membership_id': membershipId,
        }),
      );

      print('Response: ${response.body}');

      final responseData = json.decode(response.body);
      if (responseData['data']['is_member'] == '1') {
        _showReplaceMembershipDialog(context);
      } else {
        onShowSuccessDialog();
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      final customerId1 = prefs.getString('customer_id');
      final customerId2 = prefs.getString('customer_id2');

      final customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty || branchID.isEmpty || salonID.isEmpty) {
        print('Missing required parameters.');
        return null;
      }
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);
      await errorLogger.setCustomerId(customerId);
      await errorLogger.setMembershipId(membershipId);

      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> buymembership",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error in buymembership: $e');
      print('Stack Trace: $stackTrace');
      print('Error during API call: $e');
    }
  }

// New method to show the replace membership dialog
  void _showReplaceMembershipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Replace Existing Membership'),
          content: Text(
              'You already have an existing membership. Do you want to replace it?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onShowSuccessDialog(); // Call the success dialog callback
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => _handleCardTap(context),
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          margin: EdgeInsets.only(left: 0, bottom: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/crowns.png',
                                  width: screenWidth * 0.25,
                                  height: screenHeight * 0.12,
                                  fit: BoxFit.contain,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () =>
                                      _showConfirmationDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Color(0xFF0982A7),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    minimumSize: Size(
                                      screenWidth * 0.2,
                                      screenHeight * 0.035,
                                    ),
                                    side: BorderSide.none,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                  ).copyWith(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  child: Text(
                                    'BUY NOW',
                                    style: GoogleFonts.lato(
                                      fontSize: screenWidth *
                                          0.03, // Adjusted font size for smaller button
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.35,
                        top: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            validity,
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            description,
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            price,
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MembershipDetailsCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const MembershipDetailsCard({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final name = details['membership_details']['name'] ?? 'No Name';
    final price = details['membership_details']['price'] ?? '0.00';
    final serviceDiscount =
        details['membership_details']['service_discount'] ?? '0';
    final productDiscount =
        details['membership_details']['product_discount'] ?? '0';
    final membershipStart =
        details['membership_details']['membership_start'] ?? 'Unknown';
    final discountType = details['membership_details']['discount_type'] ??
        '0'; // Extract discount type
    final membershipEnd =
        details['membership_details']['membership_end'] ?? 'Unknown';
    final receipt = details['membership_details']['receipt'];
    // Extract the dynamic background color
    final backgroundColor =
        details['membership_details']['background_color'] ?? '#8C75F5';
    final TextColor = details['membership_details']['text_color'] ?? '#8C75F5';

    // Convert the hex color string to Color
    Color hexToColor(String hexString) {
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF$hexString'; // Add alpha value if missing
      }
      return Color(int.parse('0x$hexString'));
    }

    String formatDiscount(String discount, String type) {
      return type == '0' ? '$discount%' : '₹$discount';
    }

    return Center(
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.2,
        margin: EdgeInsets.only(bottom: 20, top: 10),
        decoration: BoxDecoration(
          color: hexToColor(backgroundColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'ACTIVE MEMBER',
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.03,
              top: screenHeight * 0.02,
              child: Image.asset(
                'assets/crowns.png', // Path to your PNG image
                width: screenWidth * 0.22,
                height: screenHeight * 0.12,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: screenWidth * 0.3,
              top: screenHeight * 0.02,
              child: Container(
                width: screenWidth * 0.4, // Limit the width to prevent overflow
                child: Text(
                  name,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.3,
              top: screenHeight * 0.07,
              child: Text(
                '₹$price',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.3,
              top: screenHeight * 0.10,
              child: Text(
                'Service Discount: ${formatDiscount(serviceDiscount, discountType)}',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.3,
              top: screenHeight * 0.13,
              child: Text(
                'Product Discount: ${formatDiscount(productDiscount, discountType)}',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start: $membershipStart',
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.03,
                        color: Color(0xFF8C75F5),
                      ),
                    ),
                    Text(
                      'End: $membershipEnd',
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.03,
                        color: Color(0xFF8C75F5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (receipt != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => launch(receipt),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.link,
                          color: Color(0xFF8C75F5),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'View Receipt',
                          style: GoogleFonts.lato(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF8C75F5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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




//for showing memberhship card for the current only and if not there thenn
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: CustomColors.backgroundLight,
//         elevation: 0,
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             Text(
//               'Membership',
//               style: TextStyle(
//                 fontFamily: 'Lato',
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         color: CustomColors.backgroundPrimary,
//         child: SmartRefresher(
//           controller: _refreshController,
//           onRefresh: _onRefresh,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Display MembershipDetailsCard if details are available
//               if (_hasMembershipDetails && _membershipDetails != null) ...[
//                 MembershipDetailsCard(
//                   details: _membershipDetails!,
//                 ),
//                 SizedBox(height: 20),
//               ] else ...[
//                 // Display shimmer effect or membership cards if no details are available
//                 Expanded(
//                   child: _memberships.isEmpty
//                       ? ListView.builder(
//                           itemCount: 5, // Number of shimmer placeholders
//                           itemBuilder: (context, index) {
//                             return Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 margin: EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 height: 120,
//                               ),
//                             );
//                           },
//                         )
//                       : SingleChildScrollView(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: screenWidth * 0.05,
//                                   vertical: 10, // Reduced vertical padding
//                                 ),
//                               ),
//                               ..._memberships.map((membership) {
//                                 final backgroundColor = Color(int.parse(
//                                     membership['background_color']
//                                         .replaceFirst('#', '0xff')));
//                                 final textColor = Color(int.parse(
//                                     membership['text_color']
//                                         .replaceFirst('#', '0xff')));
//                                 return MembershipCard(
//                                   backgroundColor: backgroundColor,
//                                   title: membership['name'],
//                                   validity: membership['duration_text'],
//                                   description: membership['discount_text'],
//                                   price: '₹${membership['price']}',
//                                   membershipId: membership['membership_id']
//                                       .toString(), // Pass the membership ID
//                                   onPressed: (membershipId) async {
//                                     await _membershipController.buyMembership(
//                                         membershipId); // Call buyMembership
//                                   },
//                                   onCardTap: () {},
//                                   onShowSuccessDialog: _showSuccessDialog,
//                                 );
//                               }).toList(),
//                             ],
//                           ),
//                         ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }show both of them always both membrhsips current and buy