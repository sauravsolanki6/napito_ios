import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/e_reciept.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccessfulPage extends StatefulWidget {
  @override
  _PaymentSuccessfulPageState createState() => _PaymentSuccessfulPageState();
}

class _PaymentSuccessfulPageState extends State<PaymentSuccessfulPage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_stylist_id');
    await prefs.remove('gift_card_code');
    await prefs.remove('selected_date');
    await prefs.remove('selected_time_slot');
    await prefs.remove('selected_stylist_id');
    await prefs.remove('offer_details');
    await prefs.remove('selected_service_data1');
    await prefs.remove('selected_service_data');
    await prefs.remove('selected_service_data2');
    await prefs.remove('selected_package_data_add_package');
    await prefs.remove('offers_response');
    await prefs.remove('stylist_service_data_stored');
    await prefs.remove('reward_id');
    await prefs.remove('reward_amount');
    await prefs.remove('reward_applied');
    await prefs.remove('discount_amount_rewards');
    await prefs.remove('coupons_response');
    await prefs.remove('minimum_amount');
    await prefs.remove('offered_price');
    await prefs.remove('coupon_applied');
    await prefs.remove('selected_stylist_id');
    await prefs.remove('offer_applied');
    await prefs.remove('coupon_details');
    await prefs.remove('giftcard_id');
    await prefs.remove('giftcard_min_amount');
    await prefs.remove('giftcard_discount_amount');
    await prefs.remove('giftcard_applied');

    // Remove the combined gift card details JSON entry
    await prefs.remove('giftcard_details');
    // Remove the combined reward details JSON entry
    await prefs.remove('reward_details');

    await prefs.remove('selected_product_ids');
  }

  // Load the image asynchronously
  void loadImage() async {
    final ByteData data = await rootBundle.load('assets/scissors.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _image = frameInfo.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size from MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return WillPopScope(
      onWillPop: () async {
        await _clearPreferences();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(title: '')),
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color:
                  CustomColors.backgroundtext, // Background color of the page
            ),
            // Positioned image
            Positioned(
              top: screenSize.height * 0.3, // 30% of the screen height
              left: screenSize.width * 0.3, // Centered horizontally
              child: _image != null
                  ? CustomPaint(
                      size: Size(
                          screenSize.width * 0.4,
                          screenSize.width *
                              0.4), // 40% of screen width for size
                      painter: ImagePainter(image: _image!),
                    )
                  : SizedBox(), // Replace with loading indicator if needed
            ),
            // Positioned text (Payment Successful)
            Positioned(
              width: screenSize.width * 0.6, // 60% of screen width
              top: screenSize.height * 0.55, // Adjusted for screen size
              left: screenSize.width * 0.25, // Centered horizontally
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.02,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            // Positioned text (Your Appointment has been confirmed!)
            Positioned(
              width: screenSize.width * 0.75, // 75% of screen width
              top: screenSize.height * 0.6, // Adjusted for screen size
              left: screenSize.width * 0.125, // Centered horizontally
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Your Appointment has been confirmed!\nWe’ve sent you details on WhatsApp for your Appointment.',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.02,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Positioned button (View E-Receipt)
            Positioned(
              width: screenSize.width * 0.65, // 65% of screen width
              top: screenSize.height * 0.8, // Adjusted for screen size
              left: screenSize.width * 0.175, // Centered horizontally
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EReciept()),
                  );
                },
                child: Text(
                  'View E-Receipt',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.02,
                    color: CustomColors.backgroundtext,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                  elevation: 10,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            // Positioned button (Done)
            Positioned(
              width: screenSize.width * 0.65, // 65% of screen width
              top: screenSize.height * 0.88, // Adjusted for screen size
              left: screenSize.width * 0.175, // Centered horizontally
              child: ElevatedButton(
                onPressed: () async {
                  await _clearPreferences();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(title: '')),
                  );
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.02,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.backgroundtext,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                  elevation: 10,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw the image
class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
