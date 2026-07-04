import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String issueId;
  final String title;
  final String description;
  final String category;
  final String severity;
  final String status;
  final double lat;
  final double lng;
  final String wardId;
  final String wardName;
  final String zone;
  final String district;
  final String state;
  final String photoUrl;
  final String postedBy;
  final bool anonymous;
  final int supportCount;
  final int daysActive;
  final String assignedTo;
  final String assignedRole;
  final DateTime? resolutionDeadline;
  final String contentHash;
  final String? duplicateOf;
  final int extensionCount;
  final List<dynamic> extensionHistory;
  final String? proofPhotoUrl;
  final DateTime? resolvedAt;
  final bool verified;
  final double verificationScore;
  final List<dynamic> timeline;
  final DateTime? createdAt;

  Issue({
    required this.issueId,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.lat,
    required this.lng,
    required this.wardId,
    required this.wardName,
    required this.zone,
    required this.district,
    required this.state,
    required this.photoUrl,
    required this.postedBy,
    required this.anonymous,
    required this.supportCount,
    required this.daysActive,
    required this.assignedTo,
    required this.assignedRole,
    this.resolutionDeadline,
    required this.contentHash,
    this.duplicateOf,
    required this.extensionCount,
    required this.extensionHistory,
    this.proofPhotoUrl,
    this.resolvedAt,
    required this.verified,
    required this.verificationScore,
    required this.timeline,
    this.createdAt,
  });

  factory Issue.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Issue(
      issueId: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      severity: map['severity'] ?? 'Low',
      status: map['status'] ?? 'Posted',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      wardId: map['ward_id'] ?? '',
      wardName: map['ward_name'] ?? '',
      zone: map['zone'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      photoUrl: map['photo_url'] ?? '',
      postedBy: map['posted_by'] ?? '',
      anonymous: map['anonymous'] ?? false,
      supportCount: map['support_count'] ?? 0,
      daysActive: map['days_active'] ?? 0,
      assignedTo: map['assigned_to'] ?? '',
      assignedRole: map['assigned_role'] ?? '',
      resolutionDeadline: map['resolution_deadline'] == null
          ? null
          : (map['resolution_deadline'] is Timestamp
              ? (map['resolution_deadline'] as Timestamp).toDate()
              : DateTime.tryParse(map['resolution_deadline'].toString())),
      contentHash: map['content_hash'] ?? '',
      duplicateOf: map['duplicate_of'],
      extensionCount: map['extension_count'] ?? 0,
      extensionHistory: List<dynamic>.from(map['extension_history'] ?? []),
      proofPhotoUrl: map['proof_photo_url'],
      resolvedAt: map['resolved_at'] == null
          ? null
          : (map['resolved_at'] is Timestamp
              ? (map['resolved_at'] as Timestamp).toDate()
              : DateTime.tryParse(map['resolved_at'].toString())),
      verified: map['verified'] ?? false,
      verificationScore: (map['verification_score'] as num?)?.toDouble() ?? 0.0,
      timeline: List<dynamic>.from(map['timeline'] ?? []),
      createdAt: map['created_at'] == null
          ? null
          : (map['created_at'] is Timestamp
              ? (map['created_at'] as Timestamp).toDate()
              : DateTime.tryParse(map['created_at'].toString())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'status': status,
      'lat': lat,
      'lng': lng,
      'ward_id': wardId,
      'ward_name': wardName,
      'zone': zone,
      'district': district,
      'state': state,
      'photo_url': photoUrl,
      'posted_by': postedBy,
      'anonymous': anonymous,
      'support_count': supportCount,
      'days_active': daysActive,
      'assigned_to': assignedTo,
      'assigned_role': assignedRole,
      'resolution_deadline': resolutionDeadline != null ? Timestamp.fromDate(resolutionDeadline!) : null,
      'content_hash': contentHash,
      'duplicate_of': duplicateOf,
      'extension_count': extensionCount,
      'extension_history': extensionHistory,
      'proof_photo_url': proofPhotoUrl,
      'resolved_at': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'verified': verified,
      'verification_score': verificationScore,
      'timeline': timeline,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
