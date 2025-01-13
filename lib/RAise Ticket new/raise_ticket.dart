import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../API/create_json/createjson.dart';
import '../API/network/networkcall.dart';
import '../API/response/apihelptypesresponse.dart';
import '../API/response/raiseuserqueryresponse.dart';
import '../API/url/urls.dart';
import 'help_list.dart';

class RaiseTicket extends StatefulWidget {
  const RaiseTicket({super.key});

  @override
  State<RaiseTicket> createState() => _RaiseTicketState();
}

class _RaiseTicketState extends State<RaiseTicket> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  String attachement = "";
  String? attachmentPath;

  Future<void> uploadFile(File file, String filename, String filetype) async {
    log("File base name: $filename");
    try {
      final bytes = await file.readAsBytes();
      String base64String = base64Encode(bytes);
      switch (filetype) {
        case "_submitfile":
          attachement = base64String;
          attachmentPath = filename;
          break;
      }
    } catch (e) {
      log("Error uploading file: $e");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Allow picking only one file at a time
      type: FileType.any, // Allow picking any kind of file
    );

    if (result != null) {
      String fileName = result.files.first.name;
      String filePath = result.files.first.path!;

      setState(() {
        uploadFile(File(filePath), fileName, "_submitfile");
        attachmentPath = fileName;
        _controller.text =
            fileName; // Set the selected filename to the TextField
      });
    } else {
      // User canceled the file picking process
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    HelpType();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<HelpTypeFromResponseDatum> helptypedatalist = [];
  String selectedHelpTypeId = "";
  Future<void> HelpType() async {
    try {
      // Fetch SharedPreferences instance
      SharedPreferences loginid = await SharedPreferences.getInstance();

      // Retrieve the customer_id instead of user_id
      String? customerId1 = loginid.getString('customer_id') ?? '';

      // Create JSON with customer_id
      String createjson1 = createjson().getJsonForhelptypes(
        customerId1,
      );

      // Make network call
      NetworkCall networkCall = NetworkCall();
      List<Object?>? login = await networkCall.postMethod(URLS().apihelptypes,
          URLS().baseUrl + URLS().apihelptypesurl, createjson1, context);

      if (login != null) {
        // Navigator.pop(context);

        // Parse response
        List<HelpTypesResponse> loginrespon = List.from(login);
        String status = loginrespon[0].status!;

        switch (status) {
          case "true":
            helptypedatalist = loginrespon[0].data!;
            setState(() {
              selectedHelpTypeId = helptypedatalist[0].id!;
            });
            break;
          case "false":
            break;
        }
      } else {
        // Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

//do
  Future<void> Networkcallforsubmit() async {
    SharedPreferences loginid = await SharedPreferences.getInstance();
    String? userID = loginid.getString("userID") ?? '';
    String description = descriptioncontroller.text;
    try {
      // ProgressDialog.showProgressDialog(context, "title");
      String createjson1 = jsonEncode({
        'user_id': userID,
        'selected_help_type': selectedHelpTypeId,
        'description': description,
        'attachment': attachement,
        'attachment_filename': attachmentPath
      });
      log("JSON Data: $createjson1");
      NetworkCall networkCall = NetworkCall();
      List<Object?>? list = await networkCall.postMethod(
          URLS().apiraiseuserqueryapi,
          URLS().baseUrl + URLS().apiraiseuserqueryurl,
          createjson1,
          context);
      if (list != null) {
        // Navigator.pop(context);
        List<RaiseUserQueryResponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            SnackBar(
              content: Text("Successfully submitted"),
            );
            // Navigator.pop(context);
            break;
          case "false":
            Text(response[0].message!);
            break;
        }
      } else {
        Navigator.pop(context);
        log('Something went wrong');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ShowConfirmationDialog(BuildContext context1) {
    showDialog(
      context: context1,
      builder: (context1) {
        return AlertDialog(
          title: Text("Confirmation!"),
          content: Text("Are you sure? You want to add announcement?"),
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.pop(context1);
                // Networkcallforsubmit();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                // Navigator.pop(context1);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  onTapSave() {
    FocusScope.of(context).unfocus();
    // Remove the confirmation dialog call from here
    // Networkcallforsubmit();
  }

  final List<String> genderItems = [
    'What is City Parcel Connect?',
    'What is City Parcel ?',
    'What is City Parcel hfgh?',
    'What is City  Connasdect?',
    'What is City  ConSDFnsdfdsect?',
    'What is City  ConsdfdnJHJect?',
    'What is City  Consdfasdnect?',
  ];

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.0),
              child: Container(
                decoration: BoxDecoration(),
              )),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(0x3033CC99),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 0,
              ),
              Row(
                children: [
                  Text(
                    'Raise Ticket',
                    style: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                width: 50,
              )
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Color(0xFFFFFFFF),
        // bottomNavigationBar : BottomNavigation(),

        body: GestureDetector(
          onTap: () {
            // Close the keyboard when tapping outside of text fields
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Color(0x3033CC99)),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      padding: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFffffff),
                        // border: Border.all(color: Color(0XFF000000), width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Hello, We are here to help",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          DropdownButtonFormField2<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  'Help Type', // Label text for the form field
                              hintText: 'Select Help Type', // Placeholder text
                              border: OutlineInputBorder(), // Border style
                            ),
                            value: selectedHelpTypeId.isEmpty
                                ? null
                                : selectedHelpTypeId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedHelpTypeId = newValue!;
                              });
                            },
                            items: helptypedatalist
                                .map<DropdownMenuItem<String>>(
                                    (HelpTypeFromResponseDatum item) {
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(item.helpType ?? ""),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a help type'; // Validation message if no item is selected
                              }
                              return null; // Return null if validation passes
                            },
                            onSaved: (value) {
                              // Save the selected value to form state if needed
                            },
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 24,
                            ),
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.only(right: 8),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          //textbox of our website
                          // Assuming you have a Form widget wrapping your TextField
                          Form(
                            key: _formKey, // Form key for validation
                            child: TextFormField(
                              cursorColor: Colors.green,
                              controller: descriptioncontroller,
                              keyboardType: TextInputType.text,
                              maxLines: 8,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF008357)),
                                ),
                                labelText: "Description",
                                floatingLabelStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(
                                      0xFF008357), // Color of floating label when focused
                                ),
                                // hintText: 'Description',
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                // You can add more complex validation here if needed
                                return null; // Return null if the input is valid
                              },
                            ),
                          ),

                          SizedBox(
                            height: 30,
                          ),

                          GestureDetector(
                            onTap: () => _pickFile(),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 136, 135, 135),
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                              child: TextField(
                                controller:
                                    _controller, // Connect the controller to the TextField
                                enabled: false,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 5, right: 0, bottom: 10),
                                    child: Icon(
                                      Icons.file_download_outlined,
                                      size: 30,
                                      color: Color(0xFF008357),
                                    ),
                                  ),
                                  hintText: 'Attachment',
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // ElevatedButton(
                          //   onPressed: _pickFile,
                          //   style: ElevatedButton.styleFrom(
                          //     // foregroundColor: Colors.white,
                          //     backgroundColor: Colors.white, // Set the text color
                          //     // Additional styling options...
                          //   ),
                          //   child: Image.asset('assest/download.png'),
                          // ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFF008357)),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                  ),
                                  onPressed: () async {
                                    // Validate your text fields before proceeding
                                    if (_formKey.currentState!.validate()) {
                                      // All fields are valid, proceed with the submission

                                      // Call onTapSave to handle any immediate data processing
                                      onTapSave();

                                      // Perform your network call (example function)
                                      await Networkcallforsubmit();

                                      // Navigate to HelpList page only after submission completes
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HelpList()),
                                      );
                                    } else {
                                      // Fields are not valid, handle validation errors if needed
                                      // For example, you can show a snackbar or message to inform the user
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Please fill out all required fields correctly.'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 15),
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   decoration: BoxDecoration(color: Color(0x3033CC99)),
              //   child: Image.asset('assest/parcelhand.png'),
              // )
            ],
          )),
        ),
      ),
    );
  }
}
