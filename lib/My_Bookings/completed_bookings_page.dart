import 'package:flutter/material.dart';
import 'common_layout.dart';

class CompletedBookingsPage extends StatefulWidget {
  @override
  _CompletedBookingsPageState createState() => _CompletedBookingsPageState();
}

class _CompletedBookingsPageState extends State<CompletedBookingsPage> {
  String _selectedCategory = 'Completed';

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      pageTitle: 'Completed Bookings',
      selectedCategory: _selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
          // Optionally navigate to the selected category page if needed
        });
      },
      bodyContent: Container(
        color: Color(0xFFFAFAFA),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    _buildBookingCard(
                      '574827389273',
                      '2 March, 2024 - 3:00 PM',
                      'John Doe',
                      '+91 9876543210',
                      'Massage',
                      'Sarah (Therapist)',
                    ),
                  ],
                ),
                Positioned(
                  top: 20,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(String orderId, String dateTime, String customerName,
      String phoneNumber, String services, String specialist) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(10, -2),
            blurRadius: 75,
            spreadRadius: 4,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ORDER ID:', orderId),
              SizedBox(height: 4),
              Divider(color: Colors.grey[400]),
              _buildDetailRow('Date:', dateTime),
              SizedBox(height: 4),
              _buildDetailRow('Customer Name:', customerName),
              SizedBox(height: 4),
              _buildDetailRow('Phone Number:', phoneNumber),
              SizedBox(height: 4),
              _buildDetailRow('Services:', services),
              SizedBox(height: 4),
              _buildDetailRow('Specialist:', specialist),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D2024),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D2024),
            ),
          ),
        ),
      ],
    );
  }
}
