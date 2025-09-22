import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/scanbox_response.dart';

class ScanboxService {
  static final String baseUrl = dotenv.env['API_URL'] ?? '';

  static Future<Scanbox?> getScanboxBySerial(String serial) async {
    final url = Uri.parse('$baseUrl/scanbox/serial');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"scanbox_serial": serial}),
      // body: jsonEncode({"scanbox_serial": "bus_pcb_002"}),
    );
    print("url=>: $url");
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return Scanbox.fromJson(data['data']);
    } else {
      print("❌ Error: ${data['message']}");
      return null;
    }
  }
}
