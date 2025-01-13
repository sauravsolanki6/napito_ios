import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart';

class MembershipDetailsPage extends StatefulWidget {
  final Map<String, dynamic> membershipDetails;

  const MembershipDetailsPage({
    Key? key,
    required this.membershipDetails,
  }) : super(key: key);

  @override
  _MembershipDetailsPageState createState() => _MembershipDetailsPageState();
}

class _MembershipDetailsPageState extends State<MembershipDetailsPage> {
  late Map<String, dynamic> membershipData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    membershipData = widget.membershipDetails;
    _fetchMembershipDetails();
  }

  Future<void> _fetchMembershipDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId1 = prefs.getString('customer_id');
    final customerId2 = prefs.getString('customer_id2');
    final branchId = prefs.getString('branch_id') ?? '';
    final salonId = prefs.getString('salon_id') ?? '';

    final customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    final savedMembershipId = prefs.getString('selected_membership_id') ?? '';

    final requestBody = {
      "salon_id": salonId,
      "branch_id": branchId,
      "customer_id": customerId,
      "membership_id": savedMembershipId,
    };

    final url = '${MyApp.apiUrl}customer/store-memberships/';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'true') {
        setState(() {
          membershipData = data['data'][0];
          isLoading = false;
        });
      } else {
        print('API returned an error: ${data['message']}');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _hexToColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    final int colorInt = int.parse(hexColor, radix: 16);
    return Color(colorInt).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final name = membershipData['name'] ?? 'No Name';
    final price = membershipData['price'] ?? '0.00';
    final discountText = membershipData['discount_text'] ?? '';
    final durationText = membershipData['duration_text'] ?? '';
    final description = membershipData['description'] ?? '';
    final receipt = widget.membershipDetails['receipt'];

    final backgroundColor = membershipData['background_color'] != null
        ? _hexToColor(membershipData['background_color'])
        : Color(0xFF8C75F5); // Default background color
    final textColor = membershipData['text_color'] != null
        ? _hexToColor(membershipData['text_color'])
        : Colors.white; // Default text color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Membership Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMembershipDetails,
        child: isLoading
            ? ListView(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 600,
                        maxHeight: 190,
                      ),
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    width: 60,
                                    height: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    width: 120,
                                    height: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    width: 180,
                                    height: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 190,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/crown3.svg',
                                width: 80,
                                height: 80,
                                color: textColor,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹$price',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      discountText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      durationText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}
