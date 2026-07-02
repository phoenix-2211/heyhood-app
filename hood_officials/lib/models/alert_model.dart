import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String alertId;
  final String userId;
  final String type;
  final String title;
  final String description;
  final String issueId;
  final bool read;
  final DateTime? createdAt;

  Alert({
    required this.alertId,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.issueId,
    required this.read,
    this.createdAt,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Alert(
      alertId: doc.id,
      userId: map['user_id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      issueId: map['issue_id'] ?? '',
      read: map['read'] ?? false,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'issue_id': issueId,
      'read': read,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
