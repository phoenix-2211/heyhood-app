import 'package:cloud_firestore/cloud_firestore.dart';

class Official {
  final String officialId;
  final String name;
  final String designation;
  final String? employeeId;
  final String phone;
  final String mobile;
  final String email;
  final String? wardId;
  final String district;
  final String state;
  final String level;
  final String? profilePhotoUrl;
  final int accountabilityScore;
  final int issuesAssigned;
  final int issuesResolved;
  final int issuesOverdue;
  final bool verified;
  final DateTime? createdAt;

  Official({
    required this.officialId,
    required this.name,
    required this.designation,
    this.employeeId,
    required this.phone,
    required this.mobile,
    required this.email,
    this.wardId,
    required this.district,
    required this.state,
    required this.level,
    this.profilePhotoUrl,
    required this.accountabilityScore,
    required this.issuesAssigned,
    required this.issuesResolved,
    required this.issuesOverdue,
    required this.verified,
    this.createdAt,
  });

  factory Official.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Official(
      officialId: doc.id,
      name: map['name'] ?? '',
      designation: map['designation'] ?? '',
      employeeId: map['employee_id'],
      phone: map['phone'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      wardId: map['ward_id'],
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      level: map['level'] ?? 'district',
      profilePhotoUrl: map['profile_photo_url'],
      accountabilityScore: map['accountability_score'] ?? 100,
      issuesAssigned: map['issues_assigned'] ?? 0,
      issuesResolved: map['issues_resolved'] ?? 0,
      issuesOverdue: map['issues_overdue'] ?? 0,
      verified: map['verified'] ?? false,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'official_id': officialId,
      'name': name,
      'designation': designation,
      'employee_id': employeeId,
      'phone': phone,
      'mobile': mobile,
      'email': email,
      'ward_id': wardId,
      'district': district,
      'state': state,
      'level': level,
      'profile_photo_url': profilePhotoUrl,
      'accountability_score': accountabilityScore,
      'issues_assigned': issuesAssigned,
      'issues_resolved': issuesResolved,
      'issues_overdue': issuesOverdue,
      'verified': verified,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
