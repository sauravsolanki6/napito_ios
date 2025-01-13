import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/my_bookings.dart';
import 'package:ms_salon_task/Payment/review_summary.dart';

class SelectDateTime extends StatefulWidget {
  @override
  _SelectDateTimeState createState() => _SelectDateTimeState();
}

class _SelectDateTimeState extends State<SelectDateTime> {
  bool isSelected = false;
  bool _isSubmitted = false;
  int _selectedMonthIndex = 0;

  List<String> months = [
    'March 2024',
    'April 2024',
    'May 2024',
    'June 2024',
    'July 2024',
    'August 2024',
  ];

  List<String> dates = List.generate(31, (index) => '${index + 1}');
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<String> specialists = [
    'assets/model.png',
    'assets/model.png',
    'assets/model.png',
    'assets/model.png',
    'assets/model.png',
    'assets/model.png',
  ];

  List<String> specialistNames = [
    'Dr. Smith',
    'Dr. Johnson',
    'Dr. Williams',
    'Dr. Brown',
    'Dr. Jones',
    'Dr. Garcia',
  ];

  // Track selected time slot
  String _selectedTimeSlot = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              'Select Date and Time',
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20,
                        left: 0,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/calendar1.png',
                              width: 22,
                              height: 22,
                              gaplessPlayback: true,
                              excludeFromSemantics: true,
                              alignment: Alignment.center,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Select Date',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 70,
                        left: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                setState(() {
                                  if (_selectedMonthIndex > 0) {
                                    _selectedMonthIndex--;
                                  }
                                });
                              },
                            ),
                            Container(
                              width: 271.62,
                              height: 70.62,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        List.generate(dates.length, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedMonthIndex = index;
                                          });
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: _selectedMonthIndex == index
                                                ? CustomColors.backgroundtext
                                                : Colors.white,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                dates[index],
                                                style: TextStyle(
                                                  color: _selectedMonthIndex ==
                                                          index
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                days[index % 7],
                                                style: TextStyle(
                                                  color: _selectedMonthIndex ==
                                                          index
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                setState(() {
                                  if (_selectedMonthIndex < months.length - 1) {
                                    _selectedMonthIndex++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: CustomColors.backgroundtext, width: 0.5),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0x0A000000),
                                offset: Offset(10, -2),
                                blurRadius: 75,
                                spreadRadius: 4,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                months[_selectedMonthIndex],
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: CustomColors.backgroundtext,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: CustomColors.backgroundtext),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 155,
                        left: 15,
                        child: Container(
                          width: 372,
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFD3D6DA),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 350,
                        left: 15,
                        child: Container(
                          width: 372,
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFD3D6DA),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 360,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'Available Time Slot',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 390,
                        left: 100,
                        right: 100,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: CustomColors.backgroundtext, width: 0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _selectedTimeSlot,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CustomColors.backgroundtext,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 430,
                        left: 15,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'Morning',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'Afternoon',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Text(
                                'Evening',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 460,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                _buildTimeSlot('08:00 AM'),
                                const SizedBox(height: 8),
                                _buildTimeSlot('09:00 AM'),
                                const SizedBox(height: 8),
                                _buildTimeSlot('10:00 AM'),
                              ],
                            ),
                            Column(
                              children: [
                                _buildTimeSlot('12:00 PM'),
                                const SizedBox(height: 8),
                                _buildTimeSlot('01:00 PM'),
                                const SizedBox(height: 8),
                                _buildTimeSlot('02:00 PM'),
                              ],
                            ),
                            Column(
                              children: [
                                _buildTimeSlot('05:00 PM'),
                                const SizedBox(height: 8),
                                _buildTimeSlot('06:00 PM'),
                                const SizedBox(height: 8),
                                _buildTimeSlot('07:00 PM'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Next Step and Back Buttons
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: CustomColors.backgroundtext),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.backgroundtext,
                        ),
                      ),
                    ),
                    // Next Step Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewSummary(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            CustomColors.backgroundtext, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Next Step',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build time slots
  Widget _buildTimeSlot(String time) {
    bool isSelected = time == _selectedTimeSlot;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeSlot = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected
                  ? CustomColors.backgroundtext
                  : CustomColors.backgroundtext,
              width: 0.5),
          borderRadius: BorderRadius.circular(5),
          color: isSelected ? CustomColors.backgroundtext : Colors.white,
        ),
        child: Text(
          time,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : CustomColors.backgroundtext,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
