import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ms_salon_task/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HairstylesPage extends StatefulWidget {
  @override
  _HairstylesPageState createState() => _HairstylesPageState();
}

class _HairstylesPageState extends State<HairstylesPage> {
  bool isLoading = true;
  List<String> maleImages = [];
  List<String> femaleImages = [];
  String selectedGender = 'female';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');

    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    final requestBody = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
    });

    final url = '${Config.apiUrl}customer/catlogue/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == "true") {
          setState(() {
            maleImages = List<String>.from(jsonResponse['data']['male']);
            femaleImages = List<String>.from(jsonResponse['data']['female']);
            selectedGender =
                jsonResponse['data']['customer_gender'] ?? 'female';
          });
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  void _toggleGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding:
              EdgeInsets.symmetric(horizontal: 16), // Add horizontal padding
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // Padding around the image
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final itemCount =
        isPortrait ? 2 : 4; // Adjust number of columns based on orientation

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
              'Gallery',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth,
              margin: EdgeInsets.all(16),
              child: Stack(
                children: [],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CustomColors.backgroundtext,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x00000008),
                    offset: Offset(15, 15),
                    blurRadius: 90,
                    spreadRadius: 4,
                  ),
                ],
              ),
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleGender('male'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedGender == 'male'
                              ? CustomColors.backgroundtext
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Male',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: selectedGender == 'male'
                                    ? Colors.white
                                    : CustomColors.backgroundtext,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleGender('female'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedGender == 'female'
                              ? CustomColors.backgroundtext
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Female',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: selectedGender == 'female'
                                    ? Colors.white
                                    : CustomColors.backgroundtext,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Grey line below the buttons
            Container(
              width: MediaQuery.of(context).size.width *
                  0.9, // Set the width to 90% of the screen width
              height: 1, // Set a small height to make it visible
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.08,
                  right: MediaQuery.of(context).size.width *
                      0.08), // Set horizontal margin to 8% of screen width
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFD3D6DA), // Set the border color
                    width: 0.5, // Set the border width
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? _buildSkeleton()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width *
                            0.01, // Adjust the multiplier for desired padding
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: itemCount,
                          childAspectRatio: 1,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: selectedGender == 'male'
                            ? maleImages.length
                            : femaleImages.length,
                        itemBuilder: (context, index) {
                          String imageUrl = selectedGender == 'male'
                              ? maleImages[index]
                              : femaleImages[index];
                          return GestureDetector(
                            onTap: () {
                              _showFullScreenImage(imageUrl);
                            },
                            child: Card(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
