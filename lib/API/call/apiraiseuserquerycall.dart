// To parse this JSON data, do
//
//     final addannouncementcall = addannouncementcallFromJson(jsonString);

import 'dart:convert';

ApiRaiseUserQueryCall ApiRaiseUserQueryCallFromJson(String str) =>
    ApiRaiseUserQueryCall.fromJson(json.decode(str));

String addannouncementcallToJson(ApiRaiseUserQueryCall data) =>
    json.encode(data.toJson());

class ApiRaiseUserQueryCall {
  String? user_id;
  String? selected_help_type;
  String? description;
  String? attachment;
  // List<int>? studentIds;
  // List<int>? batchIds;
  // List<int>? courseids;
  // List<int>? locationids;

  // DateTime? fromDate;
  // DateTime? toDate;

  ApiRaiseUserQueryCall({
    this.user_id,
    this.selected_help_type,
    this.description,
    this.attachment,
    // this.studentIds,
    // this.batchIds,
    // this.courseids,
    // this.locationids,
    // this.fromDate,
    // this.toDate,
  });
//**
//1.The Use of this file is to post() because we are writing data inside table by using this file.
//2. the return type  is factory so its must be different which is not expected to be returned.
//3. so we are returning the Normal contructor from namedconstructor.
//4.but i dont think it is neccesary because we can write with normal constructor which is written in returning object.
//5.and toJson do the opposite of fromJson i.e fromJson do the String to Key value while toJson will do json to String but why?
// */
  factory ApiRaiseUserQueryCall.fromJson(Map<String, dynamic> json) =>
      ApiRaiseUserQueryCall(
        user_id: json["user_id"],
        selected_help_type: json["selected_help_type"],
        description: json["description"],
        attachment: json["attachment"],
        // studentIds: json["student_ids"] == null
        //     ? []
        //     : List<int>.from(json["student_ids"]!.map((x) => x)),
        // batchIds: json["batch_ids"] == null
        //     ? []
        //     : List<int>.from(json["batch_ids"]!.map((x) => x)),
        // // courseids:json["course_ids"],
        // courseids: json["course_ids"] == null
        //     ? []
        //     : List<int>.from(json["course_ids"]!.map((x) => x)),

        // // locationids:json["location_ids"],
        // locationids: json["location_ids"] == null
        //     ? []
        //     : List<int>.from(json["location_ids"]!.map((x) => x)),

        // // studentIds:json["student_ids"],

        // fromDate: json["from_date"] == null
        //     ? null
        //     : DateTime.parse(json["from_date"]),
        // toDate:
        //     json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
        // studentIds: json["student_ids"] == null
        //     ? []
        //     : List<int>.from(json["student_ids"]!.map((x) => x)),
        // batchIds: json["batch_ids"] == null
        //     ? []
        //     : List<int>.from(json["batch_ids"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "selected_help_type": selected_help_type,
        "description": description,
        "attachment":attachment,
        
       
        
      };
}
