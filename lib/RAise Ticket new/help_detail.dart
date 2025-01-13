import 'package:flutter/material.dart';
import 'package:ms_salon_task/API/response/submituserquerreplayresponse.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../API/create_json/createjson.dart';
import '../API/network/networkcall.dart';
import '../API/response/apiuserqueriesresponse.dart';
import '../API/response/usersinglequeryreplays.dart';
import '../API/url/urls.dart';

class helpDetail extends StatefulWidget {
  final UserQuery? carddata;
  helpDetail({Key? key, this.carddata}) : super(key: key);

  @override
  State<helpDetail> createState() => _helpDetailState();
}

String? replydata;

class _helpDetailState extends State<helpDetail> {
  bool _showImage = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _replyController = TextEditingController();
  List<ApiUserSingleQueryReplaysDatum> replaystoshowdata = [];

  @mustCallSuper
  void initState() {
    super.initState();
    NetworkcallforShowReplay();
  }

  Future<void> NetworkcallforReplay(String description) async {
    String reply = _replyController.text;
    try {
      // ProgressDialog.showProgressDialog(context, "title");
      SharedPreferences loginid = await SharedPreferences.getInstance();

      String? userID = loginid.getString('userID') ?? '';

      String createjson1 = createjson().getJsonForsubmituserqueryreply(
        userID,
        widget.carddata!.helpTypeId!,
        reply,
      );
      NetworkCall networkCall = NetworkCall();
      List<Object?>? login = await networkCall.postMethod(
        URLS().apisubmituserqueryreplayapi,
        URLS().baseUrl + URLS().apisubmituserqueryreplay,
        createjson1,
        context,
      );
      if (login != null) {
        Navigator.pop(context);

        List<Submituserqueryreplayresponse> loginrespon = List.from(login);
        String status = loginrespon[0].status!;
        if (status == "true") {
          setState(() {
            replaystoshowdata.add(
              ApiUserSingleQueryReplaysDatum(
                replayBy: "user",
                message: reply,
                datetime: DateTime.now().toString(),
              ),
            );
          });
          SnackBar(
            content: Text("Successfully added"),
          );
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> NetworkcallforShowReplay() async {
    try {
      // ProgressDialog.showProgressDialog(context, "title");
      SharedPreferences loginid = await SharedPreferences.getInstance();

      String? userID = loginid.getString('userID') ?? '';

      String createjson1 = createjson().getJsonForusersinglequeryreplays(
        userID,
        widget.carddata!.helpTypeId!,
      );
      NetworkCall networkCall = NetworkCall();
      List<Object?>? login = await networkCall.postMethod(
        URLS().apireplyapi,
        URLS().baseUrl + URLS().apigetreplyurl,
        createjson1,
        context,
      );
      if (login != null) {
        Navigator.pop(context);

        List<ApiUserSingleQueryReplays> loginrespon = List.from(login);
        String status = loginrespon[0].status!;
        if (status == "true") {
          setState(() {
            replaystoshowdata = loginrespon[0].data!;
          });
          SnackBar(
            content: Text("Successfully added"),
          );
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
        return Future.delayed(Duration(seconds: 1), () {});
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.0),
            child: Container(
              decoration: BoxDecoration(),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(0x3033CC99),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 0),
              Row(
                children: [
                  Text(
                    'Ticket Details',
                    style: TextStyle(
                      color: Color(0xFF303030),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 50),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Color(0xFFFFFFFF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(color: Color(0x3033CC99)),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 0,
                        bottom: 20,
                      ),
                      padding: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Ticket No: ${widget.carddata!.supportId ?? "Not Available"}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Question : ${widget.carddata!.helpType}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Description :",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "${widget.carddata!.description}",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 20),
                          widget.carddata!.attachmentLink!.isNotEmpty
                              ? Text(
                                  "Attachment :",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration:
                                    widget.carddata!.attachmentLink!.isNotEmpty
                                        ? BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2.0,
                                            ),
                                          )
                                        : null,
                                child: widget
                                        .carddata!.attachmentLink!.isNotEmpty
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.network(
                                            "${widget.carddata!.attachmentLink}",
                                            fit: BoxFit.contain,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color:
                                                            Color(0xFF008357)),
                                              );
                                            },
                                          ),
                                          Positioned.fill(
                                            child: Center(
                                              child: Icon(Icons.error),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0x3033CC99),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: replaystoshowdata.length,
                                  itemBuilder: (context, index) {
                                    bool isUserReply =
                                        replaystoshowdata[index].replayBy ==
                                            "user";

                                    return Row(
                                      mainAxisAlignment: isUserReply
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7),
                                          child: Card(
                                            color: Color(0xFFADE0F5),
                                            elevation: 0.7,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide(
                                                color: Colors.green.shade300,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.0,
                                                  vertical: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isUserReply
                                                        ? "Me: "
                                                        : "Admin Reply:",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF424752),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  replaystoshowdata[index]
                                                          .message!
                                                          .isNotEmpty
                                                      ? Text(
                                                          '${replaystoshowdata[index].message ?? ""}',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF424752),
                                                          ),
                                                          softWrap: true,
                                                        )
                                                      : Container(),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    '${replaystoshowdata[index].datetime ?? ""}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF424752),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 8),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                      255, 219, 213, 213)
                                                  .withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          cursorColor: Colors.green,
                                          controller: _replyController,
                                          decoration: InputDecoration(
                                            // hintText: 'Reply',
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            labelText: "Reply",
                                            floatingLabelStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(
                                                  0xFF008357), // Color of floating label when focused
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 252, 250, 250),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 20),
                                          ),
                                          minLines: 6,
                                          maxLines: 6,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter a reply';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 1.0),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            String description =
                                                _replyController.text;

                                            if (_formKey.currentState!
                                                .validate()) {
                                              await NetworkcallforReplay(
                                                  description);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF008357),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            minimumSize:
                                                Size(double.infinity, 50),
                                          ),
                                          child: Text(
                                            'Send',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
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
      ),
    );
  }
}
