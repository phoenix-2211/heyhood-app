import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String alertId;
  final String userId;
  final String wardId;
  final String type;
  final String title;
  final String description;
  final String issueId;
  final bool read;
  final String tag;
  final DateTime? createdAt;

  Alert({
    required this.alertId,
    required this.userId,
    required this.wardId,
    required this.type,
    required this.title,
    required this.description,
    required this.issueId,
    required this.read,
    required this.tag,
    this.createdAt,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Alert(
      alertId: doc.id,
      userId: map['user_id'] ?? '',
      wardId: map['ward_id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      issueId: map['issue_id'] ?? '',
      read: map['read'] ?? false,
      tag: map['tag'] ?? '',
      createdAt: map['created_at'] == null
          ? null
          : (map['created_at'] is Timestamp
              ? (map['created_at'] as Timestamp).toDate()
              : DateTime.tryParse(map['created_at'].toString())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'ward_id': wardId,
      'type': type,
      'title': title,
      'description': description,
      'issue_id': issueId,
      'read': read,
      'tag': tag,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
