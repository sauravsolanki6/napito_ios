import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Raise_Ticket/raise_ticket.dart';

class HelpMain extends StatefulWidget {
  const HelpMain({super.key});

  @override
  State<HelpMain> createState() => _HelpMainState();
}

class _HelpMainState extends State<HelpMain> {
  // Future<void> CardContent() async {
  //   try {
  //     ProgressDialog.showProgressDialog(context, "title");
  //      SharedPreferences loginid = await SharedPreferences.getInstance();

  //     ///Here tried to change to btid but it doesnt worked.
  //     String? user_id = loginid.getString('user_id') ?? '';

  //     ///Here i have called createJsonForTeacherprofile() with btid which means it will give argument to body of it.
  //     String createjson1 = createjson().getJsonForhelptypes(
  //       user_id,
  //     );
  //     NetworkCall networkCall = NetworkCall();
  //     List<Object?>? login = await networkCall.postMethod(URLS().apihelptypes,
  //         URLS().baseUrl+URLS().apihelptypesurl, createjson1, context);
  //     if (login != null) {
  //       Navigator.pop(context);

  //       List<HelpTypesResponse> loginrespon = List.from(login!);
  //       String status = loginrespon[0].status!;
  //       switch (status) {
  //         case "true":
  //           helptypedatalist = loginrespon[0].data!;
  //           setState(() {
  //             selectedHelpTypeId = helptypedatalist[0].id!;
  //           });
  //           break;
  //         case "false":
  //           break;
  //       }
  //     } else {
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(const Duration(seconds: 1), () {
          // _scaffoldKey.currentState.showSnackBar(
          //   SnackBar(
          //     content: const Text('Page Refreshed'),
          //   ),
          // );
          //  final snackBar = SnackBar(content: Text('Data refreshed'));
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF008357)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Get.to(() => RaiseTicket());
                },
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Raise Ticket',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
        backgroundColor: const Color(0xFFFFFFFF),
        body: Container(
          color: const Color(0x3033CC99),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 28,
              ),
              true
                  ? Flexible(
                      child: ListView.builder(
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 137,
                              width: 376,
                              padding:
                                  const EdgeInsets.only(left: 20, right: 25),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16), // Added margin for spacing
                              decoration: BoxDecoration(
                                  color: const Color(0x3033CC99),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 17,
                                  ),
                                  Text(
                                    "Ticket No: 02020202020",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    "Can I just come in or do I have to make an appointment?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  const Row(
                                    children: [
                                      Text("Date: 10 May 2024"),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Text("Pending"),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
                  : Container(
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
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     TextButton(
                                //       style: ButtonStyle(
                                //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                //           RoundedRectangleBorder(
                                //             borderRadius: BorderRadius.circular(5.0),
                                //           )
                                //         ),
                                //         backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF008357)),
                                //         foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                //       ),
                                //       onPressed: () {
                                //         Get.to(() => const RaiseTicket());
                                //       },
                                //       child: const Padding(
                                //         padding: EdgeInsets.all(5),
                                //         child: Text('Raise Ticket',
                                //           style: TextStyle(
                                //             fontWeight: FontWeight.w500,
                                //             fontSize: 16
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // const SizedBox(height: 20),
                              ],
                            ),
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
