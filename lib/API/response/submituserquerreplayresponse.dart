// To parse this JSON data, do
//
//     final submituserqueryreplayresponse = submituserqueryreplayresponseFromJson(jsonString);

import 'dart:convert';

List<Submituserqueryreplayresponse> submituserqueryreplayresponseFromJson(String str) => List<Submituserqueryreplayresponse>.from(json.decode(str).map((x) => Submituserqueryreplayresponse.fromJson(x)));

String submituserqueryreplayresponseToJson(List<Submituserqueryreplayresponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Submituserqueryreplayresponse {
    String? data;
    String? status;
    String? message;

    Submituserqueryreplayresponse({
        this.data,
        this.status,
        this.message,
    });

    factory Submituserqueryreplayresponse.fromJson(Map<String, dynamic> json) => Submituserqueryreplayresponse(
        data: json["data"],
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "status": status,
        "message": message,
    };
}
