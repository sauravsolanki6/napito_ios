// To parse this JSON data, do
//
//     final userqueriesresponse = userqueriesresponseFromJson(jsonString);

import 'dart:convert';

List<HelpTypesResponse> helptypeFromresponseJson(String str) => List<HelpTypesResponse>.from(json.decode(str).map((x) => HelpTypesResponse.fromJson(x)));

String helptypeFromresponseToJson(List<HelpTypesResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HelpTypesResponse {
    String? status;
    String? message;
    List<HelpTypeFromResponseDatum>? data;

    HelpTypesResponse({
        this.status,
        this.message,
        this.data,
    });

    factory HelpTypesResponse.fromJson(Map<String, dynamic> json) => HelpTypesResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : List<HelpTypeFromResponseDatum>.from(json["data"].map((x) => HelpTypeFromResponseDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class HelpTypeFromResponseDatum {
    String? id;
    String? helpType;

    HelpTypeFromResponseDatum({
        this.id,
        this.helpType,
    });

    factory HelpTypeFromResponseDatum.fromJson(Map<String, dynamic> json) => HelpTypeFromResponseDatum(
        id: json["id"],
        helpType: json["help_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "help_type": helpType,
    };
}
