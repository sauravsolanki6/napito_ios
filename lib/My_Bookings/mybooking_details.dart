import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'review_dialog.dart'; // Ensure this import matches your file structure

class BookingDetailsPage extends StatefulWidget {
  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late Future<Map<String, dynamic>> _bookingDetails;
  String? _bookingId;

  @override
  void initState() {
    super.initState();
    _loadBookingId();
  }

  Future<void> _loadBookingId() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingId1 = prefs.getString('selected_booking_id');
    final bookingId2 = prefs.getString('selected_booking_id2');

    final bookingId = bookingId1 ?? bookingId2;

    if (bookingId != null) {
      setState(() {
        _bookingId = bookingId;
        _bookingDetails = _fetchBookingDetails(bookingId);
      });
    } else {
      setState(() {
        _bookingDetails = Future.error('No booking ID found');
      });
    }
  }

  Future<void> _refreshBookingDetails() async {
    if (_bookingId != null) {
      setState(() {
        _bookingDetails = _fetchBookingDetails(_bookingId!);
      });
    }
  }

  Future<Map<String, dynamic>> _fetchBookingDetails(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final salonID = prefs.getString('salon_id') ?? '';
    final branchID = prefs.getString('branch_id') ?? '';
    final customerID = prefs.getString('customer_id') ?? '';

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}customer/booking-details/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'salon_id': salonID,
        'branch_id': branchID,
        'customer_id': customerID,
        'booking_id': bookingId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['status'] == 'true') {
        final bookingList = data['data'] as List<dynamic>;
        if (bookingList.isNotEmpty) {
          final bookingDetails = bookingList[0] as Map<String, dynamic>;
          // Add is_review_submitted to the booking details
          bookingDetails['is_review_submitted'] =
              data['data'][0]['is_review_submitted'];
          return bookingDetails;
        } else {
          throw Exception('No booking details found');
        }
      } else {
        throw Exception('Failed to load booking details');
      }
    } else {
      throw Exception('Failed to load booking details');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  TextStyle _getStatusTextStyle(String status, bool isPaymentStatus) {
    if (isPaymentStatus) {
      switch (status) {
        case 'Paid':
          return TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
        case 'Pending':
          return TextStyle(color: Colors.orange, fontWeight: FontWeight.bold);
        case 'Failed':
          return TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
        default:
          return TextStyle(color: Colors.black54);
      }
    } else {
      switch (status) {
        case 'Completed':
          return TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
        case 'Pending':
          return TextStyle(color: Colors.orange, fontWeight: FontWeight.bold);
        case 'Cancelled':
          return TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
        default:
          return TextStyle(color: Colors.black54);
      }
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReviewDialog(
          onReviewSubmitted: () {
            // Refresh the booking details or update UI after review is submitted
            _refreshBookingDetails();
          },
        );
      },
    );
  }

  // Helper function to check if the value is a valid double and greater than 0
  bool isValidAmount(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final parsedValue = double.tryParse(value);
    return parsedValue != null && parsedValue > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Booking Details', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_bookingDetails != null) // Ensure _bookingDetails is not null
            FutureBuilder<Map<String, dynamic>>(
              future: _bookingDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(); // Placeholder while waiting for the data
                } else if (snapshot.hasData) {
                  final isReviewSubmitted =
                      snapshot.data?['is_review_submitted'] == '1';
                  return isReviewSubmitted
                      ? SizedBox() // Hide button if review is already submitted
                      : Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0), // Right padding
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: CustomColors
                                  .backgroundtext, // White text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Border radius of 5
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0), // Padding inside the button
                            ),
                            onPressed: _showReviewDialog,
                            child: Text(
                              'Add Review',
                              style: TextStyle(
                                  fontSize: 16), // Text size set to 12
                            ),
                          ),
                        );
                } else {
                  return SizedBox(); // Placeholder in case of error or no data
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookingDetails,

// Update the FutureBuilder with the following checks
        child: FutureBuilder<Map<String, dynamic>>(
          future: _bookingDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 16)),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text('No details found',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              );
            } else {
              final data = snapshot.data!;
              final services = data['services'] as List<dynamic>? ?? [];
              final receiptUrl = data['receipt'] as String?;
              final bookingStatus = data['booking_status_text'] as String;
              final paymentStatus = data['payment_status_text'] as String;

// Handling all discount details, and formatting numerical values to 2 decimal places
              final allDiscountDetails = data['all_discount_details'] != null
                  ? _formatDiscountDetails(data['all_discount_details'])
                  : {};

              final appliedMembershipDetails =
                  data['applied_membership_details'] != null
                      ? _formatDiscountDetails(
                          data['applied_membership_details'])
                      : {};

              final appliedOfferDetails = data['applied_offer_details'] != null
                  ? _formatDiscountDetails(data['applied_offer_details'])
                  : {};

              final appliedCouponDetails =
                  data['applied_coupon_details'] != null
                      ? _formatDiscountDetails(data['applied_coupon_details'])
                      : {};

              final appliedGiftcardDetails =
                  data['applied_giftcard_details'] != null
                      ? _formatDiscountDetails(data['applied_giftcard_details'])
                      : {};

              final appliedRewardDetails =
                  data['applied_reward_details'] != null
                      ? _formatDiscountDetails(data['applied_reward_details'])
                      : {};

// Function to format the discount values to two decimal points

              return Padding(
                padding: EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data['ref_id'] != null &&
                                    data['ref_id'] != 0)
                                  _buildDetailRow('Booking ID', data['ref_id']),
                                if (data['booking_date'] != null &&
                                    data['from'] != null &&
                                    data['to'] != null)
                                  _buildDetailRow('Date & Time',
                                      '${data['booking_date']} ${data['from']} - ${data['to']}'),
                                if (data['stylists_text'] != null &&
                                    data['stylists_text'].isNotEmpty)
                                  _buildDetailRow(
                                      'Specialist', data['stylists_text']),
                                if (isValidAmount(bookingStatus))
                                  _buildDetailRow(
                                      'Booking Status', bookingStatus,
                                      isStatus: true),
                                if (isValidAmount(paymentStatus))
                                  _buildDetailRow(
                                      'Payment Status', paymentStatus,
                                      isStatus: true),
                                if (isValidAmount(data['total_service_price']))
                                  _buildDetailRow('Services Price',
                                      '₹${data['total_service_price']}'),
                                if (isValidAmount(data['total_product_price']))
                                  _buildDetailRow('Total Product Price',
                                      '₹${data['total_product_price']}'),
                                if (isValidAmount(
                                    allDiscountDetails['mem_service_discount']
                                        ?.toString()))
                                  _buildDetailRow('Membership Service Discount',
                                      '₹${allDiscountDetails['mem_service_discount']}'),
                                if (isValidAmount(
                                    data['total_discount_amount']))
                                  _buildDetailRow('Total Discount Amount',
                                      '₹${data['total_discount_amount']}'),
                                if (isValidAmount(appliedMembershipDetails[
                                        'product_discount_amount']
                                    ?.toString()))
                                  _buildDetailRow('Membership Product Discount',
                                      '₹${appliedMembershipDetails['product_discount_amount']}'),
                                if (isValidAmount(
                                    appliedCouponDetails['discount_amount']
                                        ?.toString()))
                                  _buildDetailRow('Coupon Discount Amount',
                                      '₹${appliedCouponDetails['discount_amount']}'),
                                if (isValidAmount(
                                    appliedOfferDetails['discount_amount']
                                        ?.toString()))
                                  _buildDetailRow('Offer Discount Amount',
                                      '₹${appliedOfferDetails['discount_amount']}'),
                                if (isValidAmount(
                                    appliedGiftcardDetails['discount_amount']
                                        ?.toString()))
                                  _buildDetailRow('Gift Card Discount Amount',
                                      '₹${appliedGiftcardDetails['discount_amount']}'),
                                if (isValidAmount(
                                    appliedRewardDetails['discount_amount']
                                        ?.toString()))
                                  _buildDetailRow('Reward Discount Amount',
                                      '₹${appliedRewardDetails['discount_amount']}'),
                                Divider(color: Colors.grey),
                                if (isValidAmount(data['booking_amount']))
                                  _buildDetailRow('Sub Total',
                                      '₹${data['booking_amount']}'),
                                if (isValidAmount(data['gst_amount']))
                                  _buildDetailRow(
                                      'GST Amount ${data['salon_gst_rate'] != null && isValidAmount(data['salon_gst_rate'].toString()) ? '(${data['salon_gst_rate']}%)' : ''}',
                                      '₹${data['gst_amount']}'),
                                Divider(color: Colors.grey),
                                if (isValidAmount(data['amount_to_paid']))
                                  _buildDetailRow('Grand Total',
                                      '₹${data['amount_to_paid']}'),
                                if (receiptUrl != null && receiptUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            CustomColors.backgroundtext,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        elevation: 5,
                                        shadowColor:
                                            Colors.grey.withOpacity(0.5),
                                      ).copyWith(
                                        minimumSize: MaterialStateProperty.all(
                                            Size(200, 0)),
                                      ),
                                      onPressed: () => _openReceipt(receiptUrl),
                                      child: Text(
                                        'View Receipt',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ...services
                        .map((service) => _buildServiceDetail(service))
                        .toList(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, dynamic value, {bool isStatus = false}) {
    final displayValue = value?.toString() ?? 'N/A';
    final textStyle = isStatus
        ? _getStatusTextStyle(displayValue, title == 'Payment Status')
        : TextStyle(fontSize: 16, color: Colors.black54);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetail(Map<String, dynamic> service) {
    final products = service['products'] as List<dynamic>? ?? [];
    final serviceStatus = service['service_status_text'] as String;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${service['service_name']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CustomColors.backgroundtext,
              ),
            ),
            if (service['image'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.network(
                  service['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

            _buildDetailRow('Duration', '${service['duration']} minutes'),
            _buildDetailRow('Service Price', '₹${service['price']}'),
            // _buildDetailRow('Discount', '₹${service['discount']}'),
            // _buildDetailRow('Discounted Price', '₹${service['final_price']}'),
            _buildDetailRow('Booking Time',
                '${service['service_from']} - ${service['service_to']}'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    serviceStatus,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getStatusColor(serviceStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _buildDetailRow('Stylist', service['stylist']),
            Divider(thickness: 1, color: Colors.grey),
            if (products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Products:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ...products.map((product) => _buildProductDetail(product)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetail(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product['image'] != null)
            Image.network(
              product['image'],
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                    child: Icon(Icons.image_not_supported,
                        size: 40, color: Colors.grey));
              },
            ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['product_name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                _buildDetailRow('Price', '₹${product['final_price']}'),
                // _buildDetailRow('Discount', '₹${product['discount']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openReceipt(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Could not open the receipt. Please check the URL or try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Map<String, dynamic> _formatDiscountDetails(
      Map<String, dynamic> discountDetails) {
    return discountDetails.map((key, value) {
      return MapEntry(key, _formatToTwoDecimal(value));
    });
  }

// Function to format a single value to two decimal points
  String _formatToTwoDecimal(dynamic value) {
    if (value is double || value is int) {
      return value.toStringAsFixed(2);
    }
    return value.toString(); // If it's not a number, return as is
  }
}
