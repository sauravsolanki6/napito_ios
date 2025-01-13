// To parse this JSON data, do
//
//     final apiuseraddressresponse = apiuseraddressresponseFromJson(jsonString);

import 'dart:convert';

List<Apiuseraddressresponse> apiuseraddressresponseFromJson(String str) =>
    List<Apiuseraddressresponse>.from(
        json.decode(str).map((x) => Apiuseraddressresponse.fromJson(x)));

String apiuseraddressresponseToJson(List<Apiuseraddressresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Apiuseraddressresponse {
  String? status;
  String? message;
  List<ApiuseraddressresponseDatum>? data;

  Apiuseraddressresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Apiuseraddressresponse.fromJson(Map<String, dynamic> json) =>
      Apiuseraddressresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ApiuseraddressresponseDatum>.from(json["data"]!
                .map((x) => ApiuseraddressresponseDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ApiuseraddressresponseDatum {
  String? addressId;
  String? address;
  String? locality;
  String? pincode;
  String? latitude;
  String? longitude;
  String? name;
  String? companyName;
  String? email;
  String? gstNo;
  String? phoneNo;
  String? map_address;
  ApiuseraddressresponseDatum({
    this.addressId,
    this.address,
    this.locality,
    this.pincode,
    this.latitude,
    this.longitude,
    this.name,
    this.companyName,
    this.email,
    this.gstNo,
    this.phoneNo,
    this.map_address,
  });

  factory ApiuseraddressresponseDatum.fromJson(Map<String, dynamic> json) =>
      ApiuseraddressresponseDatum(
        addressId: json["address_id"],
        address: json["address"],
        locality: json["locality"],
        pincode: json["pincode"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        name: json["name"],
        companyName: json["company_name"],
        email: json["email"],
        gstNo: json["gst_no"],
        phoneNo: json["phone_no"],
        map_address :json["map_address"],
      );

  Map<String, dynamic> toJson() => {
        "address_id": addressId,
        "address": address,
        "locality": locality,
        "pincode": pincode,
        "latitude": latitude,
        "longitude": longitude,
        "name": name,
        "company_name": companyName,
        "email": email,
        "gst_no": gstNo,
        "phone_no": phoneNo,
        "map_address":map_address,
      };
}
