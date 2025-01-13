import 'dart:convert'; // For JSON decoding
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class EditProfileUpdate extends StatefulWidget {
  const EditProfileUpdate({Key? key}) : super(key: key);

  @override
  _EditProfileUpdateState createState() => _EditProfileUpdateState();
}

class _EditProfileUpdateState extends State<EditProfileUpdate> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  String customerID = '';
  String branchID = '';
  String salonID = '';
  String fullName = '';
  String dateOfBirth = '';
  String dateOfAnniversary = '';
  String gender = '';
  String profilePicUrl = '';
  String mobileNumber = '';
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _anniversaryDateController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _profilePicController =
      TextEditingController(); // Controller for profile picture path

  String? _selectedGender;
  List<String> _genderOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchGenderData(); // Fetch gender data when the widget is initialized
    _initializeProfileData(); // Fetch and initialize profile data
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _anniversaryDateController.dispose();
    _fullNameController.dispose();
    _profilePicController.dispose(); // Dispose the profile picture controller
    super.dispose();
  }

  Future<void> _initializeProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId1 = prefs.getString('customer_id');
    String? customerId2 = prefs.getString('customer_id2');
    branchID = prefs.getString('branch_id') ?? '';
    salonID = prefs.getString('salon_id') ?? '';
    if (customerId1 != null && customerId1.isNotEmpty) {
      print('Trying to fetch profile details with customer_id: $customerId1');
      bool success = await fetchProfileDetails(customerId1);
      if (!success && customerId2 != null && customerId2.isNotEmpty) {
        print(
            'Trying to fetch profile details with customer_id2: $customerId2');
        await fetchProfileDetails(customerId2);
      }
    } else if (customerId2 != null && customerId2.isNotEmpty) {
      print('Trying to fetch profile details with customer_id2: $customerId2');
      await fetchProfileDetails(customerId2);
    }
  }

  Future<bool> fetchProfileDetails(String customerId) async {
    if (customerId.isEmpty || branchID.isEmpty || salonID.isEmpty) {
      print('Missing required parameters');
      return false;
    }

    String url = '${MyApp.apiUrl}customer/profile-details/';
    Map<String, String> requestBody = {
      "customer_id": customerId,
      "branch_id": branchID,
      "salon_id": salonID,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data'].isNotEmpty) {
          var profileData = responseData['data'][0];
          setState(() {
            fullName = profileData['full_name']?.toString() ?? '';
            dateOfBirth = profileData['date_of_birth']?.toString() ?? '';
            dateOfAnniversary =
                profileData['date_of_anniversary']?.toString() ?? '';
            gender = profileData['gender']?.toString() ?? '';
            _fullNameController.text = fullName;
            _dateOfBirthController.text = dateOfBirth;
            _anniversaryDateController.text = dateOfAnniversary;
            _selectedGender = gender;
            // profilePicUrl = profileData['profile_pic']?.toString() ?? '';
          });
          print('Profile Details Response: $responseData');
          return true;
        } else {
          print('No profile data available');
          return false;
        }
      } else {
        print(
            'Failed to load profile details with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error fetching profile details: $e');
      return false;
    }
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          width: width,
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
                        'Update your Details',
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(context, 'First Name', width,
                              controller: _fullNameController,
                              validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          }),
                          // SizedBox(height: height * 0.015),
                          // _buildTextField(context, 'Date of Birth', width,
                          //     controller: _dateOfBirthController,
                          //     showCalendarIcon: true, validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your date of birth';
                          //   }
                          //   return null;
                          // }),
                          // SizedBox(height: height * 0.015),
                          // _buildTextField(context, 'Anniversary Date', width,
                          //     controller: _anniversaryDateController,
                          //     showCalendarIcon: true, validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your anniversary date';
                          //   }
                          //   return null;
                          // }),
                          // SizedBox(height: height * 0.015),
                          // _buildGenderDropdown(context, width),
                          SizedBox(height: height * 0.015),
                          // _buildProfilePicUpdate(context, width),
                          // SizedBox(height: height * 0.015),
                          // _buildTermsAndConditions(width),
                          SizedBox(height: height * 0.03),
                          _buildSubmitButton(context, width),
                          SizedBox(height: height * 0.1),
                        ],
                      ),
                    ),
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
                      Navigator.pop(context);
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
    );
  }

  Widget _buildTextField(BuildContext context, String labelText, double width,
      {TextEditingController? controller,
      bool showCalendarIcon = false,
      FormFieldValidator<String>? validator}) {
    return Container(
      width: width * 0.78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: false,
        onTap: () {
          if (showCalendarIcon) {
            _selectDate(context, controller);
          }
        },
        validator: validator,
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
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(BuildContext context, double width) {
    return Container(
      width: width * 0.78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
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
          });
        },
        hint: Text('Select Gender'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your gender';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildProfilePicUpdate(BuildContext context, double width) {
    return Container(
      width: width * 0.78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: width * 0.025),
            child: Text(
              'Update Profile Picture',
              style: TextStyle(
                fontSize: width * 0.04,
                color: Color(0xFF353B43),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _handleProfilePicUpdate(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Image',
                  style: TextStyle(
                    fontSize: width * 0.036,
                    color: CustomColors.backgroundtext,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.camera_alt, // Use camera_alt icon for camera
                  size: width * 0.06,
                  color: CustomColors.backgroundtext,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          _profilePicController.text.isNotEmpty
              ? Image.file(File(_profilePicController.text))
              : Container(),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(double width) {
    return Container(
      width: width * 0.78,
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                isChecked = value ?? false;
              });
            },
          ),
          Expanded(
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
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, double width) {
    return GestureDetector(
      onTap: () {
        _submitForm(context);
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
    if (_formKey.currentState?.validate() ?? false) {
      String fullName = _fullNameController.text.trim();
      String dateOfBirth = _dateOfBirthController.text.trim();
      String anniversaryDate = _anniversaryDateController.text.trim();
      String gender = _selectedGender ?? ''; // Get selected gender

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Fetch customer IDs from SharedPreferences
      String? customerIdString1 = prefs.getString('customer_id');
      String? customerIdString2 = prefs.getString('customer_id2');

      // Determine the customer ID to use
      String customerId = customerIdString1 ?? customerIdString2 ?? '';

      // Fetch other values
      String salonId = prefs.getString('salon_id') ?? '';
      String branchId = prefs.getString('branch_id') ?? '';

      String apiUrl = '${MyApp.apiUrl}customer/update-profile-details/';

      // Create multipart request for uploading image
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['customer_id'] = customerId;
      request.fields['branch_id'] = branchId;
      request.fields['salon_id'] = salonId;
      request.fields['full_name'] = fullName;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['date_of_anniversary'] = anniversaryDate;
      request.fields['gender'] = gender;

      // Attach image file to the request
      if (_profilePicController.text.isNotEmpty) {
        var picFile = await http.MultipartFile.fromPath(
            'profile_pic', _profilePicController.text);
        request.files.add(picFile);
      }

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          print('API Response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your profile has been updated successfully.'),
              duration: Duration(seconds: 2),
            ),
          );

          // Handle navigation based on branchId
          if (branchId.isNotEmpty) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/edit_profile',
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
          print('Error: ${response.statusCode}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to update profile. Please try again later.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
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

  Future<void> _handleProfilePicUpdate(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    // Show dialog to choose between gallery and camera
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _profilePicController.text = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _profilePicController.text = image.path;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
