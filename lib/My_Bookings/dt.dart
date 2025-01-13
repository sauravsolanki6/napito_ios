// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ms_salon_task/Colors/custom_colors.dart';
// import 'package:ms_salon_task/My_Bookings/reschedule_services.dart';
// import 'package:ms_salon_task/Payment/review_summary.dart';
// import 'package:ms_salon_task/select_specialist.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
// import 'api_service.dart'; // Import the ApiService

// class SDateTime extends StatefulWidget {
//   @override
//   _SelectDateTimeState createState() => _SelectDateTimeState();
// }

// class _SelectDateTimeState extends State<SDateTime> {
//   TextEditingController _dateController = TextEditingController();
//   String _selectedTimeSlot = '';
//   String _selectedTimeSlotTo = '';
//   String _selectedTime = '';
//   final ApiService _apiService = ApiService();
//   DateTime? _minDate;
//   DateTime? _maxDate;
//   Timer? _debounceTimer;
//   final Duration _debounceDuration =
//       Duration(milliseconds: 300); // Adjust as needed

//   Map<String, List<dynamic>> _timeSlots = {
//     'morning_slots': [],
//     'afternoon_slots': [],
//     'evening_slots': []
//   }; // Store time slots categorized by periods
//   bool _isLoading = true; // Manage loading state
//   bool _hasMoreSlots = true; // To check if there are more slots to load
//   int _offset = 0; // Pagination offset

//   @override
//   void initState() {
//     super.initState();
//     _fetchBookingRules();
//     _loadSelectedTimeSlot();
//     _initializePage();
//   }

//   Future<void> _initializePage() async {
//     final prefs = await SharedPreferences.getInstance();

//     // Fetch the previously selected date from SharedPreferences
//     final storedDate = prefs.getString('selected_date');

//     final today = DateTime.now();
//     final formattedToday = DateFormat('dd-MM-yyyy').format(today);

//     // Set the date controller based on whether a stored date is found
//     if (storedDate != null) {
//       _dateController.text = storedDate;
//     } else {
//       _dateController.text = formattedToday;
//       // Save today's date to SharedPreferences if no date is stored
//       await prefs.setString('selected_date', formattedToday);
//     }

//     // Fetch time slots for the current or stored date
//     await _fetchTimeSlots(offset: _offset);
//   }

//   Future<void> _loadSelectedTimeSlot() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedTimeSlot = prefs.getString('selected_time_slot');
//     if (storedTimeSlot != null) {
//       final parts = storedTimeSlot.split('|');
//       if (parts.length == 2) {
//         setState(() {
//           _selectedTimeSlot = parts[0]; // From time
//           _selectedTimeSlotTo = parts[1]; // To time
//         });
//       } else {
//         print('Stored time slot format is invalid.');
//       }
//     }
//   }

//   Future<void> _saveSelectedTimeSlot(String from, String to) async {
//     final prefs = await SharedPreferences.getInstance();
//     // Combine from and to times with a delimiter
//     final timeSlot = '$from-$to';
//     await prefs.setString('selected_time_slot', timeSlot);
//     print('Saved time slot to SharedPreferences: $timeSlot');
//   }

//   Future<void> _fetchBookingRules() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//       final response = await _apiService.fetchBookingRules();
//       print('Raw Response: $response');

//       if (response != null && response is Map<String, dynamic>) {
//         final daysBeforeBookingString =
//             response['days_before_booking'] as String?;
//         print('days_before_booking value: $daysBeforeBookingString');

//         if (daysBeforeBookingString != null) {
//           final daysBeforeBooking = int.tryParse(daysBeforeBookingString) ?? 0;
//           final now = DateTime.now();
//           setState(() {
//             _minDate = now;
//             _maxDate = now.add(Duration(days: daysBeforeBooking));
//           });
//         } else {
//           print('days_before_booking is missing or null.');
//         }
//       } else {
//         print('Invalid response format.');
//       }
//     } catch (e) {
//       print('Error: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchTimeSlots({int offset = 0}) async {
//     if (_dateController.text.isNotEmpty) {
//       final formattedDate = _dateController.text;

//       // Cancel any previous debounce timer
//       _debounceTimer?.cancel();

//       _debounceTimer = Timer(_debounceDuration, () async {
//         try {
//           // Fetch time slots with the current offset
//           final newSlots =
//               await _apiService.fetchTimeSlots(formattedDate, offset);

//           setState(() {
//             // Append new slots to the existing ones
//             if (newSlots['morning_slots'] != null) {
//               _timeSlots['morning_slots']?.addAll(newSlots['morning_slots']);
//             }
//             if (newSlots['afternoon_slots'] != null) {
//               _timeSlots['afternoon_slots']
//                   ?.addAll(newSlots['afternoon_slots']);
//             }
//             if (newSlots['evening_slots'] != null) {
//               _timeSlots['evening_slots']?.addAll(newSlots['evening_slots']);
//             }

//             // Determine if there are more slots to load
//             _hasMoreSlots = newSlots['morning_slots']?.isNotEmpty ??
//                 false || newSlots['afternoon_slots']?.isNotEmpty ??
//                 false || newSlots['evening_slots']?.isNotEmpty ??
//                 false;

//             if (_hasMoreSlots) {
//               _offset += 18; // Update offset for the next load
//             } else {
//               _offset = 0; // Reset offset if no more slots
//             }
//           });
//         } catch (e) {
//           print('Error fetching time slots: $e');
//         }
//       });
//     }
//   }

//   Future<void> _onDateSelected(DateTime date) async {
//     final formattedDate = DateFormat('dd-MM-yyyy').format(date);
//     setState(() {
//       _dateController.text = formattedDate;
//       _offset = 0; // Reset offset when date is changed
//       _isLoading = true;
//       // Reset the time slots for the new date
//       _timeSlots = {
//         'morning_slots': [],
//         'afternoon_slots': [],
//         'evening_slots': []
//       };
//     });
//     await _fetchTimeSlots(offset: _offset);
//     setState(() {
//       _isLoading = false;
//     });

//     // Save the selected date to SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_date', formattedDate);
//     print('Saved date to SharedPreferences: $formattedDate');
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _isLoading = true; // Show loading indicator
//     });

//     try {
//       // Fetch booking rules again
//       await _fetchBookingRules();

//       // If a date is already selected, fetch time slots again
//       if (_dateController.text.isNotEmpty) {
//         // Reset the time slots
//         setState(() {
//           _timeSlots = {
//             'morning_slots': [],
//             'afternoon_slots': [],
//             'evening_slots': []
//           };
//           _offset = 0; // Reset offset
//           _hasMoreSlots = true; // Ensure more slots can be fetched
//         });
//         await _fetchTimeSlots(offset: _offset);
//       }
//     } finally {
//       setState(() {
//         _isLoading = false; // Hide loading indicator
//       });
//     }
//   }

//   Widget _buildTimeSlot(
//       String from, String to, bool isVacant, bool isSelected) {
//     return GestureDetector(
//       onTap: isVacant
//           ? () {
//               setState(() {
//                 // Toggle selection
//                 if (_selectedTimeSlot == from) {
//                   _selectedTimeSlot = ''; // Deselect if already selected
//                   _selectedTimeSlotTo = ''; // Clear selected time
//                 } else {
//                   _selectedTimeSlot = from; // Select the new time slot
//                   _selectedTimeSlotTo = to; // Store both "from" and "to" times
//                 }

//                 // Save the selected time slot
//                 _saveSelectedTimeSlot(_selectedTimeSlot, _selectedTimeSlotTo);
//               });
//             }
//           : null, // Disable the tap gesture if not vacant
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
//         margin: EdgeInsets.symmetric(vertical: 5),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color:
//                 isSelected ? CustomColors.backgroundtext : Colors.transparent,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(5),
//           color: isVacant
//               ? (isSelected ? CustomColors.backgroundtext : Colors.green)
//               : Colors.red,
//           boxShadow: [
//             if (!isSelected && isVacant)
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 1,
//                 blurRadius: 4,
//                 offset: Offset(0, 2), // changes position of shadow
//               ),
//           ],
//         ),
//         child: Text(
//           from, // Display only the "from" time
//           style: TextStyle(
//             fontFamily: 'Lato',
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: isVacant
//                 ? (isSelected ? Colors.white : Colors.white)
//                 : Colors.white,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeSlots(String period, List<dynamic> slots) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           period,
//           style: TextStyle(
//             fontFamily: 'Lato',
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: 10),
//         if (slots.isNotEmpty)
//           Container(
//             padding: EdgeInsets.all(10),
//             child: Column(
//               children: slots.map<Widget>((slot) {
//                 final from = slot['from'] as String;
//                 final to = slot['to'] as String; // Ensure 'to' is used
//                 final isVacant = slot['is_vacent'] == '1';
//                 final isSelected = from == _selectedTimeSlot;

//                 return _buildTimeSlot(from, to, isVacant, isSelected);
//               }).toList(),
//             ),
//           )
//         else
//           SizedBox.shrink(), // If there are no slots, show nothing
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: CustomColors.backgroundPrimary,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: CustomColors.backgroundLight,
//         elevation: 0,
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             Text(
//               'Select Date and Time',
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
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: NotificationListener<ScrollNotification>(
//           onNotification: (ScrollNotification scrollInfo) {
//             if (!_isLoading &&
//                 _hasMoreSlots &&
//                 scrollInfo.metrics.pixels ==
//                     scrollInfo.metrics.maxScrollExtent) {
//               _fetchTimeSlots(
//                   offset:
//                       _offset); // Fetch more time slots when scrolled to bottom
//               return true;
//             }
//             return false;
//           },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: () async {
//                           if (_minDate != null && _maxDate != null) {
//                             final DateTime initialDate =
//                                 DateTime.now().isBefore(_minDate!)
//                                     ? _minDate!
//                                     : DateTime.now();
//                             final DateTime? picked = await showDatePicker(
//                               context: context,
//                               initialDate: initialDate,
//                               firstDate: _minDate!,
//                               lastDate: _maxDate!,
//                             );
//                             if (picked != null) {
//                               _onDateSelected(picked);
//                             }
//                           } else {
//                             print(
//                                 'Unable to select date. Please wait until the booking rules are loaded.');
//                           }
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _dateController.text.isEmpty
//                                     ? 'Booking Date'
//                                     : _dateController.text,
//                                 style: TextStyle(
//                                   fontFamily: 'Lato',
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Icon(Icons.calendar_today_outlined,
//                                   color: Colors.black),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Container(
//                         height: 1,
//                         color: Colors.grey[300],
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Available Time Slots',
//                         style: TextStyle(
//                           fontFamily: 'Lato',
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: CustomColors
//                                 .backgroundtext, // Blue border color
//                             width: 2, // Border width
//                           ),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           'Selected Time $_selectedTimeSlot',
//                           style: TextStyle(
//                             fontFamily: 'Lato',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: CustomColors.backgroundtext,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       if (_isLoading)
//                         Center(
//                             child:
//                                 CircularProgressIndicator()) // Show loading indicator while fetching data
//                       else if (_timeSlots.values
//                           .any((slots) => slots.isNotEmpty)) ...[
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if ((_timeSlots['morning_slots'] ?? []).isNotEmpty)
//                               Expanded(
//                                 child: _buildTimeSlots('Morning Slots',
//                                     _timeSlots['morning_slots'] ?? []),
//                               ),
//                             if ((_timeSlots['afternoon_slots'] ?? [])
//                                 .isNotEmpty)
//                               Expanded(
//                                 child: _buildTimeSlots('Afternoon Slots',
//                                     _timeSlots['afternoon_slots'] ?? []),
//                               ),
//                             if ((_timeSlots['evening_slots'] ?? []).isNotEmpty)
//                               Expanded(
//                                 child: _buildTimeSlots('Evening Slots',
//                                     _timeSlots['evening_slots'] ?? []),
//                               ),
//                           ],
//                         ),
//                         if (_hasMoreSlots)
//                           Center(
//                               child:
//                                   CircularProgressIndicator()), // Show loading indicator while fetching more slots
//                         if (!_hasMoreSlots)
//                           Center(
//                             child: Text(
//                               'No more slots available',
//                               style: TextStyle(
//                                 fontFamily: 'Lato',
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                       ] else ...[
//                         Center(child: CircularProgressIndicator()),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: CustomColors.backgroundPrimary,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => RescheduleServicesPage(),
//                   ),
//                 );
//                 // Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: CustomColors.backgroundtext, // Text color
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4), // Button shape
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//               child: Text(
//                 'Back',
//                 style: TextStyle(
//                   fontFamily: 'Lato',
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_selectedTimeSlot.isEmpty) {
//                   // Show error SnackBar if no time slot is selected
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content:
//                           Text('Please select a time slot before proceeding.'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 } else {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SpecialistPage(),
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     CustomColors.backgroundtext, // Background color
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4), // Button shape
//                 ),
//               ),
//               child: Text(
//                 'Next Step',
//                 style: TextStyle(
//                   fontFamily: 'Lato',
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
