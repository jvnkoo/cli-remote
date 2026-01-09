import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:5050/api";

  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/system'));
      if (response.statusCode == 200) {
        print("Server Response: ${response.body}");
        return jsonDecode(response.body);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      return {"status": "Offline", "error": e.toString()};
    }
  }
}
