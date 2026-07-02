import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyService {
  final String serviceId;
  final String name;
  final String type;
  final List<String> wardIds;
  final String district;
  final String phone;
  final double lat;
  final double lng;
  final bool open247;

  EmergencyService({
    required this.serviceId,
    required this.name,
    required this.type,
    required this.wardIds,
    required this.district,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.open247,
  });

  factory EmergencyService.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return EmergencyService(
      serviceId: map['service_id'] ?? doc.id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      wardIds: List<String>.from(map['ward_ids'] ?? []),
      district: map['district'] ?? '',
      phone: map['phone'] ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      open247: map['open_247'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'name': name,
      'type': type,
      'ward_ids': wardIds,
      'district': district,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'open_247': open247,
    };
  }
}
