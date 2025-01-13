// To parse this JSON data, do
//
//     final addannouncementresponse = addannouncementresponseFromJson(jsonString);

// import 'dart:convert';

// List<RaiseUserQueryResponse> RaiseUserQueryResponseFromJson(String str) =>
//     List<RaiseUserQueryResponse>.from(
//         json.decode(str).map((x) => RaiseUserQueryResponse.fromJson(x)));

// String RaiseUserQueryResponseToJson(List<RaiseUserQueryResponse> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class RaiseUserQueryResponse {
//   String? status;
//   String? message;

//   RaiseUserQueryResponse({
//     this.status,
//     this.message,
//   });

//   factory RaiseUserQueryResponse.fromJson(Map<String, dynamic> json) =>
//       RaiseUserQueryResponse(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
// To parse this JSON data, do
//
//     final raiseUserQueryResponse = raiseUserQueryResponseFromJson(jsonString);

import 'dart:convert';

List<RaiseUserQueryResponse> RaiseUserQueryResponseFromJson(String str) => List<RaiseUserQueryResponse>.from(json.decode(str).map((x) => RaiseUserQueryResponse.fromJson(x)));

String RaiseUserQueryResponseToJson(List<RaiseUserQueryResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RaiseUserQueryResponse {
    String? customerId;
    String? subjectId;
    String? description;
    DateTime? createdOn;
    int? data;
    String? status;
    String? message;

    RaiseUserQueryResponse({
        this.customerId,
        this.subjectId,
        this.description,
        this.createdOn,
        this.data,
        this.status,
        this.message,
    });

    factory RaiseUserQueryResponse.fromJson(Map<String, dynamic> json) => RaiseUserQueryResponse(
        customerId: json["customer_id"],
        subjectId: json["subject_id"],
        description: json["description"],
        createdOn: json["created_on"] == null ? null : DateTime.parse(json["created_on"]),
        data: json["data"],
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "subject_id": subjectId,
        "description": description,
        "created_on": createdOn?.toIso8601String(),
        "data": data,
        "status": status,
        "message": message,
    };
}
