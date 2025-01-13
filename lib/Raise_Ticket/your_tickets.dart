import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ms_salon_task/Raise_Ticket/ticket_details.dart';
import 'package:ms_salon_task/Raise_Ticket/raise_ticket.dart';

import '../Colors/custom_colors.dart';
import '../main.dart';

class YourTicketsPage extends StatefulWidget {
  @override
  _YourTicketsPageState createState() => _YourTicketsPageState();
}

class _YourTicketsPageState extends State<YourTicketsPage> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 6;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasMore) {
          _page++;
          _fetchData();
        }
      }
    });
  }

  Future<void> _fetchData() async {
    if (!_hasMore && !_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerID = prefs.getString('customer_id') ?? '';
    String branchID = prefs.getString('branch_id') ?? '';
    String salonID = prefs.getString('salon_id') ?? '';

    String customerID2 = prefs.getString('customer_id2') ?? '';
    if (customerID2.isNotEmpty && customerID2 != customerID) {
      customerID = customerID2;
    }

    final url = '${MyApp.apiUrl}customer/queries/';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'customer_id': customerID,
      'salon_id': salonID,
      'branch_id': branchID,
      'page': _page,
      'page_size': _pageSize,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data');

        if (data['status'] == 'true') {
          List<dynamic> ticketList = data['data'];
          setState(() {
            if (ticketList.length < _pageSize) {
              _hasMore = false;
            }
            if (_page == 1) {
              _tickets = ticketList
                  .take(6)
                  .map((item) => Ticket.fromJson(item))
                  .toList();
            } else {
              _tickets.addAll(
                  ticketList.map((item) => Ticket.fromJson(item)).toList());
            }
            _isLoading = false;
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _hasMore = true;
      _tickets.clear();
    });
    await _fetchData();
  }

  Future<void> _handleTicketTap(String ticketId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ticket_id', ticketId);

    print('Selected Ticket ID: $ticketId');

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
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('Your Tickets'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RaiseTicket(),
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.0),
          children: [
            _isLoading && _tickets.isEmpty
                ? _buildSkeletonLoader()
                : Column(
                    children: [
                      for (int index = 0; index < _tickets.length; index++)
                        Column(
                          children: [
                            TicketItem(
                              id: _tickets[index].id,
                              ticketNumber: _tickets[index].supportId,
                              question: _tickets[index].description,
                              date: _tickets[index].ticketDateTime,
                              query_type: _tickets[index].query_type,
                              pending:
                                  _tickets[index].finalResolutionStatusText ==
                                      'Pending',
                              onTap: () => _handleTicketTap(_tickets[index].id),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(
        _pageSize,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 40,
                      height: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: 200,
                  height: 14,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TicketItem extends StatelessWidget {
  final String id;
  final String ticketNumber;
  final String question;
  final String date;
  final String query_type;
  final bool pending;
  final VoidCallback onTap;

  TicketItem({
    required this.id,
    required this.ticketNumber,
    required this.question,
    required this.date,
    required this.pending,
    required this.onTap,
    required this.query_type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket No: $ticketNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.backgroundtext,
                  ),
                ),
                if (pending)
                  Row(
                    children: [
                      SizedBox(width: 5),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Query Type: $query_type',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $date',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Ticket {
  final String id;
  final String supportId;
  final String ticketDateTime;
  final String description;
  final String finalResolutionStatusText;
  final String query_type;

  Ticket({
    required this.id,
    required this.supportId,
    required this.ticketDateTime,
    required this.description,
    required this.finalResolutionStatusText,
    required this.query_type,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      supportId: json['support_id'] ?? '',
      ticketDateTime: json['ticket_datetime'] ?? '',
      description: json['description'] ?? '',
      query_type: json['query_type'] ?? '',
      finalResolutionStatusText: json['final_resolution_status_text'] ?? '',
    );
  }
}
