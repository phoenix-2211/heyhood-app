import 'package:cloud_firestore/cloud_firestore.dart';

class Ward {
  final String wardId;
  final String wardName;
  final int wardNumber;
  final String zone;
  final int zoneNumber;
  final String district;
  final String state;
  final String boundaryGeoJson;
  final int pulseScore;
  final String councillorId;
  final String zoneOfficerId;
  final String mlaId;
  final String mpId;
  final String collectorId;
  final String policeStationId;
  final String fireStationId;
  final List<String> nearestHospitalIds;
  final DateTime? createdAt;

  Ward({
    required this.wardId,
    required this.wardName,
    required this.wardNumber,
    required this.zone,
    required this.zoneNumber,
    required this.district,
    required this.state,
    required this.boundaryGeoJson,
    required this.pulseScore,
    required this.councillorId,
    required this.zoneOfficerId,
    required this.mlaId,
    required this.mpId,
    required this.collectorId,
    required this.policeStationId,
    required this.fireStationId,
    required this.nearestHospitalIds,
    this.createdAt,
  });

  factory Ward.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Ward(
      wardId: map['ward_id'] ?? doc.id,
      wardName: map['ward_name'] ?? '',
      wardNumber: map['ward_number'] ?? 0,
      zone: map['zone'] ?? '',
      zoneNumber: map['zone_number'] ?? 0,
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      boundaryGeoJson: map['boundary_geojson'] ?? '',
      pulseScore: map['pulse_score'] ?? 70,
      councillorId: map['councillor_id'] ?? '',
      zoneOfficerId: map['zone_officer_id'] ?? '',
      mlaId: map['mla_id'] ?? '',
      mpId: map['mp_id'] ?? '',
      collectorId: map['collector_id'] ?? '',
      policeStationId: map['police_station_id'] ?? '',
      fireStationId: map['fire_station_id'] ?? '',
      nearestHospitalIds: List<String>.from(map['nearest_hospital_ids'] ?? []),
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ward_id': wardId,
      'ward_name': wardName,
      'ward_number': wardNumber,
      'zone': zone,
      'zone_number': zoneNumber,
      'district': district,
      'state': state,
      'boundary_geojson': boundaryGeoJson,
      'pulse_score': pulseScore,
      'councillor_id': councillorId,
      'zone_officer_id': zoneOfficerId,
      'mla_id': mlaId,
      'mp_id': mpId,
      'collector_id': collectorId,
      'police_station_id': policeStationId,
      'fire_station_id': fireStationId,
      'nearest_hospital_ids': nearestHospitalIds,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
