import 'dart:convert';

import '../call/apifaqscall.dart';
import '../call/apihelptypescall.dart';
import '../call/apiraiseuserquerycall.dart';
import '../call/apisubmituserqueryreplycall.dart';
import '../call/apiuseraddresscall.dart';
import '../call/apiuserqueriescall.dart';
import '../call/apiusersinglequerycall.dart';
import '../call/userreplaycall.dart';

class createjson {
  // String createJsonForLogin(String mobile, String? device_id) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Logincalljson loginjsonCreation =
  //       Logincalljson(mobile: mobile, device_id: device_id);
  //   var result = Logincalljson.fromJson(loginjsonCreation.toJson());
  //   String str = encoder.convert(result);
  //   return str;
  // }

  // String createJsonForprofile(String full_name, String email, String mobile,
  //     String address, String aadhaar_no, String pan_no, String userid) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Updateprofilecall updateprofilejsonCreation = Updateprofilecall(
  //       fullName: full_name,
  //       email: email,
  //       mobile: mobile,
  //       address: address,
  //       aadhaarNo: aadhaar_no,
  //       panNo: pan_no,
  //       userId: userid);
  //   var uploadprofileresult =
  //       Updateprofilecall.fromJson(updateprofilejsonCreation.toJson());
  //   String? uploadprofilestr = encoder.convert(uploadprofileresult);
  //   return uploadprofilestr;
  // }

  // String getJsonForprofile(String id) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Getprofile getidjsonCreation = Getprofile(userId: id);
  //   var uploadresult = Getprofile.fromJson(getidjsonCreation.toJson());
  //   String uploadstr = encoder.convert(uploadresult);
  //   return uploadstr;
  // }

  // String getJsonForcity(String city) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   GetCity getidjsonCreation = GetCity(city: city);
  //   var uploadresult = GetCity.fromJson(getidjsonCreation.toJson());
  //   String uploadstr = encoder.convert(uploadresult);
  //   return uploadstr;
  // }

  // String getJsonForoffice(String office_id) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Officeid getidjsonCreation = Officeid(office_id: office_id);
  //   var uploadresult = Officeid.fromJson(getidjsonCreation.toJson());
  //   String uploadstr = encoder.convert(uploadresult);
  //   return uploadstr;
  // }

  // String getJsonForfromcitystop(
  //     String city, String selecteddate, String ispickup) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Getcityid getidjsonCreation =
  //       Getcityid(city: city, selecteddate: selecteddate, ispickup: ispickup);
  //   var uploadstopresult = Getcityid.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonFortocitystop(
  //     String from_city, String to_city, String is_pickup, String is_drop) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Getcityidto getidjsonCreation = Getcityidto(
  //       from_city: from_city,
  //       to_city: to_city,
  //       is_pickup: is_pickup,
  //       is_drop: is_drop);
  //   var uploadstopresult = Getcityidto.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonForcitytostop(String to_city) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Getcitytoid getidjsonCreation = Getcitytoid(to_city: to_city);
  //   var uploadstopresult = Getcitytoid.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonForbookingform(
  //     String user_id,
  //     String sender_name,
  //     String sender_address,
  //     String sender_email,
  //     String sender_mobile,
  //     String sender_company,
  //     String sender_gst,
  //     String fromcity,
  //     String tocity,
  //     String ispickup,
  //     String isdrop,
  //     String senderstopId,
  //     String senderofficeId,
  //     String receiverstopId,
  //     String receiverofficeId,
  //     String receivervendorId,
  //     String selecteddate,
  //     String parcellist,
  //     String route_id,
  //     String vendor_id,
  //     String price,
  //     String arrivalOnDaysCount,
  //     String scheduleId,
  //     String scheduleVehicleId,
  //     String reciver_name,
  //     String reciver_phone,
  //     String reciver_email,
  //     String reciver_address,
  //     String receiver_company,
  //     String reciver_gst,
  //     String expected_departure,
  //     String expected_arrival,
  //     String collect_address,
  //     String collect_latitude,
  //     String collect_longitude,
  //     String deliver_address,
  //     String deliver_latitude,
  //     String deliver_longitude,
  //     double pickup_charges,
  //     double drop_charges,
  //     double deliver_distance,
  //     double collect_distance,
  //     String collect_vehicle_rate_id,
  //     String deliver_vehicle_rate_id,
  //     double gst_charges,
  //     double platform_charges,
  //     double other_charges,
  //     String consignee_pin,
  //     consignor_pin,
  //     receiver_address_id,
  //     sender_address_id,
  //     expected_arrival_time,
  //     expected_departure_time) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   BookPara getidjosnCreation = BookPara(
  //     user_id: user_id,
  //     sender_name: sender_name,
  //     sender_address: sender_address,
  //     sender_email: sender_email,
  //     sender_mobile: sender_mobile,
  //     sender_company: sender_company,
  //     sender_gst: sender_gst,
  //     fromcity: fromcity,
  //     tocity: tocity,
  //     ispickup: ispickup,
  //     isdrop: isdrop,
  //     senderstopId: senderstopId,
  //     senderofficeId: senderofficeId,
  //     receiverstopId: receiverstopId,
  //     receiverofficeId: receiverofficeId,
  //     receivervendorId: receivervendorId,
  //     selecteddate: selecteddate,
  //     parcellist: parcellist,
  //     route_id: route_id,
  //     vendor_id: vendor_id,
  //     price: price,
  //     arrivalOnDaysCount: arrivalOnDaysCount,
  //     scheduleId: scheduleId,
  //     scheduleVehicleId: scheduleVehicleId,
  //     reciver_name: reciver_name,
  //     reciver_phone: reciver_phone,
  //     reciver_email: reciver_email,
  //     reciver_address: reciver_address,
  //     receiver_company: receiver_company,
  //     reciver_gst: reciver_gst,
  //     expected_departure: expected_departure,
  //     expected_arrival: expected_arrival,
  //     collect_address: collect_address,
  //     collect_latitude: collect_latitude,
  //     collect_longitude: collect_longitude,
  //     deliver_address: deliver_address,
  //     deliver_latitude: deliver_latitude,
  //     deliver_longitude: deliver_longitude,
  //     pickup_charges: pickup_charges,
  //     drop_charges: drop_charges,
  //     deliver_distance: deliver_distance,
  //     collect_distance: collect_distance,
  //     collect_vehicle_rate_id: collect_vehicle_rate_id,
  //     deliver_vehicle_rate_id: deliver_vehicle_rate_id,
  //     gst_charges: gst_charges,
  //     platform_charges: platform_charges,
  //     other_charges: other_charges,
  //     consignor_pin: consignor_pin,
  //     consignee_pin: consignee_pin,
  //     receiver_address_id: receiver_address_id,
  //     sender_address_id: sender_address_id,
  //     expected_arrival_time: expected_arrival_time,
  //     expected_departure_time: expected_arrival_time,
  //   );
  //   var uploadstopresult = BookPara.fromJson(getidjosnCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonForbuslisting(
  //     String FromCityid,
  //     String ToCityid,
  //     String FromStopid,
  //     String ToStopid,
  //     String date,
  //     String Parcels,
  //     int offset,
  //     int limit) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   CallBusListingjson getidjsonCreation = CallBusListingjson(
  //       FromCityid: FromCityid,
  //       ToCityid: ToCityid,
  //       date: date,
  //       FromStopid: FromStopid,
  //       ToStopid: ToStopid,
  //       Parcels: Parcels,
  //       offset: offset,
  //       limit: limit);
  //   var uploadstopresult =
  //       CallBusListingjson.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonFororderlist(String user_id) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   CallUserid getidjsonCreation = CallUserid(
  //     user_id: user_id,
  //   );
  //   var uploadstopresult = CallUserid.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonForsingleorderdetails(String user_id, String order_id) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   CallOrderdetails getidjsonCreation =
  //       CallOrderdetails(user_id: user_id, order_id: order_id);
  //   var uploadstopresult =
  //       CallOrderdetails.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getJsonForprofilepic(
  //     String user_id, String profile_pic_name, String profile_pic_base64) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Callprofilepic getidjsonCreation = Callprofilepic(
  //       user_id: user_id,
  //       profile_pic_name: profile_pic_name,
  //       profile_pic_base64: profile_pic_base64);
  //   var uploadstopresult = Callprofilepic.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // String getlistofbus(
  //     String FromCityid,
  //     String ToCityid,
  //     String FromStopid,
  //     String ToStopid,
  //     String date,
  //     String Parcels,
  //     String maxprice,
  //     String minprice,
  //     String mindays,
  //     String maxdays,
  //     String nonstop,
  //     String priceSort,
  //     String arrivalOn,
  //     String departureOn,
  //     int offset,
  //     int limit,
  //     String is_pickup,
  //     String is_drop) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   Getbuslistcall getidjsonCreation = Getbuslistcall(
  //     fromCityid: FromCityid,
  //     toCityid: ToCityid,
  //     date: date,
  //     fromStopid: FromStopid,
  //     toStopid: ToStopid,
  //     parcels: Parcels,
  //     maxPrice: maxprice,
  //     minPrice: minprice,
  //     minDays: mindays,
  //     maxDays: maxdays,
  //     nonStop: nonstop,
  //     priceSort: priceSort,
  //     arrivalOn: arrivalOn,
  //     departureOn: departureOn,
  //     offset: offset,
  //     limit: limit.toString(),
  //     is_pickup: is_pickup,
  //     is_drop: is_drop,
  //   );
  //   var uploadstopresult = Getbuslistcall.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  // //apiallowedearlymincall
  // String getJsonForNote(String is_pickup) {
  //   JsonEncoder encoder = JsonEncoder.withIndent('');
  //   CallNotedetails getidjsonCreation = CallNotedetails(is_pickup: is_pickup);
  //   var uploadstopresult = CallNotedetails.fromJson(getidjsonCreation.toJson());
  //   String uploadstopstr = encoder.convert(uploadstopresult);

  //   return uploadstopstr;
  // }

  //apiuserqueries-card
  String getJsonForuserqueries(String user_id) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    ApiUserQueriesCall getidjsonCreation = ApiUserQueriesCall(user_id: user_id);
    var uploadstopresult =
        ApiUserQueriesCall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  //apihelptypes-dropdwn
  String getJsonForhelptypes(String user_id) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    ApiHelpTypesCall getidjsonCreation = ApiHelpTypesCall(user_id: user_id);
    var uploadstopresult =
        ApiHelpTypesCall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  String getJsonForusersinglequery(String user_id, String selected_ticket_id) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    ApiUserSingleQuerycall getidjsonCreation = ApiUserSingleQuerycall(
        user_id: user_id, selected_ticket_id: selected_ticket_id);
    var uploadstopresult =
        ApiUserSingleQuerycall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  String getJsonForraiseuserquery(String user_id, String selected_help_type,
      String description, String attachment) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    ApiRaiseUserQueryCall getidjsonCreation = ApiRaiseUserQueryCall(
        user_id: user_id,
        selected_help_type: selected_help_type,
        description: description,
        attachment: attachment);
    var uploadstopresult =
        ApiRaiseUserQueryCall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  String getJsonForusersinglequeryreplays(
      String user_id, String selected_ticket_id) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    UserReplayCall getidjsonCreation = UserReplayCall(
        user_id: user_id, selected_ticket_id: selected_ticket_id);
    var uploadstopresult = UserReplayCall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  String getJsonForsubmituserqueryreply(
    String user_id,
    String selected_help_type,
    String replay,
  ) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    ApiSubmitUserQueryReplyCall getidjsonCreation = ApiSubmitUserQueryReplyCall(
        user_id: user_id,
        selected_ticket_id: selected_help_type,
        replay: replay);
    var uploadstopresult =
        ApiSubmitUserQueryReplyCall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  //new to get address foy use previous address
  String getJsonForapiuseradress(String user_id, String address_type) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    apiuseraddresscall getidjsonCreation =
        apiuseraddresscall(user_id: user_id, address_type: address_type);
    var uploadstopresult =
        apiuseraddresscall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }

  String getJsonForApiFaqs(String user_id) {
    JsonEncoder encoder = JsonEncoder.withIndent('');
    apifaqscall getidjsonCreation = apifaqscall(user_id: user_id);
    var uploadstopresult = apifaqscall.fromJson(getidjsonCreation.toJson());
    String uploadstopstr = encoder.convert(uploadstopresult);

    return uploadstopstr;
  }
}
