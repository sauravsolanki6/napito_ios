import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class TicketDetails extends StatefulWidget {
  @override
  _TicketDetailsState createState() => _TicketDetailsState();
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        enableRotation: true,
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}

class _TicketDetailsState extends State<TicketDetails> {
  // State variables to hold the API response data

  String _ticketNo = '';
  String _description = '';
  String _date = '';
  String _queryType = '';
  String _attachmentLink = '';
  List<Map<String, dynamic>> _replies = []; // List to store replies

  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _downloadImage(String url) async {
    try {
      // Get the directory to save the file
      final directory = await getExternalStorageDirectory();
      final filePath =
          '${directory!.path}/downloaded_image.jpg'; // You can customize the filename

      // Create a Dio instance
      final dio = Dio();

      // Start downloading
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download complete: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchTicketDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String customerID = prefs.getString('customer_id') ?? '';
    String customerID2 = prefs.getString('customer_id2') ?? '';

    if (customerID2.isNotEmpty && customerID2 != customerID) {
      customerID = customerID2;
    }

    final selectedTicketID = prefs.getString('selected_ticket_id') ?? '';

    if (customerID.isNotEmpty && selectedTicketID.isNotEmpty) {
      final url = Uri.parse('${MyApp.apiUrl}customer/single-query/');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'customer_id': customerID,
            'selected_ticket_id': selectedTicketID,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'true' && data['data'] != null) {
            final ticketDataList = data['data'] as List;
            if (ticketDataList.isNotEmpty) {
              final ticketData = ticketDataList[0];
              setState(() {
                _ticketNo = ticketData['support_id'] ?? 'No Ticket No';
                _description = ticketData['description'] ?? 'No Description';
                _date = ticketData['ticket_datetime'] ?? 'No Date';
                _queryType = ticketData['query_type'] ?? 'No Query Type';
                _attachmentLink = ticketData['attachment_link'] ??
                    ''; // Set the attachment link
              });
              // Fetch query replies after successfully fetching ticket details
              await _fetchQueryReplies(customerID, selectedTicketID);
            } else {
              _handleDataLoadFailure('No data found.');
            }
          } else {
            _handleDataLoadFailure('Failed to load ticket details.');
          }
        } else {
          _handleDataLoadFailure('Failed to load data.');
        }
      } catch (e) {
        _handleDataLoadFailure('Error occurred: $e');
      }
    } else {
      _handleDataLoadFailure('Customer ID or selected ticket ID is missing.');
    }
  }

  void _viewImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _fetchQueryReplies(
      String customerID, String selectedTicketID) async {
    final url = Uri.parse('${MyApp.apiUrl}customer/query-replays');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerID,
          'selected_ticket_id': selectedTicketID,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'true' && data['data'] != null) {
          setState(() {
            _replies = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print('No replies found');
        }
      } else {
        print('Failed to load query replies');
      }
    } catch (e) {
      print('Error occurred while fetching query replies: $e');
    }
  }

  void _sendReply() async {
    final prefs = await SharedPreferences.getInstance();
    String customerID = prefs.getString('customer_id') ?? '';
    String selectedTicketID = prefs.getString('selected_ticket_id') ?? '';

    final newReply = _replyController.text.trim();

    if (newReply.isEmpty) {
      // Show a snackbar if the reply field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please type a reply before sending.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // API URL
    final url = Uri.parse('${MyApp.apiUrl}customer/submit-query-replay/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerID,
          'selected_ticket_id': selectedTicketID,
          'replay': newReply,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response from server: $data');

        if (data['status'] == 'true') {
          setState(() {
            _replies.add({
              'name': 'You', // or any identifier for the user
              'reply_by': 'You',
              'message': newReply,
              'datetime': DateTime.now().toString(),
            });
          });

          _replyController.clear();

          // Refresh the replies to reflect the latest data
          await _fetchQueryReplies(customerID, selectedTicketID);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reply sent successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reply.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Failed to send reply. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reply.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error occurred while sending reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while sending reply.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    // Call the method to fetch ticket details and replies
    await _fetchTicketDetails();
  }

  void _handleDataLoadFailure(String message) {
    setState(() {
      _ticketNo = message;
      _description = message;
      _date = message;
      _queryType = message;
      _attachmentLink = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // To get the height of the keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.top;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
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
              'Ticket Details',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket No: $_ticketNo',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Query Type: $_queryType',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Date: $_date',
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Description: $_description',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Attachment: ',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              if (_attachmentLink != null &&
                                  _attachmentLink.isNotEmpty) ...[
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => _viewImage(_attachmentLink),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 20,
                                          height: 100,
                                          child: Image.network(
                                            _attachmentLink,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  'Failed to load image',
                                                  style: GoogleFonts.lato(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 100),
                                      IconButton(
                                        icon: Icon(Icons.download,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _downloadImage(_attachmentLink),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else
                                Text(
                                  'No attachment available',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reply = _replies[index];
                      final name = reply['name'];
                      final replyBy = reply['reply_by'];
                      final message = reply['message'];
                      final datetime = reply['datetime'];

                      bool isAdmin =
                          (name != null && name.toLowerCase() == 'admin');

                      return Align(
                        alignment: isAdmin
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                isAdmin ? Colors.grey[200] : Colors.blue[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: isAdmin
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              if (name != null)
                                Text(
                                  '$name${replyBy != null ? ' ($replyBy)' : ''}',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold, // Set to bold
                                    color: Colors.black,
                                  ),
                                ),
                              SizedBox(height: 5),
                              if (message != null) Text(message),
                              SizedBox(height: 5),
                              if (datetime != null)
                                Text(
                                  datetime,
                                  style: GoogleFonts.lato(
                                    color:
                                        Colors.grey[600], // Set the color here
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold, // Set to bold
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _replies.length,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 100,
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
                          child: TextField(
                            controller: _replyController,
                            decoration: InputDecoration(
                              hintText: 'Type your reply here...',
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.lato(
                              // Apply Google Fonts here
                              fontSize: 16, // Set the desired font size
                              color: Colors.black, // Set the desired text color
                            ),
                            maxLines: null, // Allows multiple lines
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: _sendReply,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
