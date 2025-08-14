// To parse this JSON data, do
//
//     final tiketModel = tiketModelFromJson(jsonString);

import 'dart:convert';

TiketModel tiketModelFromJson(String str) => TiketModel.fromJson(json.decode(str));

String tiketModelToJson(TiketModel data) => json.encode(data.toJson());

class TiketModel {
    bool? success;
    List<DataTiket>? data;
    String? message;

    TiketModel({
        this.success,
        this.data,
        this.message,
    });

    factory TiketModel.fromJson(Map<String, dynamic> json) => TiketModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataTiket>.from(json["data"]!.map((x) => DataTiket.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataTiket {
    int? id;
    int? userId;
    int? orderId;
    int? eventId;
    String? name;
    String? location;
    String? code;
    DateTime? startDate;
    DateTime? endDate;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataTiket({
        this.id,
        this.userId,
        this.orderId,
        this.eventId,
        this.name,
        this.location,
        this.code,
        this.startDate,
        this.endDate,
        this.createdAt,
        this.updatedAt,
    });

    factory DataTiket.fromJson(Map<String, dynamic> json) => DataTiket(
        id: json["id"],
        userId: json["user_id"],
        orderId: json["order_id"],
        eventId: json["event_id"],
        name: json["name"],
        location: json["location"],
        code: json["code"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "order_id": orderId,
        "event_id": eventId,
        "name": name,
        "location": location,
        "code": code,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
