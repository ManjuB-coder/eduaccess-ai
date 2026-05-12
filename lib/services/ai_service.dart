import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = "http://localhost:5000";

  static Future<String> simplifyText(String text) async {
    final response = await http.post(
      Uri.parse("$baseUrl/simplify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["result"];
    } else {
      return "Error simplifying text";
    }
  }

  static Future<String> translateText(String text, String language) async {
    final response = await http.post(
      Uri.parse("$baseUrl/translate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text, "language": language}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["result"];
    } else {
      return "Error translating text";
    }
  }
}
