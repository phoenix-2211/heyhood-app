import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String currentOfficialId = 'TN-MLA-100'; // Default to Adyar MLA
  static String currentOfficialName = 'Suresh Patel';
  static String currentOfficialRole = 'MLA';
  static String currentWardId = 'TN-CHN-170'; // Adyar
  static String currentWardName = 'Adyar';
  static String currentUserId = 'USR-ADYAR-01';

  // --- WARD METHODS ---

  // Fetch a single Ward by ID
  Future<Ward?> getWard(String wardId) async {
    try {
      var doc = await _db.collection('wards').doc(wardId).get();
      if (doc.exists && doc.data() != null) {
        return Ward.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching ward $wardId: $e');
    }
    return null;
  }

  // Fetch all Wards
  Future<List<Ward>> getAllWards() async {
    try {
      var snap = await _db.collection('wards').get();
      return snap.docs.map((doc) => Ward.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all wards: $e');
    }
    return [];
  }

  // --- ISSUES METHODS ---

  // Stream issues for a specific ward
  Stream<List<Issue>> getIssuesByWard(String wardId) {
    return _db.collection('issues')
        .where('ward_id', isEqualTo: wardId)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) => Issue.fromFirestore(doc)).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        });
  }

  // Create/Post a new Issue
  Future<Issue?> createIssue(Map<String, dynamic> issueData) async {
    try {
      String wardId = issueData['ward_id'] ?? 'unknown';
      String issueId = issueData['issue_id'] ?? 'HH-$wardId-${DateTime.now().year}-${Random().nextInt(90000) + 10000}';
      
      // Inject standard fields
      issueData['created_at'] = FieldValue.serverTimestamp();
      issueData['support_count'] = issueData['support_count'] ?? 1;
      issueData['status'] = issueData['status'] ?? 'Posted';
      issueData['timeline'] = [
        {
          'status': 'Posted',
          'timestamp': DateTime.now().toIso8601String(),
          'notes': 'Issue reported by citizen.'
        }
      ];

      await _db.collection('issues').doc(issueId).set(issueData);
      
      // Fetch the created document and return as typed Issue object
      var doc = await _db.collection('issues').doc(issueId).get();
      return Issue.fromFirestore(doc);
    } catch (e) {
      print('Error creating issue: $e');
    }
    return null;
  }

  // Support an Issue
  Future<void> supportIssue(String issueId, String userId) async {
    try {
      await _db.collection('issues').doc(issueId).update({
        'support_count': FieldValue.increment(1)
      });
      await _db.collection('users').doc(userId).update({
        'supported_count': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error supporting issue $issueId: $e');
    }
  }

  // --- WISHES METHODS ---

  // Stream wishes for a specific ward
  Stream<List<Wish>> getWishesByWard(String wardId) {
    return _db.collection('wishes')
        .where('ward_id', isEqualTo: wardId)
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) => Wish.fromFirestore(doc)).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        });
  }

  // Create/Post a new Wish
  Future<Wish?> createWish(Map<String, dynamic> wishData) async {
    try {
      String wardId = wishData['ward_id'] ?? 'unknown';
      String wishId = 'WH-$wardId-${DateTime.now().year}-${Random().nextInt(90000) + 10000}';

      wishData['created_at'] = FieldValue.serverTimestamp();
      wishData['support_count'] = wishData['support_count'] ?? 1;
      wishData['status'] = wishData['status'] ?? 'Active';
      wishData['is_trending'] = wishData['is_trending'] ?? false;

      await _db.collection('wishes').doc(wishId).set(wishData);
      
      var doc = await _db.collection('wishes').doc(wishId).get();
      return Wish.fromFirestore(doc);
    } catch (e) {
      print('Error creating wish: $e');
    }
    return null;
  }

  // Support a Wish
  Future<void> supportWish(String wishId, String userId) async {
    try {
      await _db.collection('wishes').doc(wishId).update({
        'support_count': FieldValue.increment(1)
      });
      await _db.collection('users').doc(userId).update({
        'supported_count': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error supporting wish $wishId: $e');
    }
  }

  // --- OFFICIALS METHODS ---

  // Fetch Officials for a specific ward
  Future<List<Official>> getOfficialsByWard(String wardId) async {
    try {
      var snap = await _db.collection('officials')
          .where('ward_id', isEqualTo: wardId)
          .get();
      return snap.docs.map((doc) => Official.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting officials for ward $wardId: $e');
    }
    return [];
  }

  // --- NOTICES METHODS ---

  // Stream notices in current ward
  Stream<List<Notice>> getNotices(String wardId) {
    return _db.collection('notices')
        .where('ward_id', isEqualTo: wardId)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) => Notice.fromFirestore(doc)).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        });
  }

  // --- ALERTS METHODS ---

  // Stream alerts for a specific user
  Stream<List<Alert>> getAlerts(String userId) {
    return _db.collection('alerts')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) => Alert.fromFirestore(doc)).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        });
  }

  // --- EMERGENCY SERVICES METHODS ---

  // Stream emergency services in current ward
  Stream<List<EmergencyService>> getEmergencyServices(String wardId) {
    return _db.collection('emergency_services')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => EmergencyService.fromFirestore(doc))
              .where((service) => service.wardIds.contains(wardId))
              .toList();
        });
  }


  // Fetch a single Official by ID
  Future<Official?> getOfficial(String officialId) async {
    try {
      var doc = await _db.collection('officials').doc(officialId).get();
      if (doc.exists && doc.data() != null) {
        return Official.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching official $officialId: $e');
    }
    return null;
  }

  // Fetch a single Issue by ID
  Future<Issue?> getIssue(String issueId) async {
    try {
      var doc = await _db.collection('issues').doc(issueId).get();
      if (doc.exists && doc.data() != null) {
        return Issue.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching issue $issueId: $e');
    }
    return null;
  }

  // Resolve an Issue
  Future<void> resolveIssue(String issueId, String notes, {String? proofPhotoUrl}) async {
    try {
      // 1. Get the issue details to find the assigned official and supporters
      var issueDoc = await _db.collection('issues').doc(issueId).get();
      if (!issueDoc.exists) return;
      var issueData = issueDoc.data() ?? {};
      String? officialId = issueData['assigned_to'];
      String title = issueData['title'] ?? 'Issue';
      List<dynamic> supporters = issueData['supporters'] ?? [];

      // 2. Resolve the issue document
      await _db.collection('issues').doc(issueId).update({
        'status': 'Resolved',
        'resolved_at': FieldValue.serverTimestamp(),
        'resolution_notes': notes,
        if (proofPhotoUrl != null) 'proof_photo_url': proofPhotoUrl,
        'timeline': FieldValue.arrayUnion([
          {
            'status': 'Resolved',
            'timestamp': DateTime.now().toIso8601String(),
            'notes': 'Resolved: ' + notes,
            if (proofPhotoUrl != null) 'proof_photo_url': proofPhotoUrl,
          }
        ])
      });

      // 3. Increment official statistics
      if (officialId != null && officialId.isNotEmpty) {
        await _db.collection('officials').doc(officialId).update({
          'issues_resolved': FieldValue.increment(1),
          'accountability_score': FieldValue.increment(3),
        });

        // 4. Create alert documents for each supporter
        for (var userId in supporters) {
          if (userId is String) {
            await _db.collection('alerts').add({
              'user_id': userId,
              'type': 'Issue Resolved',
              'title': 'Issue Resolved ✓',
              'description': 'The issue "$title" you supported has been resolved.',
              'issue_id': issueId,
              'read': false,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (e) {
      print('Error resolving issue $issueId: $e');
    }
  }

  // Assign an Issue
  Future<void> assignIssue(String issueId, String officialId) async {
    try {
      await _db.collection('issues').doc(issueId).update({
        'status': 'In Progress',
        'assigned_to': officialId,
        'timeline': FieldValue.arrayUnion([
          {
            'status': 'In Progress',
            'timestamp': DateTime.now().toIso8601String(),
            'notes': 'Issue assigned to official.'
          }
        ])
      });
    } catch (e) {
      print('Error assigning issue $issueId: $e');
    }
  }

  // Create a Notice (Report to Hood)
  Future<void> createNotice(Map<String, dynamic> noticeData) async {
    try {
      String wardId = noticeData['ward_id'] ?? 'unknown';
      String noticeId = 'NT-' + wardId + '-' + DateTime.now().millisecondsSinceEpoch.toString();
      noticeData['created_at'] = FieldValue.serverTimestamp();
      await _db.collection('notices').doc(noticeId).set(noticeData);
    } catch (e) {
      print('Error creating notice: $e');
    }
  }
}
