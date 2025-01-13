import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:http/http.dart' as http;
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Raise_Ticket/raise_ticket.dart';
import 'package:ms_salon_task/Raise_Ticket/sos.dart';
import 'package:ms_salon_task/Raise_Ticket/ticket_details.dart';
import 'package:ms_salon_task/firebase_crash/Crashannalytics.dart';
import 'package:ms_salon_task/homepage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart';

class AllTicket extends StatefulWidget {
  @override
  _AllTicketState createState() => _AllTicketState();
}

class _AllTicketState extends State<AllTicket> {
  List<Task> tasks = [];
  int displayedTasksCount = 6; // Initially show 6 tasks
  static const int tasksPerLoad = 6; // Load 6 more tasks each time
  bool isLoading = false;
  bool reachedEnd = false; // Flag to indicate if all tasks are loaded
  bool sortByDateAscending =
      true; // Track ascending/descending for date sorting
  bool sortByPriorityAscending =
      true; // Track ascending/descending for priority sorting

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTaskData();

    // Add listener to detect when user reaches the end of the list
    _scrollController.addListener(_scrollListener);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Fetch data again whenever the widget becomes visible
  //   if (ModalRoute.of(context)?.isCurrent == true) {
  //     fetchTaskData();
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        !reachedEnd) {
      // Reached the bottom of the list and not currently loading
      loadMoreTasks();
    }
  }

  Future<void> fetchTaskData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve customer IDs and other IDs
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';

    // Determine the customer ID to use
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    var apiUrl = '${MyApp.apiUrl}customer/queries';

    final body = jsonEncode({
      'customer_id': customerId,
      'salon_id': salonID,
      'branch_id': branchID,
      'page': 1, // Change these as needed for pagination
      'page_size': displayedTasksCount,
    });

    print('Request Body: $body'); // Print request body for debugging
    final errorLogger = ErrorLogger(); // Initialize the error logger
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'Response Status Code: ${response.statusCode}'); // Print response status code
      print(
          'Response Body: ${response.body}'); // Print response body for debugging

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print(
            'Response Data of tickets: $responseData'); // Print entire response for debugging

        // Check if status is "true" in response data
        if (responseData['status'] == 'true') {
          List<Task> fetchedTasks = [];
          var dateFormatter = DateFormat('dd MMM, yyyy hh:mm a');

          for (var taskData in responseData['data']) {
            DateTime parsedDate;
            try {
              parsedDate = dateFormatter.parse(taskData['ticket_datetime']);
            } catch (e) {
              parsedDate = DateTime.now(); // Fallback date if parsing fails
              print('Error parsing date: $e');
            }

            fetchedTasks.add(Task(
              taskId: taskData['id'].toString(),
              taskNumber: taskData['support_id'].toString(),
              date: parsedDate.toString(),
              description: taskData['description'].toString(),
              priority: taskData['query_type'].toString(),
              status: taskData['final_resolution_status_text'].toString(),
              siteAddress: taskData['attachment_link'].toString(),
              attachmentLink: taskData['attachment_link']
                  .toString(), // Assuming attachmentLink should be set here
            ));
          }

          setState(() {
            tasks = fetchedTasks;
            if (tasks.length <= displayedTasksCount) {
              reachedEnd = true; // All tasks are loaded
            }
          });
        } else if (responseData['status'] == 'false' &&
            responseData['message'] == 'Queries not found') {
          // Navigate to the SOS page
          Navigator.pushReplacementNamed(
              context, '/sos'); // Update the route name as needed
        } else {
          print('Status not true in response');
        }
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';

      await errorLogger.setSalonId(salonID);
      await errorLogger.setBranchId(branchID);

      // Log the error details with Crashlytics or your custom logger
      await errorLogger.logError(
        errorMessage: e.toString(),
        errorLocation: "Function -> fetchTaskData",
        userId: salonID,
        receiverId: "System",
        stackTrace: stackTrace,
      );

      print('Error in fetchTaskData: $e');
      print('Stack Trace: $stackTrace');

      // Optionally, rethrow the exception or return an empty list
      throw Exception('Error during fetchTicketsLIst API call: $e');
    }
  }

  Future<void> loadMoreTasks() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      // Simulating a delay to demonstrate loading animation
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        if (displayedTasksCount + tasksPerLoad < tasks.length) {
          displayedTasksCount += tasksPerLoad;
        } else {
          displayedTasksCount = tasks.length;
          reachedEnd = true; // All tasks have been displayed
        }
        isLoading = false;
      });
    }
  }

  Widget buildDropdown(
      String label, List<String> options, Function(String?) onChanged) {
    List<String> filteredOptions = options;

    if (label == 'Date') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              ).then((pickedDate) {
                if (pickedDate != null) {
                  onChanged(pickedDate.toIso8601String().split('T')[0]);
                }
              });
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                controller: TextEditingController(
                    text: options.isNotEmpty ? options[0] : ''),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: null,
            items:
                filteredOptions.map<DropdownMenuItem<String>>((String? value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value ?? ''),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          SizedBox(height: 12),
        ],
      );
    }
  }

  void storeTaskInfo(String ticketId, String siteAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ticket_id', ticketId);

    print('Selected Ticket ID: $ticketId');

    // Navigate to SiteVisitDetails page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetails(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      title: '',
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Text(
                'Your Tickets',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            // Add the wider rounded rectangular button here
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      CustomColors.backgroundtext, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8), // Wider button
                  elevation: 2, // Optional: add elevation for shadow effect
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RaiseTicket()), // Navigate to SosPage
                  );
                },
                child: Text(
                  'Raise Ticket',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: tasks.isEmpty
          ? buildShimmerLoading()
          : RefreshIndicator(
              onRefresh: fetchTaskData,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: displayedTasksCount +
                    (reachedEnd ? 0 : 1), // +1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < tasks.length) {
                    return TaskItem(
                      task: tasks[index],
                      onTap: () {
                        storeTaskInfo(
                            tasks[index].taskId, tasks[index].siteAddress);
                      },
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
    );
  }

  Widget buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6, // Number of skeletons you want to show
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color.fromARGB(255, 219, 220, 220),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                // Placeholder for an avatar or icon
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 10,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 10,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDialogOption(IconData icon, String text, VoidCallback onPressed) {
    return TextButton(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black, // Icon color set to black
          ),
          SizedBox(width: 8), // Padding between icon and text
          Text(
            text,
            style: TextStyle(
              color: Colors.black, // Text color set to black
            ),
          ),
        ],
      ),
      onPressed: () {
        onPressed();
        Navigator.pop(context); // Close the dialog
      },
    );
  }
}

class Task {
  final String taskId;
  final String taskNumber;
  final String date;
  final String description;
  final String siteAddress;
  final String priority;
  final String status;
  final String attachmentLink;

  Task({
    required this.taskId,
    required this.taskNumber,
    required this.date,
    required this.description,
    required this.siteAddress,
    required this.priority,
    required this.status,
    required this.attachmentLink,
  });
}

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  TaskItem({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formatting date to DD-MM-yyyy format
    DateTime dateTime = DateTime.parse(task.date);
    String formattedDate =
        '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year.toString()}';

    // Determine status text and color based on status value
    String statusText = '';
    Color statusColor = Colors.black;
    switch (task.status) {
      case 'Pending':
        statusText = 'Pending';
        statusColor = Colors.red;
        break;
      case 'Started':
        statusText = 'Started';
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusText = 'Completed';
        statusColor = Colors.green;
        break;
      case 'In Process':
        statusText = 'In Process';
        statusColor = Colors.orange;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: Text(
                statusText,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket ID: ${task.taskNumber}',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.backgroundtext,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date: $formattedDate',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Color(0xFF353B43),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Query Type: ${task.priority}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Color(0xFF353B43),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
