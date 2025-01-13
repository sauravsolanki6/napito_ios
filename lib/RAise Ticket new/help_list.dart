import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../API/create_json/createjson.dart';
import '../API/network/networkcall.dart';
import '../API/response/apiuserqueriesresponse.dart';
import '../API/url/urls.dart';
import '../Raise_Ticket/raise_ticket.dart';
import 'help_detail.dart';

class HelpList extends StatefulWidget {
  const HelpList({super.key});

  @override
  State<HelpList> createState() => _HelpListState();
}

class _HelpListState extends State<HelpList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @mustCallSuper
  void initState() {
    super.initState();
    NetworkcallforDard();
  }

  List<UserQuery> carddata = [];
  Future<void> NetworkcallforDard() async {
    try {
      // ProgressDialog.showProgressDialog(context, "title");
      SharedPreferences loginid = await SharedPreferences.getInstance();

      String? userID = loginid.getString('userID') ?? '';

      String createjson1 = createjson().getJsonForuserqueries(
        userID,
      );
      NetworkCall networkCall = NetworkCall();
      List<Object?>? login = await networkCall.postMethod(URLS().apiuserqueries,
          URLS().baseUrl + URLS().apiuserqueriesurl, createjson1, context);
      if (login != null) {
        Navigator.pop(context);

        List<Userqueriesresponse> loginrespon = List.from(login);
        String status = loginrespon[0].status!;
        switch (status) {
          case "true":
            carddata = loginrespon[0].data!;
            setState(() {
              // selectedHelpTypeId = helptypedatalist[0].id!;
            });
            break;
          case "false":
            break;
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(Duration(seconds: 1), () {
          // var _scaffoldKey;
          if (_scaffoldKey.currentState != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Page Refreshed'),
              ),
            );
          }

          final snackBar = SnackBar(
            content: Text(
              'Data refreshed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade500,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(_createRoute("Profile"));
                },
                child: Icon(Icons.arrow_back_ios_outlined)),
            Expanded(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                // // width: 60,

                // decoration: BoxDecoration(
                //   color: const Color(0xFF008357),
                //   // borderRadius: BorderRadius.circular(19),

                // ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Your Tickets',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF303030),
                    ),
                  ),
                ),
              ),
            ),
          ],
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              decoration: const BoxDecoration(),
            ),
          ),
          backgroundColor: const Color(0x3033CC99),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Color(0xFFe9f8fd),
        body: Container(
          color: Color(0x3033CC99),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (carddata.isNotEmpty)
              Container(
                padding: EdgeInsets.only(right: 15, left: 15),
                margin: const EdgeInsets.only(top: 10),
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF008357)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    // Handle button press action
                    Navigator.of(context).push(_createRoute("RaiseTicket"));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Raise Ticket',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: carddata.isNotEmpty
                  ? ListView.builder(
                      itemCount: carddata.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      helpDetail(carddata: carddata[index])),
                            ),
                            child: TicketList(carddata[index]),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 150),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('assest/parcelhand.png'),
                                  const SizedBox(height: 30),
                                  const Text(
                                    'No Data Found!',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFF008357)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              _createRoute("RaiseTicket"));
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            'Raise Ticket',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

Route _createRoute(String pageName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      Widget page;

      page = RaiseTicket();

      switch (pageName) {
        case 'RaiseTicket':
          page = RaiseTicket();
          break; //Profile
        case 'Profile':
          // page = Profile();
          break;
      }

      return page;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var fadeAnimation = animation;

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

Widget TicketList(UserQuery carddata) {
  String dateTimeString = carddata.ticketdatetime ?? "Not Available";
  DateTime? dateTime = DateTime.tryParse(dateTimeString);

  String formattedDate = dateTime != null
      ? "${dateTime.day}-${dateTime.month}-${dateTime.year}"
      : "Not Available";

  String formattedTime = dateTime != null
      ? DateFormat('h:mm a').format(dateTime)
      : "Not Available";

  print(formattedTime);
  return Container(
    margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 0),
    padding: EdgeInsets.only(left: 20, right: 20),
    decoration: BoxDecoration(
      color: Color(0xffffffff),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            'Ticket No: ${carddata.supportId ?? "Not Found"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Question : ${carddata.helpType ?? "Not Available"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Attachments : ${carddata.attachments ?? "Not Available"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Date : ${formattedDate ?? "Not Available"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Time : ${formattedTime ?? "Not Available"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${carddata.finalresolutionstatustext ?? "Not Available"}',
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
  );
}
