// import 'package:chat_application/customdesigns/snackbardesign.dart';
// import 'package:chat_application/responsefromserver/creatememberresponse.dart';
// import 'package:chat_application/responsefromserver/getmemberprofileresponse.dart';
// import 'package:chat_application/responsefromserver/loginresponse.dart';
// import 'package:chat_application/responsefromserver/operationresponse.dart';
// import 'package:chat_application/responsefromserver/uniquemobilenumberresponse.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../response/ApiFaqsResponse.dart';
import '../response/Apiuseraddressresponse.dart';
import '../response/UserSingleQuery.dart';
import '../response/apihelptypesresponse.dart';
import '../response/apiuserqueriesresponse.dart';
import '../response/raiseuserqueryresponse.dart';
import '../response/submituserquerreplayresponse.dart';
import '../response/usersinglequeryreplays.dart';
// import 'package:logistics_app/splash/snackbardesign.dart';

// import '../responsefromserver/getmemberlistresponse.dart';

class NetworkCall {
  Future<List<Object?>?> postMethod(
      int requestCode, String url, String body, BuildContext context) async {
    var response = await http.post(Uri.parse(url), body: body);
    log("URL: $url");
    log("body: $body");

    // var data = response.body;
    try {
      if (response.statusCode == 200) {
        String ResponseString = response.body;

        String str = "[" + ResponseString + "]";
        log(str);

        switch (requestCode) {
          // case 1: //Login
          //   final idd = jsonDecode(ResponseString);
          //   print("my data is : '$str'");
          //   final id = idd['id'].toString();
          //   print("my id is : $id");
          //   Future<void> setID(String id) async {
          //     SharedPreferences prefs = await SharedPreferences.getInstance();
          //     await prefs.setString('userID', id);
          //   }
          //   await setID(id);
          // final loginresponse =
          //     Loginresponse.fromJson(str as Map<String, dynamic>);
          // return [loginresponse];
          // case 2: //Unique Mobile Number
          //   final profilepic =
          //       Uploadprofileresponse.fromJson(str as Map<String, dynamic>);
          //   return [profilepic];
          // case 3: //Get Profile
          //   final getprofileresponse = getprofileresponseFromJson(str);
          //   return getprofileresponse;

          // case 4:
          //   final memberlistresponse = citiyselectresponceFromJson(str);
          //   return memberlistresponse;
          // case 5: //Member Profile
          //   // print('this is my responce : ${str}');
          //   final getcitystop = getCitystoprespnceFromJson(str);
          //   return getcitystop;

          // case 6: //Operation
          //   final getcitytostop = getCitystoprespnceFromJson(str);
          //   return getcitytostop;

          // case 7: //Operation
          //   final getWeight = getWeightresponseFromJson(str);
          //   return getWeight;

          // case 8: //Operation
          //   final getBuslisting = getbuslistresponseFromJson(str);
          //   return getBuslisting;

          // case 9: //Operation
          //   final getBuslisting = vehicletyperesponceFromJson(str);
          //   return getBuslisting;

          // case 10: //Operation
          //   final getBuslisting = ordersubmitresponseFromJson(str);
          //   return getBuslisting;
          // case 11: //Operation
          //   final getBuslisting = ConsignmentresponceFromJson(str);
          //   return getBuslisting;

          // case 12:
          //   final memberlistresponse = citiyselectresponceFromJson(str);
          //   return memberlistresponse;

          // case 13:
          //   final memberlistresponse = getorderlistresponseFromJson(str);
          //   return memberlistresponse;

          // case 14:
          //   final memberlistresponse = getorderlistresponseFromJson(str);
          //   return memberlistresponse;

          // case 15:
          //   final memberlistresponse = getsingleorderresponseFromJson(str);
          //   return memberlistresponse;

          // case 16:
          //   final memberlistresponse = profilepicresponseFromJson(str);
          //   return memberlistresponse;

          // case 17:
          //   final memberlistresponse = getprofilepicresponseFromJson(str);
          //   return memberlistresponse;
          // case 18:
          //   final getnoteresponse = getnoteresponseFromJson(str);
          //   return getnoteresponse;
          case 19:
            final userqueries = userqueriesresponseFromJson(str);
            return userqueries;
          case 20:
            final helptype = helptypeFromresponseJson(str);
            return helptype;
          case 21:
            final usersinglequery = userSingleQueryResponseFromJson(str);
            return usersinglequery;
          case 22:
            final raiseuserquery = RaiseUserQueryResponseFromJson(str);
            return raiseuserquery;
          case 23:
            final showreplyresponse = apiUserSingleQueryReplaysFromJson(
                str); //to show reply after sending reply from client,it is admin reply
            return showreplyresponse;
          case 24:
            final submituserqueryreplay =
                submituserqueryreplayresponseFromJson(str);
            return submituserqueryreplay; //apiuseraddressresponseFromJson
          case 25:
            final submituserqueryreplay = apiuseraddressresponseFromJson(str);
            return submituserqueryreplay; //apiFaqsResponseFromJson
          case 26:
            final submituserqueryreplay = apiFaqsResponseFromJson(str);
            return submituserqueryreplay;
        }
      } else if (response.statusCode == 400) {
        switch (requestCode) {
          case 1:
            break;
          case 2:
            break;
          case 3:
            break;
          case 4:
            break;
          case 5:
            break;
          case 6:
            break;
          case 7:
            break;
          case 8:
            break;
        }
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      SnackBar(
        content: Text("Something went wrong"),
      );
    }
    return null;
  }

  getMethod(
      int profileUrl, String s, String profileString, BuildContext context) {}
}
