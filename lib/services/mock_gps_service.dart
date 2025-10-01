// lib/services/mock_gps_service.dart
import 'dart:async';

/// รูปแบบข้อมูลตำแหน่งที่แทนของเดิม (Geolocator.Position)
class Position {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const Position({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Mock API แบบ in-memory: คืนทีละชุด (วนลูป) เหมือนยิง REST แล้วได้ JSON กลับมา
class MockGpsApi {
  static int _idx = 0;

  /// ชุด mock 10 ตัวอย่าง (โซนขอนแก่น) timestamp เป็น UTC (ลงท้าย Z)
  static List<Map<String, dynamic>> _data = [
    {
      "latitude": 16.439812,
      "longitude": 102.834901,
      "timestamp": "2025-09-30T07:20:31.123Z",
    },
    {
      "latitude": 16.442150,
      "longitude": 102.835420,
      "timestamp": "2025-09-30T07:20:41.123Z",
    },
    {
      "latitude": 16.444320,
      "longitude": 102.836950,
      "timestamp": "2025-09-30T07:20:51.123Z",
    },
    {
      "latitude": 16.446780,
      "longitude": 102.838100,
      "timestamp": "2025-09-30T07:21:01.123Z",
    },
    {
      "latitude": 16.448900,
      "longitude": 102.839500,
      "timestamp": "2025-09-30T07:21:11.123Z",
    },
    {
      "latitude": 16.451220,
      "longitude": 102.840880,
      "timestamp": "2025-09-30T07:21:21.123Z",
    },
    {
      "latitude": 16.453540,
      "longitude": 102.842260,
      "timestamp": "2025-09-30T07:21:31.123Z",
    },
    {
      "latitude": 16.455860,
      "longitude": 102.843640,
      "timestamp": "2025-09-30T07:21:41.123Z",
    },
    {
      "latitude": 16.458180,
      "longitude": 102.845020,
      "timestamp": "2025-09-30T07:21:51.123Z",
    },
    {
      "latitude": 16.460500,
      "longitude": 102.846400,
      "timestamp": "2025-09-30T07:22:01.123Z",
    },
  ];

  /// ตั้งค่า mock data เองได้ถ้าต้องการ (เช่นจากไฟล์ทดสอบ)
  static void setMockData(List<Map<String, dynamic>> data) {
    _data = data;
    _idx = 0;
  }

  /// จำลองเรียก API: หน่วงเวลานิดหน่อยให้เหมือน network แล้วคืน JSON
  static Future<Map<String, dynamic>> fetchPositionJson() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final json = _data[_idx % _data.length];
    _idx++;
    return json;
  }
}

/// ฟังก์ชัน public ที่ใช้แทน Geolocator เวอร์ชันเดิม
Future<Position> getPositionWithFallback() async {
  // ถ้าต้องทำ fallback อื่น ๆ (เช่น cache) ใส่ใน try/catch ได้
  final json = await MockGpsApi.fetchPositionJson();
  return Position.fromJson(json);
}
