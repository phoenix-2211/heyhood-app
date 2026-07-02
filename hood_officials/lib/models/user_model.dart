import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String displayName;
  final String phoneNumber;
  final String aadhaarToken;
  final String homeWardId;
  final String homeAreaName;
  final String homeDistrict;
  final String homeState;
  final bool verified;
  final int civicScore;
  final int postsCount;
  final int supportedCount;
  final int wishesCount;
  final String language;
  final DateTime? createdAt;
  final String accountStatus;

  UserProfile({
    required this.userId,
    required this.displayName,
    required this.phoneNumber,
    required this.aadhaarToken,
    required this.homeWardId,
    required this.homeAreaName,
    required this.homeDistrict,
    required this.homeState,
    required this.verified,
    required this.civicScore,
    required this.postsCount,
    required this.supportedCount,
    required this.wishesCount,
    required this.language,
    this.createdAt,
    required this.accountStatus,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      userId: doc.id,
      displayName: map['display_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      aadhaarToken: map['aadhaar_token'] ?? '',
      homeWardId: map['home_ward_id'] ?? '',
      homeAreaName: map['home_area_name'] ?? '',
      homeDistrict: map['home_district'] ?? '',
      homeState: map['home_state'] ?? '',
      verified: map['verified'] ?? false,
      civicScore: map['civic_score'] ?? 750,
      postsCount: map['posts_count'] ?? 0,
      supportedCount: map['supported_count'] ?? 0,
      wishesCount: map['wishes_count'] ?? 0,
      language: map['language'] ?? 'ta',
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
      accountStatus: map['account_status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'phone_number': phoneNumber,
      'aadhaar_token': aadhaarToken,
      'home_ward_id': homeWardId,
      'home_area_name': homeAreaName,
      'home_district': homeDistrict,
      'home_state': homeState,
      'verified': verified,
      'civic_score': civicScore,
      'posts_count': postsCount,
      'supported_count': supportedCount,
      'wishes_count': wishesCount,
      'language': language,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'account_status': accountStatus,
    };
  }
}
