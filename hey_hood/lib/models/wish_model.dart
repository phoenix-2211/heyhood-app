import 'package:cloud_firestore/cloud_firestore.dart';

class Wish {
  final String wishId;
  final String title;
  final String description;
  final String imageUrl;
  final String imageType;
  final String category;
  final String wardId;
  final String wardName;
  final String district;
  final String state;
  final int supportCount;
  final String postedBy;
  final String status;
  final String? clusterId;
  final bool isTrending;
  final DateTime? createdAt;

  Wish({
    required this.wishId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageType,
    required this.category,
    required this.wardId,
    required this.wardName,
    required this.district,
    required this.state,
    required this.supportCount,
    required this.postedBy,
    required this.status,
    this.clusterId,
    required this.isTrending,
    this.createdAt,
  });

  factory Wish.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Wish(
      wishId: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
      imageType: map['image_type'] ?? 'ai_generated',
      category: map['category'] ?? 'Facility',
      wardId: map['ward_id'] ?? '',
      wardName: map['ward_name'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      supportCount: map['support_count'] ?? 0,
      postedBy: map['posted_by'] ?? '',
      status: map['status'] ?? 'Active',
      clusterId: map['cluster_id'],
      isTrending: map['is_trending'] ?? false,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'image_type': imageType,
      'category': category,
      'ward_id': wardId,
      'ward_name': wardName,
      'district': district,
      'state': state,
      'support_count': supportCount,
      'posted_by': postedBy,
      'status': status,
      'cluster_id': clusterId,
      'is_trending': isTrending,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
