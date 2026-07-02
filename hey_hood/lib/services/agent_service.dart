import 'dart:convert';
import 'package:http/http.dart' as http;

class AgentService {
  // Base URLs for Railway services (updated during deployment)
  static const String _duplicateUrl = 'https://hey-hood-duplicate-detection.up.railway.app';
  static const String _textPolishUrl = 'https://hey-hood-text-polish.up.railway.app';
  static const String _fakeNewsUrl = 'https://hey-hood-fake-news.up.railway.app';
  static const String _issueRoutingUrl = 'https://hey-hood-issue-routing.up.railway.app';
  static const String _wishMatchingUrl = 'https://hey-hood-wish-matching.up.railway.app';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Call duplicate detection agent
  static Future<Map<String, dynamic>> checkDuplicate({
    required String issueId,
    required String title,
    required String description,
    required String category,
    required String wardId,
    required String wardName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_duplicateUrl/run'),
        headers: _headers,
        body: jsonEncode({
          'issue_id': issueId,
          'title': title,
          'description': description,
          'category': category,
          'ward_id': wardId,
          'ward_name': wardName,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': 'error', 'action': 'publish'};
    } catch (e) {
      return {'status': 'fallback', 'action': 'publish'};
    }
  }

  // Call text polish agent
  static Future<String> polishText({
    required String rawText,
    required String context,
    String languageHint = 'auto',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_textPolishUrl/run'),
        headers: _headers,
        body: jsonEncode({
          'raw_text': rawText,
          'context': context,
          'language_hint': languageHint,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['polished_result'] != null && data['result']['polished_result']['polished_text'] != null) {
          return data['result']['polished_result']['polished_text'];
        }
      }
      return rawText;
    } catch (e) {
      return rawText;
    }
  }

  // Call fake news verification agent
  static Future<Map<String, dynamic>> verifyImage({
    required String issueId,
    required String photoUrl,
    required String description,
    required String wardId,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_fakeNewsUrl/run'),
        headers: _headers,
        body: jsonEncode({
          'issue_id': issueId,
          'photo_url': photoUrl,
          'description': description,
          'ward_id': wardId,
          'category': category,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': 'fallback', 'action': 'publish'};
    } catch (e) {
      return {'status': 'fallback', 'action': 'publish'};
    }
  }

  // Call issue routing agent
  static Future<Map<String, dynamic>> routeIssue({
    required String issueId,
    required String title,
    required String category,
    required String severity,
    required String wardId,
    required String wardName,
    required double lat,
    required double lng,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_issueRoutingUrl/run'),
        headers: _headers,
        body: jsonEncode({
          'issue_id': issueId,
          'title': title,
          'category': category,
          'severity': severity,
          'ward_id': wardId,
          'ward_name': wardName,
          'lat': lat,
          'lng': lng,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': 'error', 'action': 'route'};
    } catch (e) {
      return {'status': 'fallback', 'action': 'route'};
    }
  }

  // Call wish matching agent
  static Future<Map<String, dynamic>> matchWish({
    required String wishId,
    required String title,
    required String description,
    required String category,
    required String wardId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_wishMatchingUrl/run'),
        headers: _headers,
        body: jsonEncode({
          'wish_id': wishId,
          'title': title,
          'description': description,
          'category': category,
          'ward_id': wardId,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': 'error', 'action': 'match'};
    } catch (e) {
      return {'status': 'fallback', 'action': 'match'};
    }
  }
}
