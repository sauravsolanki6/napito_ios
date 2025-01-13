import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Scanner/scan_details.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  GlobalKey _qrKey = GlobalKey();
  late QRViewController _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0, // Remove elevation
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            Text(
              'Scan Your QR Code',
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
          Positioned(
            top: 250, // Adjusted position to place above the button
            left: 110,
            child: Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Outline color
                  width: 2, // Outline width
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: QRView(
                  key: _qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
          ),
          Positioned(
            top: 550,
            left: 110,
            child: GestureDetector(
              onTap: () {
                // Navigate to ScanDetailsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanDetailsPage()),
                );
              },
              child: Container(
                width: 185,
                height: 48,
                decoration: BoxDecoration(
                  color: CustomColors.backgroundtext, // Button background color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Handle scanned QR code data
      print(scanData);
      // Optionally navigate or perform an action based on the scan result
    });
  }
}
