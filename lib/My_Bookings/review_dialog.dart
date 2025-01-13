import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ReviewDialog extends StatefulWidget {
  final VoidCallback onReviewSubmitted; // Add callback

  ReviewDialog({required this.onReviewSubmitted});

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  bool _isRatingSelected = false;

  Future<void> _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';
    final String bookingId = prefs.getString('selected_booking_id') ?? '';

    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    final requestBody = {
      "salon_id": salonID,
      "branch_id": branchID,
      "customer_id": customerId,
      "stars": _rating.toString(),
      "description": _reviewController.text,
      "booking_id": bookingId
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/raise-review/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}');
      widget.onReviewSubmitted(); // Notify the parent
    } else {
      print('Failed to submit review. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFFAFAFA),
      title: Center(
        child: Text(
          'Add Your Review',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 30.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                  _isRatingSelected = rating > 0;
                });
              },
            ),
            SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFC4C4C4)),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Icon(
                  //     Icons.reviews,
                  //     color: Color(0xFFC4C4C4),
                  //     size: 20.0,
                  //   ),
                  // ),
                  Container(
                    height: 150.0, // Adjust this height as needed
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: null, // Allow text to wrap
                      textAlignVertical:
                          TextAlignVertical.top, // Align text to the top
                      decoration: InputDecoration(
                        hintText: 'Leave your experience',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFC4C4C4),
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1D2024),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          child: Text('Cancel'),
        ),
        SizedBox(width: 8.0),
        ElevatedButton(
          onPressed: _isRatingSelected
              ? () {
                  _submitReview();
                  Navigator.of(context).pop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: _isRatingSelected ? Colors.green : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          child: Text('Submit'),
        ),
      ],
    );
  }
}
