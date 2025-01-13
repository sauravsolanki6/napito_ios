import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Raise_Ticket/all_visits.dart';
import 'package:ms_salon_task/Raise_Ticket/your_tickets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart'; // Import shimmer package

class RaiseTicket extends StatefulWidget {
  @override
  _RaiseTicketState createState() => _RaiseTicketState();
}

class _RaiseTicketState extends State<RaiseTicket> {
  final _formKey = GlobalKey<FormState>();
  String customerID = '';
  String branchID = '';
  String salonID = '';
  String mobileNumber = '';
  List<Map<String, dynamic>> helpTypes = [];
  String selectedHelpType = '';
  String selectedHelpTypeId = '';
  TextEditingController descriptionController = TextEditingController();
  String attachmentFileName = '';
  String attachmentBase64 = '';
  bool _isSubmitting = false;
  String? _helpTypeError;
  bool _isLoading = true; // Add a loading flag

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerID = prefs.getString('customer_id') ?? '';
      branchID = prefs.getString('branch_id') ?? '';
      salonID = prefs.getString('salon_id') ?? '';
      mobileNumber = prefs.getString('mobileNumber') ?? '';
    });

    String customerID2 = prefs.getString('customer_id2') ?? '';
    if (customerID2.isNotEmpty && customerID2 != customerID) {
      customerID = customerID2;
    }

    await _getHelpTypes();
  }

  Future<void> _getHelpTypes() async {
    final url = '${MyApp.apiUrl}customer/query-types/';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'customer_id': customerID});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          helpTypes = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _isLoading = false; // Stop loading
        });
      } else {
        print('Failed to load help types. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isLoading = false; // Stop loading even on failure
        });
      }
    } catch (error) {
      print('Error occurred while fetching help types: $error');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchData();
  }

  void _onHelpTypeSelected(Map<String, dynamic> helpType) {
    setState(() {
      selectedHelpType = helpType['query_type'];
      selectedHelpTypeId = helpType['query_type_id'];
      _helpTypeError = null;
    });
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    await _fetchData();
    return true;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        final fileExtension = filePath.split('.').last.toLowerCase();
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
        if (allowedExtensions.contains(fileExtension)) {
          final file = File(filePath);
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);

          setState(() {
            attachmentFileName = result.files.single.name;
            attachmentBase64 = base64String;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please select a valid image file (jpg, jpeg, png, gif, bmp).'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      if (selectedHelpTypeId.isEmpty) {
        _helpTypeError = 'Please select a help type';
      }
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (_helpTypeError == null && selectedHelpTypeId.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String customerID = prefs.getString('customer_id') ?? '';
        String salonID = prefs.getString('salon_id') ?? '';
        String branchID = prefs.getString('branch_id') ?? '';

        final requestBody = {
          "customer_id": customerID,
          "salon_id": salonID,
          "branch_id": branchID,
          "query_type": selectedHelpTypeId,
          "description": descriptionController.text,
          "attachment_filename": attachmentFileName,
          "attachment": attachmentBase64,
        };

        final url = '${MyApp.apiUrl}customer/raise-query/';
        final headers = {'Content-Type': 'application/json'};

        try {
          final response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(requestBody),
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Query submitted successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            // Clear the form data after a successful submission
            setState(() {
              descriptionController.clear();
              selectedHelpType = '';
              selectedHelpTypeId = '';
              attachmentFileName = '';
              attachmentBase64 = '';
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AllTicket(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to submit the query. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: CustomColors.backgroundLight,
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
                'Help',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Add padding here
            child: Stack(
              children: [
                if (_isLoading) ...[
                  // Skeleton Loader
                  ListView(
                    padding: EdgeInsets.all(16.0),
                    children: List.generate(
                      5,
                      (index) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.0),
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Your actual content
                  Positioned(
                    top: 40,
                    left: 10, // Margin from the left
                    right: null, // No constraint on the right side
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width -
                            20, // Full width minus left margin
                      ),
                      height: 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hello, We are here to help',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Container(
                                width: double.infinity,
                                height: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        "Select Your Help Type",
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF353B43),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...helpTypes
                                        .map((item) => buildHelpTypeItem(
                                              item,
                                              selectedHelpTypeId ==
                                                  item['query_type_id'],
                                              _onHelpTypeSelected,
                                            ))
                                        .toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 219, 220, 220),
                            width: 1.4,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedHelpType.isEmpty
                                    ? 'Select Your Help Type'
                                    : selectedHelpType,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF353B43),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF353B43),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 140,
                    left: 0,
                    right: 0,
                    child: Form(
                      key: _formKey,
                      child: Container(
                        width: double.infinity,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color.fromARGB(255, 219, 220, 220),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text(
                                'Description',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF353B43),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: descriptionController,
                                    maxLines: null,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      hintText: 'Type your description here...',
                                      border: InputBorder
                                          .none, // No border here as it's handled by the parent container
                                      focusedBorder: InputBorder
                                          .none, // No focused border as well
                                      errorText: _isSubmitting &&
                                              (_formKey.currentState
                                                      ?.validate() ??
                                                  false)
                                          ? null
                                          : null,
                                    ),
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF353B43),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_isSubmitting &&
                                          (value == null || value.isEmpty)) {
                                        return 'Description cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 410,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color.fromARGB(255, 219, 220, 220),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  attachmentFileName.isEmpty
                                      ? 'Attachment'
                                      : attachmentFileName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF353B43),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Image.asset(
                                  'assets/upload.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 500,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _handleSubmit,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CustomColors.backgroundtext,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color.fromARGB(255, 219, 220, 220),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Submit',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_helpTypeError != null)
                    Positioned(
                      top: 110,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          _helpTypeError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHelpTypeItem(Map<String, dynamic> helpType, bool selected,
      Function(Map<String, dynamic>) onTap) {
    return GestureDetector(
      onTap: () => onTap(helpType),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              helpType['query_type'],
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 16.8 / 14,
                color: Color(0xFF353B43),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
