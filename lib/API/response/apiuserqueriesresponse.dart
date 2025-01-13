import 'dart:convert';

List<Userqueriesresponse> userqueriesresponseFromJson(String str) =>
    List<Userqueriesresponse>.from(json.decode(str).map((x) => Userqueriesresponse.fromJson(x)));

String userqueriesresponseToJson(List<Userqueriesresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Userqueriesresponse {
  String? status;
  String? message;
  List<UserQuery>? data;

  Userqueriesresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Userqueriesresponse.fromJson(Map<String, dynamic> json) => Userqueriesresponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : List<UserQuery>.from(json["data"].map((x) => UserQuery.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class UserQuery {
  String? id;
  String? supportId;
  String? fullName;
  String? email;
  String? mobile;
  String? helpTypeId;
  String? description;
  String? finalResolutionStatus;
  String? attachments;
  String? finalRemark;
  String? finalRemarkDate;
  String? helpType;
  String? attachmentLink;
  String? ticketdatetime;
String? finalresolutionstatustext;
  UserQuery({
    this.id,
    this.supportId,
    this.fullName,
    this.email,
    this.mobile,
    this.helpTypeId,
    this.description,
    this.finalResolutionStatus,
    this.attachments,
    this.finalRemark,
    this.finalRemarkDate,
    this.helpType,
    this.attachmentLink,
    this.ticketdatetime,
    this.finalresolutionstatustext
  });

  factory UserQuery.fromJson(Map<String, dynamic> json) => UserQuery(
    id: json["id"],
    supportId: json["support_id"],
    fullName: json["full_name"],
    email: json["email"],
    mobile: json["mobile"],
    helpTypeId: json["help_type_id"],
    description: json["description"],
    finalResolutionStatus: json["final_resolution_status"],
    attachments: json["attachments"],
    finalRemark: json["final_remark"],
    finalRemarkDate: json["final_remark_date"],
    helpType: json["help_type"],
    attachmentLink: json["attachment_link"],
    ticketdatetime: json["ticket_datetime"],
    finalresolutionstatustext: json["final_resolution_status_text"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "support_id": supportId,
    "full_name": fullName,
    "email": email,
    "mobile": mobile,
    "help_type_id": helpTypeId,
    "description": description,
    "final_resolution_status": finalResolutionStatus,
    "attachments": attachments,
    "final_remark": finalRemark,
    "final_remark_date": finalRemarkDate,
    "help_type": helpType,
    "attachment_link": attachmentLink,
    "ticket_datetime":ticketdatetime,
    "final_resolution_status_text":finalresolutionstatustext,
  };
}
