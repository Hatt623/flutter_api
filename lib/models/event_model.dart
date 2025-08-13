// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);

import 'dart:convert';

EventModel eventModelFromJson(String str) => EventModel.fromJson(json.decode(str));

String eventModelToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
    bool? success;
    List<DataEvent>? data;
    String? message;

    EventModel({
        this.success,
        this.data,
        this.message,
    });

    factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataEvent>.from(json["data"]!.map((x) => DataEvent.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataEvent {
    int? id;
    String? image;
    String? name;
    DateTime? startDate;
    DateTime? endDate;
    String? location;
    String? description;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataEvent({
        this.id,
        this.image,
        this.name,
        this.startDate,
        this.endDate,
        this.location,
        this.description,
        this.createdAt,
        this.updatedAt,
    });

    factory DataEvent.fromJson(Map<String, dynamic> json) => DataEvent(
        id: json["id"],
        image: json["image"],
        name: json["name"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        location: json["location"],
        description: json["description"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "name": name,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "location": location,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
