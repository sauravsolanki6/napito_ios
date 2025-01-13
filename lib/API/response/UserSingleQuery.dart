// To parse this JSON data, do
//
//     final userSingleQueryResponse = userSingleQueryResponseFromJson(jsonString);

import 'dart:convert';

List<UserSingleQueryResponse> userSingleQueryResponseFromJson(String str) => List<UserSingleQueryResponse>.from(json.decode(str).map((x) => UserSingleQueryResponse.fromJson(x)));

String userSingleQueryResponseToJson(List<UserSingleQueryResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserSingleQueryResponse {
    String? status;
    String? message;
    dynamic data;

    UserSingleQueryResponse({
        this.status,
        this.message,
        this.data,
    });

    factory UserSingleQueryResponse.fromJson(Map<String, dynamic> json) => UserSingleQueryResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
    };
}
