import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/card_use_response.dart';

class CardService {
  static final String baseUrl = dotenv.env['API_URL'] ?? '';

  static Future<CardUseResponse> useCard(
    String hash,
    currentPrice,
    scanboxBusId,
    scanboxBusroundLatest,
  ) async {
    final url = Uri.parse('$baseUrl/card/use');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          "hashed_input": hash,
          "used_amount": currentPrice,
          "bus_id": scanboxBusId,
          "busround_id": scanboxBusroundLatest,
        },
      ), //หลังบ้านจะเช็ค ถ้าบัตรเป็นแบบเงิน จะลดยอดตามเงิน ถ้าเป็นรอบ จะลดทีละ 1
    );

    final json = jsonDecode(response.body);
    return CardUseResponse.fromJson(json);
  }
}
