class OrderModel {
  final bool success;
  final DataOrder? data;
  final String? message;

  OrderModel({
    required this.success,
    this.data,
    this.message,
  });

  /// Getter 
  bool get isSuccessful => success || (data?.id != null);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    final normalizedSuccess = rawSuccess == true ||
        rawSuccess == 1 ||
        rawSuccess == '1' ||
        (rawSuccess is String && rawSuccess.toLowerCase() == 'true');

    return OrderModel(
      success: normalizedSuccess,
      data: json['data'] == null
          ? null
          : (json['data'] is List
              ? (json['data'] as List).isNotEmpty
                  ? DataOrder.fromJson((json['data'] as List).first)
                  : null
              : DataOrder.fromJson(json['data'] as Map<String, dynamic>)),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data?.toJson(),
        'message': message,
      };
}

class DataOrder {
  final int? id;
  final int? userId;
  final int? eventId;
  final String? name;
  final String? location;
  final String? code;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? quantity;
  final int? price;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Event? event;
  final List<Tiket> tikets;

  DataOrder({
    this.id,
    this.userId,
    this.eventId,
    this.name,
    this.location,
    this.code,
    this.startDate,
    this.endDate,
    this.quantity,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.event,
    List<Tiket>? tikets,
  }) : tikets = tikets ?? [];

  factory DataOrder.fromJson(Map<String, dynamic> json) {
    final rawTikets = json['tiket'] ?? json['tikets'];
    return DataOrder(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      eventId: json['event_id'] as int?,
      name: json['name'] as String?,
      location: json['location'] as String?,
      code: json['code'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date']),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date']),
      quantity: json['quantity'] as int?,
      price: json['price'] as int?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at']),
      event: json['event'] == null
          ? null
          : Event.fromJson(json['event']),
      tikets: rawTikets == null
          ? []
          : List<Tiket>.from(
              (rawTikets as List).map((x) => Tiket.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'event_id': eventId,
        'name': name,
        'location': location,
        'code': code,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'quantity': quantity,
        'price': price,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'event': event?.toJson(),
        'tiket': tikets.map((x) => x.toJson()).toList(),
      };
}

class Event {
  int? id;
  String? image;
  String? name;
  DateTime? startDate;
  DateTime? endDate;
  String? location;
  String? description;
  int? price; // opsional, kalau mau dipakai
  DateTime? createdAt;
  DateTime? updatedAt;

  Event({
    this.id,
    this.image,
    this.name,
    this.startDate,
    this.endDate,
    this.location,
    this.description,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json["id"] as int?,
    image: json["image"] as String?,
    name: json["name"] as String?,
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    location: json["location"] as String?,
    description: json["description"] as String?,
    price: json["price"] as int?, // aman kalau nggak ada
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
    "price": price,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Tiket {
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

  Tiket({
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

  factory Tiket.fromJson(Map<String, dynamic> json) => Tiket(
    id: json["id"] as int?,
    userId: json["user_id"] as int?,
    orderId: json["order_id"] as int?,
    eventId: json["event_id"] as int?,
    name: json["name"] as String?,
    location: json["location"] as String?,
    code: json["code"] as String?,
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