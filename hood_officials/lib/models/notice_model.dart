import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String noticeId;
  final String title;
  final String content;
  final String type;
  final String postedByOfficialId;
  final String wardId;
  final String circle;
  final bool verifiedOfficialPost;
  final bool cannotDelete;
  final DateTime? createdAt;

  Notice({
    required this.noticeId,
    required this.title,
    required this.content,
    required this.type,
    required this.postedByOfficialId,
    required this.wardId,
    required this.circle,
    required this.verifiedOfficialPost,
    required this.cannotDelete,
    this.createdAt,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Notice(
      noticeId: doc.id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'Notice',
      postedByOfficialId: map['posted_by_official_id'] ?? '',
      wardId: map['ward_id'] ?? '',
      circle: map['circle'] ?? 'Ward',
      verifiedOfficialPost: map['verified_official_post'] ?? true,
      cannotDelete: map['cannot_delete'] ?? true,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'posted_by_official_id': postedByOfficialId,
      'ward_id': wardId,
      'circle': circle,
      'verified_official_post': verifiedOfficialPost,
      'cannot_delete': cannotDelete,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
