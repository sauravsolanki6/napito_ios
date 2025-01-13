import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Loading_Screen/loading_screen.dart';
import 'package:ms_salon_task/Scanner/qr_animation.dart';
import 'package:ms_salon_task/Scanner/scan_details.dart';
import 'package:ms_salon_task/SignUp/SignUpPage.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zxing2/qrcode.dart';
import 'package:zxing2/zxing2.dart';
import 'package:image/image.dart' as img;

import '../main.dart';

class QrCodeHomePage extends StatefulWidget {
  @override
  _QrCodeHomePageState createState() => _QrCodeHomePageState();
}

class _QrCodeHomePageState extends State<QrCodeHomePage> {
  GlobalKey _qrKey = GlobalKey();
  QRViewController? _controller;
  bool _showOverlay = false;
  bool _isCameraOpen = true;
  bool _showGif = false;
  bool _blockBackNavigation = false;
  String? _errorText; // Add a variable to store error text
  String _activeIcon = 'camera';
  TextEditingController _manualCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkOtpVerification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showGif = false;
      });
    });
  }

  Future<void> _checkOtpVerification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String isOtpVerified = prefs.getString('isOtpVerified') ?? '';
    if (isOtpVerified == '2') {
      setState(() {
        _blockBackNavigation = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          title: '',
        ),
      ),
    );
    return !_blockBackNavigation;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Full screen transparent
        body: Stack(
          children: [
            // Camera feed positioned to cover the entire screen
            if (_isCameraOpen)
              Positioned.fill(
                child: Stack(
                  children: [
                    QRView(
                      key: _qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                    // Semi-transparent black overlay
                    Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    // Center the BlinkingBorder widget
                    const Center(
                      child: BlinkingBorder(size: 300),
                    ),
                  ],
                ),
              ),
            if (_showOverlay)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showOverlay = false; // Close the overlay
                      _activeIcon = 'camera'; // Reset the camera icon to blue
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrCodeHomePage(),
                      ),
                    );
                  },
                  child: Container(
                    color: const Color.fromRGBO(59, 68, 83, 0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // Prevent tapping on the dialog from triggering the outer tap
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Enter Saloon Code',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF353B43),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _errorText == null
                                        ? const Color(
                                            0xFF0056D0) // Blue border when no error
                                        : Colors
                                            .red, // Red border when there is an error
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _manualCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    hintText: 'Enter Your Saloon Code',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFC4C4C4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Display the error message if there is an error
                              if (_errorText != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  _validateAndSubmit();
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: CustomColors.backgroundtext,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Overlay for manual input
            // if (_showOverlay)
            //   Positioned.fill(
            //     child: GestureDetector(
            //       onTap: () {
            //         // Close the overlay and navigate to QrCodePage
            //         setState(() {
            //           _showOverlay = false; // Close the overlay
            //           _activeIcon = 'camera'; // Reset the camera icon to blue
            //         });

            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => QrCodeHomePage(),
            //           ),
            //         );
            //       },
            //       child: Container(
            //         color: const Color.fromRGBO(59, 68, 83, 0.5),
            //         child: Center(
            //           child: GestureDetector(
            //             onTap: () {
            //               // Prevent tapping on the dialog from triggering the outer tap
            //             },
            //             child: Container(
            //               width: MediaQuery.of(context).size.width * 0.8,
            //               height: MediaQuery.of(context).size.height * 0.25,
            //               decoration: BoxDecoration(
            //                 color: Colors.white,
            //                 borderRadius: BorderRadius.circular(16),
            //               ),
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   const Text(
            //                     'Enter Saloon Code',
            //                     style: TextStyle(
            //                       fontFamily: 'Lato',
            //                       fontSize: 18,
            //                       fontWeight: FontWeight.w700,
            //                       color: Color(0xFF353B43),
            //                     ),
            //                   ),
            //                   const SizedBox(height: 16),
            //                   Container(
            //                     width: MediaQuery.of(context).size.width * 0.7,
            //                     height: 50,
            //                     decoration: BoxDecoration(
            //                       color: Colors.white,
            //                       borderRadius: BorderRadius.circular(6),
            //                       border: Border.all(
            //                         color: const CustomColors.backgroundtext,
            //                         width: 1,
            //                       ),
            //                     ),
            //                     child: TextField(
            //                       controller: _manualCodeController,
            //                       keyboardType: TextInputType.number,
            //                       decoration: const InputDecoration(
            //                         border: InputBorder.none,
            //                         contentPadding:
            //                             EdgeInsets.symmetric(horizontal: 10),
            //                         hintText: 'Enter Your Saloon Code',
            //                         hintStyle: TextStyle(
            //                           fontFamily: 'Lato',
            //                           fontSize: 12,
            //                           fontWeight: FontWeight.w500,
            //                           color: Color(0xFFC4C4C4),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   const SizedBox(height: 16),
            //                   GestureDetector(
            //                     onTap: () {
            //                       _validateAndSubmit();
            //                     },
            //                     child: Container(
            //                       width:
            //                           MediaQuery.of(context).size.width * 0.5,
            //                       height: 40,
            //                       decoration: BoxDecoration(
            //                         color: const CustomColors.backgroundtext,
            //                         borderRadius: BorderRadius.circular(6),
            //                       ),
            //                       child: const Center(
            //                         child: Text(
            //                           'Submit',
            //                           style: TextStyle(
            //                             fontFamily: 'Lato',
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w600,
            //                             color: Colors.white,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),

            // Header text
            const Positioned(
              top: 150,
              left: 30,
              right: 30,
              child: Center(
                child: Text(
                  'Scan QR Code to Connect with Your Favourite Salon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upload button
                  IconButton(
                    icon: const Icon(Icons.upload_file_outlined),
                    color: _activeIcon == 'upload'
                        ? CustomColors.backgroundtext
                        : Colors.white,
                    onPressed: () {
                      setState(() {
                        _activeIcon = 'upload'; // Set active icon to 'upload'
                        _isCameraOpen = false;
                      });
                      _pickFile(); // Call the file pick function
                    },
                  ),
                  const SizedBox(width: 20),

                  // Camera button
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: _activeIcon == 'camera'
                        ? CustomColors.backgroundtext
                        : Colors.white, // Blue if camera is active
                    onPressed: () {
                      setState(() {
                        _activeIcon = 'camera'; // Set active icon to 'camera'
                        _isCameraOpen = true; // Open the camera
                        _showGif = false; // Hide the GIF
                        _showOverlay = false;
                      });
                    },
                  ),
                  const SizedBox(width: 20),

                  // Keyboard button
                  IconButton(
                    icon: const Icon(Icons.keyboard_outlined),
                    color: _activeIcon == 'keyboard'
                        ? CustomColors.backgroundtext
                        : Colors.white,
                    onPressed: () {
                      setState(() {
                        _activeIcon =
                            'keyboard'; // Set active icon to 'keyboard'
                        _showOverlay = true; // Show the overlay
                        _isCameraOpen = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Skip button
            Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.1, // Adjust vertical position
              left: MediaQuery.of(context).size.width * 0.3,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CustomColors
                          .backgroundButtonCancel, // Blue border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(6), // Rounded corners
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            title: '',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    _controller!.scannedDataStream.listen((scanData) async {
      String scannedCode = scanData.code!;
      print('The code received is: $scannedCode');

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      await _storeScannedCode(scannedCode);
      _hitAPI(scannedCode);

      setState(() {
        _showGif = true;
        _isCameraOpen = false;
        _showOverlay = false;
      });
    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      String? path = file.path;

      if (path != null) {
        print('File selected: ${file.name}');
        final qrCode = await scanQRCodeFromFile(path);

        if (qrCode != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('scanned_code', qrCode);
          print('Scanned code stored in SharedPreferences: $qrCode');

          await _hitAPI(qrCode);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No QR code found in the selected image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No file selected'),
          backgroundColor: Colors.red,
          duration:
              const Duration(milliseconds: 300), // Set duration to 0.2 seconds
        ),
      );

      // Navigate to QrCodeHomePage if no file is selected
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrCodeHomePage(),
        ),
      );
    }
  }

  // void _pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //     allowMultiple: false,
  //   );

  //   if (result != null) {
  //     PlatformFile file = result.files.single;
  //     String? path = file.path;

  //     if (path != null) {
  //       print('File selected: ${file.name}');
  //       final qrCode = await _scanQRCodeFromFile(path);

  //       if (qrCode != null) {
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('scanned_code', qrCode);
  //         print('Scanned code stored in SharedPreferences: $qrCode');

  //         await _hitAPI(qrCode);
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('No QR code found in the selected image.'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('No file selected'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<String?> scanQRCodeFromFile(String filePath) async {
    try {
      // Load the image from the file path
      final file = File(filePath);
      final imageBytes = await file.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        print('Error: Could not decode the image.');
        return null;
      }

      // Convert the image to grayscale (optional, for performance improvement)
      final width = decodedImage.width;
      final height = decodedImage.height;
      final pixels = decodedImage.getBytes(order: img.ChannelOrder.rgba);

      // Convert the RGBA image data (Uint8List) to Int32List
      final intPixels = Int32List(width * height);
      for (int i = 0; i < width * height; i++) {
        int r = pixels[i * 4];
        int g = pixels[i * 4 + 1];
        int b = pixels[i * 4 + 2];
        int a = pixels[i * 4 + 3];

        // Combine RGBA into a single int (in this example, we use ARGB format)
        intPixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
      }

      // Use the pixels as a luminance source for ZXing
      final luminanceSource = RGBLuminanceSource(width, height, intPixels);

      final binaryBitmap = BinaryBitmap(HybridBinarizer(luminanceSource));

      // Decode the QR code
      final reader = QRCodeReader();
      final result = reader.decode(binaryBitmap);

      return result.text;
    } catch (e) {
      print('Error scanning QR code: $e');
    }

    return null;
  }

  Future<void> _storeScannedCode(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('scanned_code', code);
    print('Scanned code stored in SharedPreferences: $code');
  }

  Future<void> _storeManualCode(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('manual_code', code);
    print('Manual code stored in SharedPreferences: $code');
  }

  Future<void> _hitAPI(String code) async {
    String apiUrl = '${MyApp.apiUrl}customer/get-store/';
    var requestBody = jsonEncode({'store_code': code});

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('API Request: $apiUrl, Body: $requestBody');
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('API Response: $jsonResponse');

        if (jsonResponse['status'] == 'true') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanDetailsPage(),
            ),
          );
        } else {
          String errorMessage = jsonResponse['message'] ?? 'An error occurred';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Request failed with status: ${response.statusCode}.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception encountered: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An exception occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void _validateAndSubmit() {
  //   String manualCode = _manualCodeController.text.trim();
  //   if (manualCode.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Please enter a saloon code.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } else {
  //     _storeManualCode(manualCode);
  //     _hitAPI(manualCode);
  //   }
  // }
  void _validateAndSubmit() {
    String manualCode = _manualCodeController.text.trim();
    setState(() {
      _errorText = manualCode.isEmpty ? 'Please enter a saloon code.' : null;
    });

    if (_errorText == null) {
      _storeManualCode(manualCode);
      _hitAPI(manualCode);
    }
  }
}
