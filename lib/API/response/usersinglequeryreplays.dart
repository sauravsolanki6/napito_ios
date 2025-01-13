// To parse this JSON data, do
//
//     final apiUserSingleQueryReplays = apiUserSingleQueryReplaysFromJson(jsonString);

import 'dart:convert';

List<ApiUserSingleQueryReplays> apiUserSingleQueryReplaysFromJson(String str) =>
    List<ApiUserSingleQueryReplays>.from(
        json.decode(str).map((x) => ApiUserSingleQueryReplays.fromJson(x)));

String apiUserSingleQueryReplaysToJson(List<ApiUserSingleQueryReplays> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ApiUserSingleQueryReplays {
  String? status;
  String? message;
  List<ApiUserSingleQueryReplaysDatum>? data;

  ApiUserSingleQueryReplays({
    this.status,
    this.message,
    this.data,
  });

  factory ApiUserSingleQueryReplays.fromJson(Map<String, dynamic> json) =>
      ApiUserSingleQueryReplays(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ApiUserSingleQueryReplaysDatum>.from(json["data"]!
                .map((x) => ApiUserSingleQueryReplaysDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ApiUserSingleQueryReplaysDatum {
  String? replayId;
  String? message;
  String? datetime;
  String? replayBy;
  String? name;

  ApiUserSingleQueryReplaysDatum({
    this.replayId,
    this.message,
    this.datetime,
    this.replayBy,
    this.name,
  });

  factory ApiUserSingleQueryReplaysDatum.fromJson(Map<String, dynamic> json) =>
      ApiUserSingleQueryReplaysDatum(
        replayId: json["replay_id"],
        message: json["message"],
        datetime: json["datetime"],
        replayBy: json["replay_by"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "replay_id": replayId,
        "message": message,
        "datetime": datetime,
        "replay_by": replayBy,
        "name": name,
      };
}
