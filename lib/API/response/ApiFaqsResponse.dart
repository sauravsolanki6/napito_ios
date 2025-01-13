// To parse this JSON data, do
//
//     final apiFaqsResponse = apiFaqsResponseFromJson(jsonString);

import 'dart:convert';

List<ApiFaqsResponse> apiFaqsResponseFromJson(String str) => List<ApiFaqsResponse>.from(json.decode(str).map((x) => ApiFaqsResponse.fromJson(x)));

String apiFaqsResponseToJson(List<ApiFaqsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ApiFaqsResponse {
    String? status;
    String? message;
    List<ApiFaqsResponseDatum>? data;

    ApiFaqsResponse({
        this.status,
        this.message,
        this.data,
    });

    factory ApiFaqsResponse.fromJson(Map<String, dynamic> json) => ApiFaqsResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<ApiFaqsResponseDatum>.from(json["data"]!.map((x) => ApiFaqsResponseDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class ApiFaqsResponseDatum {
    String? categoryId;
    String? categoryName;
    List<CategoryQuestion>? categoryQuestions;

    ApiFaqsResponseDatum({
        this.categoryId,
        this.categoryName,
        this.categoryQuestions,
    });

    factory ApiFaqsResponseDatum.fromJson(Map<String, dynamic> json) => ApiFaqsResponseDatum(
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        categoryQuestions: json["category_questions"] == null ? [] : List<CategoryQuestion>.from(json["category_questions"]!.map((x) => CategoryQuestion.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "category_name": categoryName,
        "category_questions": categoryQuestions == null ? [] : List<dynamic>.from(categoryQuestions!.map((x) => x.toJson())),
    };
}

class CategoryQuestion {
    String? faqId;
    String? question;
    String? answer;

    CategoryQuestion({
        this.faqId,
        this.question,
        this.answer,
    });

    factory CategoryQuestion.fromJson(Map<String, dynamic> json) => CategoryQuestion(
        faqId: json["faq_id"],
        question: json["question"],
        answer: json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "faq_id": faqId,
        "question": question,
        "answer": answer,
    };
}
