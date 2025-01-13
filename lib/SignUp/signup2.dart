import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/SignUp/SignUpPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class SignUp2Page extends StatefulWidget {
  const SignUp2Page({Key? key}) : super(key: key);

  @override
  _SignUp2PageState createState() => _SignUp2PageState();
}

class _SignUp2PageState extends State<SignUp2Page> {
  bool isChecked = false;
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _anniversaryDateController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  String _customerId = '';
  String _customerId2 = ''; // Additional customer ID
  String? _selectedGender;
  List<String> _genderOptions = [];
  bool _hasErrorFullName = false;
  bool _hasErrorDateOfBirth = false;
  bool _hasErrorAnniversaryDate = false;
  bool _hasErrorGender = false; // New error state for gender
  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _anniversaryDateController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCustomerIds();
    _fetchGenderData();
  }

  Future<void> _loadCustomerIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Retrieve the saved API response
      String savedApiResponse = prefs.getString('api_response') ?? '';

      // Print the saved API response for debugging
      if (savedApiResponse.isNotEmpty) {
        print('Retrieved API Response: $savedApiResponse');

        try {
          // Parse the JSON response
          var jsonResponse = jsonDecode(savedApiResponse);
          print('Parsed JSON Response: $jsonResponse');

          // Extract the customer ID from the parsed JSON
          String customerIdFromApi =
              jsonResponse['data']['customer_id']?.toString() ?? '';

          // Use the customer ID from the API response instead of _customerId2
          _customerId2 = customerIdFromApi;

          // Save the customer ID in SharedPreferences
          prefs.setString('customer_id2', _customerId2);
          print('Saved Customer ID to SharedPreferences: $_customerId2');

          // Print the retrieved customer ID for debugging
          print('Updated Customer ID: $_customerId2');
        } catch (e) {
          print('Error parsing JSON response: $e');
        }
      } else {
        print('No API Response found in SharedPreferences.');
      }
    });
  }

  Future<void> _fetchGenderData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String salonId = prefs.getString('salon_id') ?? '';
    String branchId = prefs.getString('branch_id') ?? '';

    if (salonId.isNotEmpty && branchId.isNotEmpty) {
      var url = Uri.parse('${MyApp.apiUrl}customer/get-store-genders/');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salon_id': salonId,
          'branch_id': branchId,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            _genderOptions = List<String>.from(responseData['data']);
          });
        } else {
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } else {
      print('Salon ID or Branch ID is missing.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(),
          ),
        );
        return false; // Prevent the default back navigation
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            height: height,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  width: width,
                  height: height * 0.5,
                  child: Image.asset(
                    'assets/signupback1.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  width: width,
                  height: height * 0.5,
                  child: Transform.rotate(
                    angle: -180 * (3.14 / 180),
                    child: Image.asset(
                      'assets/signupback1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.25),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Enter your Details',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF353B43),
                            height: 1.2,
                            letterSpacing: 0.02,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      _buildGenderDropdown(context, width),
                      SizedBox(height: height * 0.015),
                      _buildTextField(
                        context,
                        'Customer Name*',
                        width,
                        controller: _fullNameController,
                        isError: _hasErrorFullName,
                      ),
                      SizedBox(height: height * 0.015),
                      _buildTextField(
                        context,
                        'Date of Birth*',
                        width,
                        controller: _dateOfBirthController,
                        isError: _hasErrorDateOfBirth,
                        showCalendarIcon: true,
                      ),
                      SizedBox(height: height * 0.015),
                      _buildTextField(
                        context,
                        'Anniversary Date',
                        width,
                        controller: _anniversaryDateController,
                        showCalendarIcon: true,
                      ),
                      SizedBox(height: height * 0.015),
                      SizedBox(height: height * 0.015),
                      _buildTermsAndConditions(width),
                      SizedBox(height: height * 0.03),
                      _buildSubmitButton(context, width),
                      SizedBox(height: height * 0.1),
                    ],
                  ),
                ),
                Positioned(
                  top: height * 0.07,
                  left: width * 0.10,
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.012),
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/back.png',
                        width: width * 0.06,
                        height: width * 0.06,
                        fit: BoxFit.cover,
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

  Widget _buildTextField(BuildContext context, String labelText, double width,
      {TextEditingController? controller,
      bool showCalendarIcon = false,
      bool isError = false}) {
    return Container(
      width: width * 0.78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: Color(0x1A000000),
        //     blurRadius: 14.0,
        //     offset: Offset(0, 4),
        //   ),
        // ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: false,
        onTap: () {
          if (showCalendarIcon) {
            _selectDate(context, controller);
          }
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: width * 0.04,
            height: 1.1,
            letterSpacing: 0.0,
            color: Color(0xFF353B43),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: width * 0.025),
          suffixIcon: showCalendarIcon
              ? IconButton(
                  icon: Image.asset(
                    'assets/calendar1.png',
                    width: 20.0,
                    height: 20.0,
                  ),
                  onPressed: () {
                    _selectDate(context, controller);
                  },
                )
              : null,
          // Change border color if there's an error
          errorText: isError ? 'This field cannot be empty' : null,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isError ? Colors.red : Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isError ? Colors.red : Colors.white),
          ),
          errorStyle: TextStyle(
            color: Colors.red, // Set error text color to red
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(BuildContext context, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
      children: [
        Container(
          width: width * 0.78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 14.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedGender = value;
                _hasErrorGender = false; // Clear error if a gender is selected
              });
            },
            hint: Text('Select Gender*'),
            value: _selectedGender,
          ),
        ),
        // Display error message if there's an error
        if (_hasErrorGender)
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0), // Add some space above the error message
            child: Text(
              'Please select a gender',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12, // Adjust font size as needed
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermsAndConditions(double width) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
        ),
        Flexible(
          child: Text(
            'I agree to the Privacy Policy, Terms of Use, and Terms of Service',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: width * 0.029,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3B4453),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, double width) {
    return GestureDetector(
      onTap: () async {
        // Check if the terms and conditions checkbox is checked
        if (isChecked) {
          // Call setLoggedInUserDetails here
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('full_name', _fullNameController.text);

          _submitForm(context);
        } else {
          // Show a snackbar or alert to inform the user to agree to the terms
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please agree to the Privacy Policy and Terms of Service before submitting.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: width * 0.78,
        padding: EdgeInsets.symmetric(vertical: width * 0.025),
        decoration: BoxDecoration(
          color: CustomColors.backgroundtext,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    // Get values from controllers
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve user input from controllers
    String fullName = _fullNameController.text.trim();
    String dateOfBirth = _dateOfBirthController.text.trim();
    String anniversaryDate = _anniversaryDateController.text.trim();
    String gender = _selectedGender ?? ''; // Use selected gender
    setState(() {
      _hasErrorFullName = fullName.isEmpty;
      _hasErrorDateOfBirth = dateOfBirth.isEmpty;
      _hasErrorAnniversaryDate = anniversaryDate.isEmpty;
      _hasErrorGender = gender.isEmpty; // Check gender
    });
    // Retrieve customer ID and check if it's null
    // final String? customerId =
    //     prefs.getString('customer_id2'); // Ensure this key is correct
    // if (customerId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Customer ID not found. Please log in again.'),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    //   return;
    // }

    // Retrieve salon and branch IDs, ensuring they have default values
    String salonId = prefs.getString('salon_id') ?? '';
    String branchId = prefs.getString('branch_id') ?? '';

    // Validate all required fields
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // API endpoint URL
    String apiUrl = '${MyApp.apiUrl}customer/update-profile-details/';

    // Prepare request body
    Map<String, String> requestBody = {
      'customer_id': _customerId2,
      'branch_id': branchId.toString(),
      'salon_id': salonId.toString(),
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'date_of_anniversary': anniversaryDate,
      'gender': gender,
      'profile_pic': '', // Assuming profile_pic is not required, leave empty
    };

    // Print request body for debugging
    print('Request Body: $requestBody');

    // Make POST request to update the profile
    try {
      var response = await http.post(Uri.parse(apiUrl), body: requestBody);

      // Print response status and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your profile has been updated successfully.'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate based on branchId
        if (branchId != '0') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/qr',
            (route) => false,
          );
        }
      } else {
        // Error handling for unsuccessful response
        print('Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Catch any exceptions that occur during the request
      print('Exception caught: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to update profile. Please check your internet connection.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController? controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && controller != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }
}
