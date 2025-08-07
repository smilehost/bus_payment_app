import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/card_use_response.dart';
import '../models/card_group.dart';

class CardService {
  static final String baseUrl = dotenv.env['API_URL'] ?? '';

  // static Future<CardUseResponse> useCard(
  //   String hash,
  //   currentPrice,
  //   scanboxBusId,
  //   scanboxBusroundLatest,
  //   String lat,
  //   String long,
  // ) async {
  //   final url = Uri.parse('$baseUrl/card/use');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(
  //       {
  //         "hashed_input": hash,
  //         "used_amount": currentPrice,
  //         "bus_id": scanboxBusId,
  //         "busround_id": scanboxBusroundLatest,
  //         "card_transaction_lat": lat,
  //         "card_transaction_long": long,
  //       },
  //     ), //หลังบ้านจะเช็ค ถ้าบัตรเป็นแบบเงิน จะลดยอดตามเงิน ถ้าเป็นรอบ จะลดทีละ 1
  //   );

  //   final json = jsonDecode(response.body);
  //   return CardUseResponse.fromJson(json);
  // }
  static Future<CardUseResponse> useCard(
    String hash,
    currentPrice,
    scanboxBusId,
    scanboxBusroundLatest,
    String lat,
    String long,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/card/use');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "hashed_input": hash,
          "used_amount": currentPrice,
          "bus_id": scanboxBusId,
          "busround_id": scanboxBusroundLatest,
          "card_transaction_lat": lat,
          "card_transaction_long": long,
        }),
      );

      final json = jsonDecode(response.body);
      return CardUseResponse.fromJson(json);
    } catch (e) {
      print("❌ useCard error: $e");
      return CardUseResponse(
        status: 'error',
        message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
        remainingBalance: null,
        cardType: null,
        expireDate: null,
      );
    }
  }

  static Future<dynamic> activateCard(
    String hash,
    scanboxBusroundLatest,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/card/activate');
      final body = {"hashed_input": hash, "busround_id": scanboxBusroundLatest};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] != null) {
          return {
            "status": "success",
            "message": json['message'],
            "data": CardGroup.fromJson(json['data']),
          };
        } else {
          return {
            "status": "error",
            "message": json['message'] ?? 'ไม่สามารถซื้อบัตรได้',
          };
        }
      } else {
        final errorJson = jsonDecode(response.body);
        return {
          "status": "error",
          "message": errorJson['message'] ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์',
        };
      }
    } catch (e) {
      // 💥 แก้จุดนี้! เพื่อให้กรณีเช่น DNS fail, timeout, ฯลฯ ไม่พัง
      print("❌ activateCard error: $e");
      return {
        "status": "error",
        "message": "ไม่สามารถเชื่อมต่อระบบได้", // Fallback
      };
    }
  }
}
