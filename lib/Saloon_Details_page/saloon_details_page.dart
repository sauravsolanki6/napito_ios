import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ms_salon_task/Book_appointment/select_package_details.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Saloon_Details_page/saloondetailscontroller.dart';
import 'package:ms_salon_task/Scanner/qr_code_home.dart';
import 'package:ms_salon_task/Store_Selection/store_change.dart';
import 'package:ms_salon_task/Store_Selection/store_selection.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class SaloonDetails extends StatefulWidget {
  @override
  _SaloonDetailsState createState() => _SaloonDetailsState();
}

class _SaloonDetailsState extends State<SaloonDetails> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _anotherScrollController = ScrollController();
  int selectedIndex = 0; // Track the selected menu item index
  bool showAboutUs = true;
  bool isSelected = false;
  String _address = '';
  int _currentPage = 0; // Track current page index
  String _branchName = '';
  String _storeLogo = '';
  String _instagramLink = '';
  String _facebookLink = '';
  String _youtubeLink = '';
  String _websiteLink = '';
  String _website = '';
  String _storenumber = '';
  String _image = '';
  String _storeAddress = '';
  GoogleMapController? _mapController;
  int starCount = 0; // Set the star count here
  int reviewCount = 0;
  final LatLng _center = const LatLng(
      37.7749, -122.4194); // Replace with your latitude and longitude
  final SalonDetailsController controller = SalonDetailsController();
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  late PageController _pageController; // Step 1: Add PageController
  final SalonDetailsController _controller = SalonDetailsController();
  late Future<List<String>> _galleryImages;
  late Future<List<Map<String, dynamic>>> _specialistsFuture;

  @override
  void initState() {
    super.initState();
    _fetchStoreSocials();
    // _loadStoreName();
    _fetchStoreProfile();
    _pageController = PageController(); // Step 2: Initialize PageControlle
    // Initialize futures for asynchronous data fetching
    _salonData = _controller.fetchSalonData();
    _galleryImages = _controller.fetchGalleryImages();
    _specialistsFuture = SalonDetailsController().fetchSpecialists();

    // Set up scroll synchronization
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _anotherScrollController.jumpTo(_scrollController.offset);
      }
    });
    _anotherScrollController.addListener(() {
      if (_anotherScrollController.hasClients) {
        _scrollController.jumpTo(_anotherScrollController.offset);
      }
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    // Optionally load address if needed
    _loadAddress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _anotherScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchStoreSocials() async {
    try {
      // Initialize SharedPreferences to retrieve branchID and salonID
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Set up request body
      final Map<String, String> requestBody = {
        "salon_id": salonID,
        "branch_id": branchID,
      };

      // Send POST request to store socials endpoint
      final response = await http.post(
        Uri.parse("${MyApp.apiUrl}customer/store-socials/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Debugging output
      print("Response status: ${response.statusCode}");
      print("Response body of store socials: ${response.body}");

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Check the response status as a string
        if (responseData['status'] == "true") {
          // Set values to global variables
          setState(() {
            _instagramLink = responseData['data']['instagram_link'] ?? '';
            _facebookLink = responseData['data']['facebook_link'] ?? '';
            _youtubeLink = responseData['data']['youtube_link'] ?? '';
            _websiteLink = responseData['data']['website_link'] ?? '';
          });

          // Debugging output to confirm values are set
          print("Instagram Link: $_instagramLink");
          print("Facebook Link: $_facebookLink");
          print("YouTube Link: $_youtubeLink");
          print("Website Link: $_websiteLink");
        } else {
          print("Error: ${responseData['message']}");
        }
      } else {
        print(
            "Failed to load social data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error occurred: $error");
    }
  }

  Future<void> _fetchStoreProfile() async {
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      // Initialize SharedPreferences to retrieve branchID and salonID
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Set up request body
      final Map<String, String> requestBody = {
        "salon_id": salonID,
        "branch_id": branchID,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse("${MyApp.apiUrl}customer/store-profile/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Debugging output
      print("Response status: ${response.statusCode}");
      print("Response body of store profile: ${response.body}");

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Check the response status as a string
        if (responseData['status'] == "true") {
          // Debugging before setting state
          print(
              "Branch Name from response: ${responseData['data']['branch_name']}");
          print(
              "Store Logo from response: ${responseData['data']['store_logo']}");
          print(
              "Store Address from response: ${responseData['data']['address']}");

          // Extract starCount and reviewCount and handle empty or invalid values
          int parsedStarCount =
              int.tryParse(responseData['data']['starCount'] ?? '') ?? 0;
          int parsedReviewCount =
              int.tryParse(responseData['data']['reviewCount'].toString()) ?? 0;

          setState(() {
            _branchName = responseData['data']['branch_name'] ?? '';
            _storeLogo = responseData['data']['store_logo'] ?? '';
            _storeAddress =
                responseData['data']['address'] ?? 'Default Store Address';
            starCount = parsedStarCount; // Set star count from response
            reviewCount = parsedReviewCount; // Set review count from response
          });

          // Debugging after setState
          print("Branch Name after setState: $_branchName");
          print("Store Logo after setState: $_storeLogo");
          print("Store Address after setState: $_storeAddress");
        } else {
          print("Error: ${responseData['message']}");
        }
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      // Log error with Crashlytics and error logger
      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> storeProfile",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      // Print the error for debugging
      print('Error in storeProfile: $e');
      print('Stack Trace: $stackTrace');

      // Re-throw the exception to ensure higher-level error handling
      throw Exception('Failed to fetch storeProfile: $e');
    }
  }

  // Future<void> _loadStoreName() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   final storedAddress =
  //       prefs.getString('store_address') ?? 'Address Not Available';
  //   setState(() {
  //     _storeAddress = storedAddress;
  //   });
  // }

  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    // final address = prefs.getString('salon_address') ?? 'No address available';

    setState(() {
      // _address = address;
      // _branchName = prefs.getString('store_name') ?? 'Unknown';
      // _storeLogo = prefs.getString('store_logo') ?? '';
      _website = prefs.getString('website') ?? '';
      _image = prefs.getString('image') ?? '';
      _storenumber = prefs.getString('phone_number') ?? '';
    });
    print(_image);
  }

  Future<Map<String, dynamic>>? _salonData;

  Widget buildMenuItem(String title, int index) {
    bool isSelected =
        selectedIndex == index; // Determine if this item is selected

    return GestureDetector(
      onTap: () {
        selectItem(index); // Update the selected index on tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(
                    color: CustomColors.backgroundtext,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? CustomColors.backgroundtext : Colors.black,
          ),
        ),
      ),
    );
  }

  void selectItem(int index) {
    setState(() {
      selectedIndex = index; // Update the selected index
      // Toggle showAboutUs based on the selected index
      showAboutUs = (index == 0);
    });

    // Perform any other operations based on the selected index
    switch (index) {
      case 0:
        // Handle 'About Us' tap
        break;
      case 1:
        // Handle 'Services' tap
        break;
      case 2:
        // Handle 'Packages' tap
        break;
      case 3:
        // Handle 'Gallery' tap
        break;
      case 4:
        // Handle 'Reviews' tap
        break;
    }
  }

  void _launchPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      // Handle if the URL cannot be launched (for example, if the device doesn't support calling)
      print('Could not launch $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: CustomColors.backgroundLight,
        elevation: 0, // Remove elevation
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space out children
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'My Salon',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreSwitch(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Padding for the container
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey, width: 2), // Blue border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      color: Colors.black, // Icon color set to black
                      size: 20, // Adjust the icon size if needed
                    ),
                    const SizedBox(width: 8), // Space between icon and text
                    Text(
                      'Switch Salon',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Text color set to black
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: CustomColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh for all future data fetching
          setState(() {
            _salonData = _controller.fetchSalonData();
            _galleryImages = _controller.fetchGalleryImages();
            _specialistsFuture = _controller.fetchSpecialists();
          });
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 430,
                height: 270,
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          FutureBuilder<List<String>>(
                            future: _galleryImages,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.0,
                                      left: MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                    child: Image.asset(
                                      'assets/nodata2.png', // Replace with your image path
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7, // 70% of screen height
                                      width: MediaQuery.of(context).size.width *
                                          0.7, // 70% of screen width
                                    ),
                                  ),
                                );
                              } else {
                                final images = snapshot.data!;
                                return PageView.builder(
                                  controller: _pageController,
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    final imageUrl = images[index];
                                    return imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.contain,
                                          )
                                        : Image.asset(
                                            'assets/apple.png', // Placeholder image
                                            fit: BoxFit.contain,
                                          );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<List<String>>(
                      future: _galleryImages,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final images = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (index) {
                                return _buildDotIndicator(index);
                              }),
                            ),
                          );
                        }
                        return SizedBox
                            .shrink(); // Return an empty widget if no data
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 1.0,
                      child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30), //
                            child: _storeLogo.isNotEmpty
                                ? Image.network(
                                    _storeLogo,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200, // Adjust as needed
                                  )
                                : Image.asset(
                                    'assets/apple.png', // Placeholder image
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200, // Adjust as needed
                                  ),
                          )),
                    ),
                    const SizedBox(height: 10),
                    Transform.translate(
                      offset: const Offset(60,
                          -42), // Move 10 pixels to the right and 10 pixels up
                      child: Opacity(
                        opacity: 1.0,
                        child: Container(
                          // width: 149,
                          height: 34,
                          child: Text(
                            // 'Apple Saloon',
                            _branchName,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 28.8 / 24,
                              letterSpacing: 0.02,
                              color: Color(0xFF1D2024),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -45), // Move 45 pixels up
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Opacity(
                            opacity: 1.0,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    'assets/loc1.svg',
                                    width: 16,
                                    height: 16,
                                    color: CustomColors.backgroundtext,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 272,
                                  height: 17,
                                  child: Text(
                                    _storeAddress.isNotEmpty
                                        ? _storeAddress
                                        : 'Address not available', // Placeholder text
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 16.8 / 14,
                                      letterSpacing: 0.0168,
                                      color: const Color(0xFF1D2024),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height:
                                  10), // Add spacing between address and stars
                          Row(
                            children: [
                              // Display star rating
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < starCount
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: CustomColors.stars, // Star color
                                  size: 18, // Size of the star
                                );
                              }),
                              const SizedBox(
                                  width:
                                      8), // Add spacing between stars and reviews
                              // Display review count
                              Text(
                                '($reviewCount reviews)',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF1D2024),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  5), // Optional spacing below stars and reviews
                        ],
                      ),
                    ),
                    Container(
                      width: 370,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                'Select Specialist',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 21.6 / 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: SalonDetailsController()
                            .fetchSpecialists(), // Fetch specialists from your controller
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildShimmerLoader(); // Show shimmer effect while loading
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Error: ${snapshot.error}'), // Error handling
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                  'No specialists available'), // No data scenario
                            );
                          } else {
                            final specialists = snapshot.data!;
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: specialists.length,
                              itemBuilder: (context, index) {
                                final specialist = specialists[index];
                                final imageUrl =
                                    specialist['profile_photo'] ?? '';
                                final name =
                                    specialist['employee_name'] ?? 'Unknown';
                                final designation = specialist['designation'] ??
                                    'Unknown'; // Placeholder designation

                                return Container(
                                  width:
                                      90, // Increased width to accommodate both name and designation
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape
                                              .circle, // To make it circular, like ClipOval
                                          image: imageUrl.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      imageUrl), // Dynamically load the image URL
                                                  fit: BoxFit
                                                      .cover, // Ensures the image covers the container area
                                                )
                                              : DecorationImage(
                                                  image: AssetImage(
                                                      'assets/person1.png'), // Fallback image if no URL
                                                  fit: BoxFit
                                                      .cover, // Cover the container area with the fallback image
                                                ),
                                        ),
                                        child: imageUrl.isNotEmpty
                                            ? Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipOval(
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: 80,
                                                      height: 80,
                                                      loadingBuilder: (BuildContext
                                                              context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        } else {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      (loadingProgress
                                                                              .expectedTotalBytes ??
                                                                          1)
                                                                  : null,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Center(
                                                          child: Icon(
                                                            Icons.image,
                                                            size:
                                                                40, // Size of the error icon
                                                            color: Colors
                                                                .grey, // Error icon color
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons
                                                      .person, // Default icon when there's no image URL
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        name,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        designation,
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: CustomColors
                                              .backgroundtext, // Optional: change color to differentiate
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 400,
                      height: 38,
                      decoration: BoxDecoration(
                        color: CustomColors.backgroundPrimary,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildMenuItem('About Us', 0),
                          const SizedBox(width: 60),
                          buildMenuItem('Gallery', 3),
                          const SizedBox(width: 60),
                          buildMenuItem('Reviews', 4),
                        ],
                      ),
                    ),
                    if (selectedIndex == 0)
                      FutureBuilder<Map<String, dynamic>>(
                        future:
                            _salonData, // Ensure _salonData is a Future<Map<String, dynamic>> that fetches salon details
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // return Center(
                            //   child:
                            //       CircularProgressIndicator(), // Loader while fetching data
                            // );
                            return _buildShimmerLoader3();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Center(
                              child: Text('No data available'),
                            );
                          } else {
                            final data = snapshot.data!;
                            final description = data['description'] ??
                                'No description available';
                            final phoneNumber = data['phone_number'] ??
                                'No phone number available';
                            final address =
                                data['address'] ?? 'No address available';
                            final latitude =
                                double.tryParse(data['latitude'] ?? '') ?? 0.0;
                            final longitude =
                                double.tryParse(data['longitude'] ?? '') ?? 0.0;
                            final openingHours =
                                (data['opening_hrs'] as List<dynamic>?) ?? [];

                            // Method to launch Google Maps directions
                            void _launchGoogleMaps(
                                double latitude, double longitude) async {
                              final url =
                                  'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0), // Added horizontal margin
                              padding: const EdgeInsets.fromLTRB(
                                  6, 8, 20, 8), // Added right padding of 20
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

// Inside your children list
                                children: [
                                  Text(
                                    description,
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 20.3 / 14,
                                      letterSpacing: 0.02,
                                      color: Color(0xFF1D2024),
                                    ),
                                    // maxLines: 4,
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Opening Hours',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1D2024),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: openingHours.map<Widget>((hour) {
                                      final day = hour['day'] ?? 'No day';
                                      final time = hour['time'] ?? 'No time';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    CustomColors.backgroundtext,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    day,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFF1D2024),
                                                    ),
                                                  ),
                                                  Text(
                                                    time,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFF1D2024),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Contact',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1D2024),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Only attempt to launch the phone number if it's not empty
                                      if (phoneNumber.isNotEmpty &&
                                          phoneNumber != 'Not Available') {
                                        _launchPhoneNumber(phoneNumber);
                                      }
                                    },
                                    child: Text(
                                      phoneNumber.isNotEmpty
                                          ? phoneNumber
                                          : 'Not Available',
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF1D2024),
                                        decoration: phoneNumber.isNotEmpty
                                            ? TextDecoration.underline
                                            : TextDecoration
                                                .none, // Underline if phone number is available
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Address',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1D2024),
                                    ),
                                  ),
                                  Text(
                                    address,
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF1D2024),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: double.infinity,
                                    height: 250,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(latitude, longitude),
                                        zoom: 14.0,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: MarkerId('salon'),
                                          position: LatLng(latitude, longitude),
                                          infoWindow: InfoWindow(
                                              title: 'Salon Location'),
                                        ),
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      _launchGoogleMaps(latitude, longitude);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        color: CustomColors.backgroundtext,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x08000000),
                                            offset: Offset(10, -2),
                                            blurRadius: 75,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Get directions',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: 430,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Change this value to adjust the rounding
                                      color: CustomColors.backgroundtext,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Header text at the top
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Connect with Us',
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                fontSize:
                                                    18, // Adjust font size as needed
                                                fontWeight: FontWeight
                                                    .bold, // Adjust font weight as needed
                                                color: Colors
                                                    .white, // Change color if needed
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        // Create a list of available icons with labels
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildIcon('assets/instagram.svg',
                                                _instagramLink, 'Instagram'),
                                            _buildIcon('assets/facebook1.svg',
                                                _facebookLink, 'Facebook'),
                                            _buildIcon(
                                                'assets/whatsapp.svg',
                                                _youtubeLink,
                                                'YouTube'), // Adjust label as needed
                                            _buildIcon('assets/email.svg',
                                                _websiteLink, 'Email'),
                                          ],
                                        ),
                                        const SizedBox(height: 20.0),
                                        GestureDetector(
                                          onTap: () {
                                            _launchPhoneNumber(
                                                '$phoneNumber'); // Call the phone number when clicked
                                          },
                                          child: Text(
                                            'Contact Us | $phoneNumber',
                                            style: GoogleFonts.inter(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              height: 1.21,
                                              letterSpacing: 0.02,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        const SizedBox(height: 20.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    if (selectedIndex == 3)
                      FutureBuilder<List<String>>(
                        future:
                            _galleryImages, // Ensure _galleryImages is a Future<List<String>> that fetches image URLs
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // return Center(
                            //   child:
                            //       CircularProgressIndicator(), // Loader while fetching data
                            // );
                            return _buildShimmerLoader3();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('No images available'),
                            );
                          } else {
                            final images = snapshot.data!;
                            return Align(
                              alignment: Alignment
                                  .centerLeft, // Aligns the container to the left
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        0.0), // Adjust horizontal padding to move it left
                                child: Container(
                                  width: 375,
                                  height: 550, // Adjust the height as needed
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 8),
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                    ),
                                    itemCount: images.length,
                                    itemBuilder: (context, index) {
                                      final imageUrl = images[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            _showImage(
                                                imageUrl); // Pass the image URL to the _showImage method
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    if (selectedIndex == 4)
                      Container(
                        width: 400,
                        height: 600, // Adjust the height as needed
                        padding: const EdgeInsets.fromLTRB(
                            0, 8, 20, 8), // Added right padding of 20
                        child: RefreshIndicator(
                          onRefresh: () async {
                            // Trigger a refresh by calling fetchReviews again
                            await controller.fetchReviews();
                          },
                          child: FutureBuilder<List<Review>>(
                            future: controller
                                .fetchReviews(), // Fetch reviews from the controller
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // return Center(
                                //     child:
                                //         CircularProgressIndicator()); // Loading indicator
                                return _buildShimmerLoader3();
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error: ${snapshot.error}')); // Error message
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text(
                                        'No reviews available')); // No data message
                              } else {
                                final reviews = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with review count
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16, left: 15),
                                      child: Text(
                                        'All reviews (${reviews.length})', // Display review count
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1D2024),
                                        ),
                                      ),
                                    ),
                                    // List of reviews
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.zero,
                                        itemCount: reviews.length,
                                        itemBuilder: (context, index) {
                                          final review = reviews[index];
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 16),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.white,
                                            ),
                                            child: Stack(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipOval(
                                                      child: Image.network(
                                                        review
                                                            .profilePic, // URL of the profile picture
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Icon(
                                                              Icons.error,
                                                              size:
                                                                  40); // Placeholder for errors
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            review.customerName,
                                                            style: GoogleFonts
                                                                .lato(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color(
                                                                  0xFF1D2024),
                                                            ),
                                                          ),
                                                          Row(
                                                            children:
                                                                List.generate(
                                                              5,
                                                              (index) => Icon(
                                                                Icons.star,
                                                                size: 14,
                                                                color: index <
                                                                        review
                                                                            .stars
                                                                    ? Colors
                                                                        .yellow
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            review.description,
                                                            style: GoogleFonts
                                                                .lato(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xFF1D2024),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 15, top: 10),
                                                    child: Text(
                                                      review.date,
                                                      style: GoogleFonts
                                                          .nunitoSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.3,
                                                        letterSpacing: 0.03,
                                                        color: const Color(
                                                            0xFFC4C4C4),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void launchGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(imageUrl), // Display the image from the URL
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return SizedBox(
      height: 150, // Adjust the height to match your expected content size
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of shimmer items to display
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle, // Circle shape for profile image
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Name shimmer
                  Container(
                    height: 14, // Height for name text
                    width: 80, // Width for name text
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  // Designation shimmer
                  Container(
                    height: 12, // Height for designation text
                    width: 60, // Width for designation text
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoader2() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 430,
              height: 270,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  Widget _buildIcon(String assetPath, String url, String label) {
    return url.isNotEmpty
        ? GestureDetector(
            onTap: () => _launchURL(url),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal:
                      5.5), // 5 px gap between icons (2.5 px on each side)
              child: Column(
                children: [
                  Container(
                    width: 50.0, // Diameter of the circle
                    height: 50.0, // Diameter of the circle
                    decoration: BoxDecoration(
                      color: Colors.white, // Circle color
                      shape: BoxShape.circle, // Make it circular
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        assetPath,
                        width: 30.0, // Adjust icon size
                        height: 30.0, // Adjust icon size
                        color: CustomColors.backgroundtext, // Blue icon color
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0), // Space between icon and label
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12, // Adjust font size as needed
                      fontWeight:
                          FontWeight.bold, // Adjust font weight as needed
                      color: Colors.white, // Label color
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink(); // Hide if URL is empty
  }

  Widget _buildShimmerLoader3() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.fromLTRB(6, 8, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer for description
            Container(
              width: double.infinity,
              height: 20, // Height for the description
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
            ),
            // Shimmer for opening hours title
            Container(
              width: 120,
              height: 20, // Height for the title
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 4),
            ),
            // Shimmer for opening hours
            for (int i = 0; i < 3; i++) // Assuming 3 opening hours
              Container(
                width: double.infinity,
                height: 16, // Height for each opening hour
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
            // Add shimmer for phone number and address if needed
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 2),
            ),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            _currentPage == index ? CustomColors.backgroundtext : Colors.grey,
      ),
    );
  }
}
