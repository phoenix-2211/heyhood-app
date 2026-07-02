import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String currentWardId = 'TN-CHN-170'; // Default to Adyar
  static String currentWardName = 'Adyar';
  static String currentUserId = 'USR-ADYAR-01'; // Default demo user

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

  // Create or set user document
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      String userId = userData['user_id'];
      await _db.collection('users').doc(userId).set(userData);
    } catch (e) {
      print('Error creating user: $e');
    }
  }
}
