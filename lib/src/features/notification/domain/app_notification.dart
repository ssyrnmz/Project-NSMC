class AppNotification {
  final int id;
  final String userId;
  final String type;      // e.g. 'medical_record'
  final String title;
  final String message;
  final bool isRead;
  final bool isDismissed;
  final int? referenceId; // e.g. record_id
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.isDismissed,
    required this.createdAt,
    this.referenceId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: int.parse(json['notif_id'].toString()),
      userId: json['user_id'] as String,
      type: json['notif_type'] as String,
      title: json['notif_title'] as String,
      message: json['notif_message'] as String,
      isRead: int.parse(json['notif_read'].toString()) == 1,
      isDismissed: int.parse(json['notif_dismissed'].toString()) == 1,
      referenceId: json['reference_id'] != null
          ? int.tryParse(json['reference_id'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
