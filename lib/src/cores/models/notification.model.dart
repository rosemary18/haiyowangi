class NotificationModel {

  final int id;
  final String? title;
  final String? message;
  bool? isRead;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;

  NotificationModel({
    required this.id,
    this.title = "",
    this.message = "",
    this.isRead = false,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"],
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      isRead: json["is_read"] ?? false,
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "message": message,
      "is_read": isRead,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
  
}