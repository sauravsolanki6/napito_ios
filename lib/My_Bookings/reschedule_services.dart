import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/UpcomingPage.dart';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:ms_salon_task/My_Bookings/reschedule_calender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ms_salon_task/My_Bookings/my_bookings.dart';
import 'package:ms_salon_task/My_Bookings/select_data_time.dart';

class RescheduleServicesPage extends StatefulWidget {
  @override
  _RescheduleServicesPageState createState() => _RescheduleServicesPageState();
}

class _RescheduleServicesPageState extends State<RescheduleServicesPage> {
  bool _isSubmitted = false;
  bool _isLoading = true;
  Map<String, dynamic>? _bookingData;

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingJson = prefs.getString('selected_booking_json');
    if (bookingJson != null) {
      setState(() {
        _bookingData = json.decode(bookingJson);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadBookingData();
  }

  void _submitReschedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RescheduleCalender()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingData = _bookingData;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookAppointmentPage(),
        //   ),
        // );
        // Navigate to SDateTime when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UpcomingPage(),
          ),
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpcomingPage(),
                    ),
                  );
                  // Navigator.pop(context);
                },
              ),
              Text(
                'Reschedule Your Services',
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: _isLoading
              ? _buildSkeletonLoader(context)
              : bookingData == null
                  ? Center(child: Text('No booking data found'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You Have Selected',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${bookingData['services_text']}',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: CustomColors.backgroundtext,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            itemCount: bookingData['services']?.length ?? 0,
                            itemBuilder: (context, index) {
                              final service = bookingData['services'][index];
                              return ServiceItem(
                                serviceName: service['service_name'] ??
                                    'No Service Name',
                                stylist: service['stylist'] ?? 'No Stylist',
                                serviceFrom: service['service_from'] ?? 'N/A',
                                serviceTo: service['service_to'] ?? 'N/A',
                                duration: service['duration'] ?? 'N/A',
                                price: (double.tryParse(
                                            service['price']?.toString() ??
                                                '0') ??
                                        0)
                                    .toStringAsFixed(2),
                                discount: (double.tryParse(
                                            service['discount']?.toString() ??
                                                '0') ??
                                        0)
                                    .toStringAsFixed(2),
                                finalPrice: (double.tryParse(
                                            service['final_price']
                                                    ?.toString() ??
                                                '0') ??
                                        0)
                                    .toStringAsFixed(2),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpcomingPage(),
                                    ),
                                  );
                                  // Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: CustomColors.backgroundtext,
                                      width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.015,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.06),
                                ),
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.backgroundtext,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _submitReschedule();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.backgroundtext,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.015,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.06),
                                ),
                                child: Text(
                                  'Reschedule',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.02),
          child: Container(
            width: double.infinity,
            height: screenHeight * 0.25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(0x00000008),
                  offset: Offset(15, 15),
                  blurRadius: 90,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonText(screenWidth * 0.6, 20),
                  SizedBox(height: 10),
                  _buildSkeletonText(screenWidth * 0.8, 15),
                  SizedBox(height: 10),
                  _buildSkeletonText(screenWidth * 0.5, 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonText(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String serviceName;
  final String stylist;
  final String serviceFrom;
  final String serviceTo;
  final String duration;
  final String price;
  final String discount;
  final String finalPrice;

  const ServiceItem({
    Key? key,
    required this.serviceName,
    required this.stylist,
    required this.serviceFrom,
    required this.serviceTo,
    required this.duration,
    required this.price,
    required this.discount,
    required this.finalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x00000008),
              offset: Offset(15, 15),
              blurRadius: 90,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424752),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Stylist: $stylist',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 107, 107, 107),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'From: $serviceFrom',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 20), // Space between 'From' and 'To'
                  Text(
                    'To: $serviceTo',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Price: \₹$finalPrice',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.backgroundtext,
                ),
              ),
              // const SizedBox(height: 10),
              // Text(
              //   'Discount: \$$discount',
              //   style: const TextStyle(
              //     fontFamily: 'Lato',
              //     fontSize: 15,
              //     fontWeight: FontWeight.w400,
              //     color: Colors.grey,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // Text(
              //   'Final Price: \$$finalPrice',
              //   style: const TextStyle(
              //     fontFamily: 'Lato',
              //     fontSize: 15,
              //     fontWeight: FontWeight.w400,
              //     color: Colors.grey,
              //   ),
              // ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.timer, // Stopwatch icon
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    '$duration minutes',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
