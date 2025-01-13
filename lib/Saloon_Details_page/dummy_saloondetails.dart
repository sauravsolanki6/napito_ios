import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ms_salon_task/Book_appointment/select_package_details.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Saloon_Details_page/saloondetailscontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SaloonDetails extends StatefulWidget {
  @override
  _SaloonDetailsState createState() => _SaloonDetailsState();
}

class _SaloonDetailsState extends State<SaloonDetails> {
  int selectedIndex = 0; // Track the selected menu item index
  bool showAboutUs = true;
  bool isSelected = false;
  String _address = '';
  String _branchName = '';
  String _storeLogo = '';
  String _website = '';
  String _storenumber = '';
  String _image = '';
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(
      37.7749, -122.4194); // Replace with your latitude and longitude

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  final SalonDetailsController _controller = SalonDetailsController();
  late Future<List<String>> _galleryImages;
  late Future<List<Map<String, dynamic>>> _specialistsFuture;
  @override
  void initState() {
    super.initState();
    _salonData = _controller.fetchSalonData();
    _galleryImages = _controller.fetchGalleryImages();
    _specialistsFuture = SalonDetailsController().fetchSpecialists();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('salon_address') ?? 'No address available';

    setState(() {
      _address = address;
      _branchName = prefs.getString('branch_name') ?? 'Unknown';
      _storeLogo = prefs.getString('store_logo') ?? '';
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
          style: TextStyle(
            fontFamily: 'Lato',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0, // Remove elevation
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              'My Salon',
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
        color: Color(0xFFFAFAFA),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 430,
                height: 270,
                child: FutureBuilder<List<String>>(
                  future: _galleryImages,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child:
                            CircularProgressIndicator(), // Loader while fetching data
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No images available'),
                      );
                    } else {
                      final images = snapshot.data!;
                      return PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final imageUrl = images[index];
                          final isFirstImage =
                              index == 0; // Check if this is the first image
                          final isLastImage = index ==
                              images.length -
                                  1; // Check if this is the last image

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit
                                            .contain, // Maintain aspect ratio
                                      )
                                    : Image.asset(
                                        'assets/apple.png', // Placeholder image
                                        fit: BoxFit
                                            .contain, // Maintain aspect ratio
                                      ),
                              ),
                              if (!isFirstImage) // Show the back arrow only if it's not the first image
                                Positioned(
                                  left: 10,
                                  top: 120,
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                              if (!isLastImage) // Show the forward arrow only if it's not the last image
                                Positioned(
                                  right: 10,
                                  top: 120,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    }
                  },
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
                      offset: const Offset(50,
                          -42), // Move 10 pixels to the right and 10 pixels up
                      child: Opacity(
                        opacity: 1.0,
                        child: Container(
                          width: 149,
                          height: 34,
                          child: Text(
                            // 'Apple Saloon',
                            _branchName,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontFamily: 'Lato',
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
                                    _address.isNotEmpty
                                        ? _address
                                        : 'Address not available', // Placeholder text
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 16.8 / 14,
                                      letterSpacing: 0.0168,
                                      color: Color(0xFF1D2024),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // const SizedBox(height: 10),
                          // Align(
                          //   alignment:
                          //       Alignment.centerLeft, // Align to the left side
                          //   child: Opacity(
                          //     opacity: 1.0,
                          //     child: Container(
                          //       width: 145,
                          //       height: 19.8,
                          //       child: const Text(
                          //         '★★★★★ (200 Reviews)',
                          //         textAlign: TextAlign.center,
                          //         style: TextStyle(
                          //           fontFamily: 'Lato',
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.w400,
                          //           height: 20.3 / 14,
                          //           color: CustomColors.backgroundtext,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // Transform.translate(
                    //   offset: const Offset(0, -10), // Move 10 pixels up
                    //   child: Row(
                    //     mainAxisAlignment:
                    //         MainAxisAlignment.start, // Align items to the right
                    //     children: [
                    //       Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           GestureDetector(
                    //             onTap: () async {
                    //               final Uri url = Uri.parse(
                    //                   _website); // Replace _website with the variable holding your URL

                    //               // Check if the URL can be launched
                    //               if (await canLaunchUrl(url)) {
                    //                 await launchUrl(url); // Launch the URL
                    //               } else {
                    //                 print(
                    //                     'Could not launch $_website'); // Handle the case where the URL can't be launched
                    //               }
                    //             },
                    //             child: Container(
                    //               width: 30,
                    //               height: 30,
                    //               child: SvgPicture.asset(
                    //                 'assets/chrome22.svg',
                    //                 width: 16,
                    //                 height: 16,
                    //                 color: CustomColors.backgroundtext,
                    //               ),
                    //             ),
                    //           ),

                    //           const SizedBox(
                    //               height: 5), // Space between image and text
                    //           Container(
                    //             width: 34,
                    //             height: 17,
                    //             child: const Text(
                    //               'Website',
                    //               textAlign: TextAlign.left,
                    //               style: TextStyle(
                    //                 fontFamily: 'Lato',
                    //                 fontSize: 10,
                    //                 fontWeight: FontWeight.w400,
                    //                 height: 12 / 10,
                    //                 letterSpacing: 0.0168,
                    //                 color: Color(0xFF1D2024),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(
                    //           width: 75), // Space between the two sets
                    //       GestureDetector(
                    //         onTap: () async {
                    //           final Uri phoneUri = Uri(
                    //             scheme: 'tel',
                    //             path:
                    //                 _storenumber, // Replace _storenumber with the actual phone number variable
                    //           );

                    //           // Check if the phone URI can be launched
                    //           if (await canLaunchUrl(phoneUri)) {
                    //             await launchUrl(
                    //                 phoneUri); // Launch the dialer with the phone number
                    //           } else {
                    //             // Handle the error if the URI cannot be launched
                    //             print('Could not launch $phoneUri');
                    //             // Optionally, show a user-friendly message here
                    //           }
                    //         },
                    //         child: Column(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Container(
                    //               width: 30,
                    //               height: 30,
                    //               child: SvgPicture.asset(
                    //                 'assets/call3.svg',
                    //                 width: 16,
                    //                 height: 16,
                    //                 color: CustomColors.backgroundtext,
                    //               ),
                    //             ),
                    //             const SizedBox(
                    //                 height: 5), // Space between image and text
                    //             Container(
                    //               width: 15,
                    //               height: 17,
                    //               child: const Text(
                    //                 'Call',
                    //                 textAlign: TextAlign.left,
                    //                 style: TextStyle(
                    //                   fontFamily: 'Lato',
                    //                   fontSize: 10,
                    //                   fontWeight: FontWeight.w400,
                    //                   height: 12 / 10,
                    //                   letterSpacing: 0.0168,
                    //                   color: Color(0xFF1D2024),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),

                    //       const SizedBox(
                    //           width: 85), // Space between the two sets
                    //       Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Container(
                    //             width: 30,
                    //             height: 30,
                    //             child: SvgPicture.asset(
                    //               'assets/share3.svg',
                    //               width: 16,
                    //               height: 16,
                    //               // ignore: deprecated_member_use
                    //               color: CustomColors.backgroundtext,
                    //             ),
                    //           ),
                    //           const SizedBox(
                    //               height: 5), // Space between image and text
                    //           Container(
                    //             width: 25,
                    //             height: 17,
                    //             child: const Text(
                    //               'Share',
                    //               textAlign: TextAlign.left,
                    //               style: TextStyle(
                    //                 fontFamily: 'Lato',
                    //                 fontSize: 10,
                    //                 fontWeight: FontWeight.w400,
                    //                 height: 12 / 10,
                    //                 letterSpacing: 0.0168,
                    //                 color: Color(0xFF1D2024),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(
                    //           width: 85), // Space between the two sets
                    //       Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Container(
                    //             width: 32,
                    //             height: 32,
                    //             child: SvgPicture.asset(
                    //               'assets/review3.svg',
                    //               width: 16,
                    //               height: 16,
                    //               color: CustomColors.backgroundtext,
                    //             ),
                    //           ),
                    //           const SizedBox(
                    //               height: 5), // Space between image and text
                    //           Container(
                    //             width: 30,
                    //             height: 17,
                    //             child: const Text(
                    //               'Review',
                    //               textAlign: TextAlign.left,
                    //               style: TextStyle(
                    //                 fontFamily: 'Lato',
                    //                 fontSize: 10,
                    //                 fontWeight: FontWeight.w400,
                    //                 height: 12 / 10,
                    //                 letterSpacing: 0.0168,
                    //                 color: Color(0xFF1D2024),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    Container(
                      width: 370,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFD3D6DA),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Select Specialist',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 21.6 / 18,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                        height: 120,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: SalonDetailsController()
                              .fetchSpecialists(), // Fetch specialists from your controller
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child:
                                      CircularProgressIndicator()); // Loading indicator
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error: ${snapshot.error}')); // Error handling
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text(
                                      'No specialists available')); // No data scenario
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
                                  final designation =
                                      specialist['designation'] ??
                                          'Unknown'; // Placeholder designation

                                  return Container(
                                    width:
                                        120, // Increased width to accommodate both name and designation
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            image: imageUrl.isNotEmpty
                                                ? DecorationImage(
                                                    image:
                                                        NetworkImage(imageUrl),
                                                    fit: BoxFit.cover,
                                                    onError: (_, __) => AssetImage(
                                                        'assets/avatar.png'), // Fallback on error
                                                  )
                                                : null,
                                          ),
                                          child: imageUrl.isNotEmpty
                                              ? Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey[200],
                                                      child: Icon(Icons.person,
                                                          color:
                                                              Colors.grey[600]),
                                                    );
                                                  },
                                                )
                                              : CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  child: Icon(Icons.person,
                                                      color: Colors.grey[600]),
                                                ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          designation,
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors
                                                .grey, // Optional: change color to differentiate
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
                        )),
                    const SizedBox(height: 20),
                    Container(
                      width: 380,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildMenuItem('About Us', 0),
                            const SizedBox(width: 80),
                            buildMenuItem('Gallery', 3),
                            const SizedBox(width: 80),
                            buildMenuItem('Reviews', 4),
                          ],
                        ),
                      ),
                    ),
                    if (selectedIndex == 0)
                      FutureBuilder<Map<String, dynamic>>(
                        future:
                            _salonData, // Ensure _salonData is a Future<Map<String, dynamic>> that fetches salon details
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child:
                                  CircularProgressIndicator(), // Loader while fetching data
                            );
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
                              width: 385,
                              height: 550, // Adjust the height as needed
                              padding: const EdgeInsets.fromLTRB(
                                  6, 8, 20, 8), // Added right padding of 20
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 20.3 / 14,
                                      letterSpacing: 0.02,
                                      color: Color(0xFF1D2024),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // const SizedBox(height: 8),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     // Implement 'Read more...' functionality if needed
                                  //   },
                                  //   child: const Text(
                                  //     'Read more...',
                                  //     style: TextStyle(
                                  //       fontFamily: 'Lato',
                                  //       fontSize: 14,
                                  //       fontWeight: FontWeight.w600,
                                  //       color: CustomColors.backgroundtext,
                                  //     ),
                                  //   ),
                                  // ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Opening Hours',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1D2024),
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
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFF1D2024),
                                                    ),
                                                  ),
                                                  Text(
                                                    time,
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
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
                                  const Text(
                                    'Contact',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1D2024),
                                    ),
                                  ),
                                  Text(
                                    phoneNumber,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF1D2024),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Address',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1D2024),
                                    ),
                                  ),
                                  Text(
                                    address,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF1D2024),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 360,
                                    height: 170,
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
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _launchGoogleMaps(latitude, longitude);
                                      },
                                      child: Container(
                                        width: 360,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          color: CustomColors.backgroundtext,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x08000000),
                                              offset: Offset(10, -2),
                                              blurRadius: 75,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 8),
                                            Text(
                                              'Get directions',
                                              style: TextStyle(
                                                fontFamily: 'Lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                            _galleryImages, // Ensure _galleryData is a Future<List<String>> that fetches image URLs
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child:
                                  CircularProgressIndicator(), // Loader while fetching data
                            );
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
                            return Container(
                              width: 375,
                              height: 550, // Adjust the height as needed
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 8),
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
                        child: Stack(
                          children: [
                            // Positioned(
                            //   top:
                            //       30, // Adjusted top position to ensure visibility within the container
                            //   left: 10, // Specified left position
                            //   child: Container(
                            //     width:
                            //         350, // Width to accommodate both text and stars
                            //     height: 21, // Specified height
                            //     child: Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         const Text(
                            //           'Write your review',
                            //           style: TextStyle(
                            //             fontFamily:
                            //                 'Lato', // Specified font-family
                            //             fontSize: 14, // Specified font-size
                            //             fontWeight: FontWeight
                            //                 .w400, // Specified font-weight
                            //             height: 1.2,
                            //             color: Colors
                            //                 .black, // Specified line-height
                            //           ),
                            //         ),
                            //         Row(
                            //           children: List.generate(
                            //             5,
                            //             (index) => const Icon(
                            //               Icons
                            //                   .star_border, // Outline star icon
                            //               size: 14, // Adjusted star size
                            //               color: Colors
                            //                   .grey, // Adjusted star color
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // New Box with Label, Gallery Icon, and Send Icon added below the "Write your review" text
                            // Positioned(
                            //   top: 70,
                            //   left: 10,
                            //   child: Container(
                            //     width: 360,
                            //     height: 48,
                            //     decoration: const BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.only(
                            //         topLeft: Radius.circular(8),
                            //         topRight: Radius.circular(8),
                            //         bottomLeft: Radius.circular(8),
                            //         bottomRight: Radius.circular(8),
                            //       ),
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Color(0x14000000),
                            //           offset: Offset(0, 4),
                            //           blurRadius: 14,
                            //         ),
                            //       ],
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 16),
                            //       child: Row(
                            //         children: [
                            //           Image.asset(
                            //             'assets/gallery1.png',
                            //             width: 20,
                            //             height: 20,
                            //           ),
                            //           const SizedBox(width: 10),
                            //           Expanded(
                            //             child: TextField(
                            //               decoration: InputDecoration(
                            //                 hintText: 'Leave your experience',
                            //                 hintStyle: TextStyle(
                            //                   fontFamily: 'Lato',
                            //                   fontSize: 14,
                            //                   fontWeight: FontWeight.w400,
                            //                   color: Color(0xFFC4C4C4),
                            //                 ),
                            //                 border: InputBorder.none,
                            //               ),
                            //               style: TextStyle(
                            //                 fontFamily: 'Lato',
                            //                 fontSize: 14,
                            //                 fontWeight: FontWeight.w400,
                            //                 color: Color(0xFF1D2024),
                            //               ),
                            //             ),
                            //           ),
                            //           GestureDetector(
                            //             onTap: () {
                            //               // Implement send functionality
                            //             },
                            //             child: Image.asset(
                            //               'assets/send3.png',
                            //               width: 20,
                            //               height: 20,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            // Text for "All reviews (200)" added below the "Leave your experience" container
                            const Positioned(
                              top:
                                  10, // Adjusted top position to place it just below the previous container
                              left: 15,
                              child: Text(
                                'All reviews (200)',
                                style: TextStyle(
                                  fontFamily: 'Lato', // Specified font-family
                                  fontSize: 16, // Specified font-size
                                  fontWeight:
                                      FontWeight.w600, // Specified font-weight
                                  height:
                                      1.2, // Line-height calculated as font-size * 1.2
                                  color: Color(0xFF1D2024), // Specified color
                                ),
                              ),
                            ),
                            // New box with dp.png, "Shraddha Kapoor", and 5-star rating
                            Positioned(
                              top:
                                  40, // Adjusted top position to place it just below the "All reviews (200)" text
                              left: 15,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/dp.png', // Ensure the path to the image is correct
                                    width: 40, // Adjust width as needed
                                    height: 40, // Adjust height as needed
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Space between the image and the text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Shraddha Kapoor',
                                        style: TextStyle(
                                          fontFamily:
                                              'Lato', // Specified font-family
                                          fontSize: 14, // Specified font-size
                                          fontWeight: FontWeight
                                              .w600, // Specified font-weight
                                          color: Color(
                                              0xFF1D2024), // Specified color
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => const Icon(
                                                Icons.star, // Filled star icon
                                                size: 14, // Adjusted star size
                                                color: Colors
                                                    .yellow, // Adjusted star color
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  5), // Space between stars and "2 days ago" text
                                          const Text(
                                            '2 days ago',
                                            style: TextStyle(
                                              fontFamily:
                                                  'Nunito Sans', // Specified font-family
                                              fontSize:
                                                  12, // Specified font-size
                                              fontWeight: FontWeight
                                                  .w400, // Specified font-weight
                                              height: 1.3, // Line-height
                                              letterSpacing:
                                                  0.03, // Specified letter-spacing
                                              color: Color(
                                                  0xFFC4C4C4), // Specified color
                                              // Specified text-align
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              10), // Increased space between stars and the review text
                                      const Text(
                                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the',
                                        style: TextStyle(
                                          fontFamily:
                                              'Lato', // Specified font-family
                                          fontSize: 14, // Specified font-size
                                          fontWeight: FontWeight
                                              .w400, // Specified font-weight
                                          color: Color(
                                              0xFF1D2024), // Specified color
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Other children widgets can be added here
                          ],
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
}
