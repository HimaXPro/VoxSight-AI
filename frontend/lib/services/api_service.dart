import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import '../utils/token_storage.dart';

class ApiService {
  static Future<Map<String, dynamic>> _parseJson(http.Response res) async {
    final body = res.body.trim();
    if (body.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'raw': decoded};
  }

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    bool auth = false,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    final request = http.Request('GET', uri);

    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    final json = await _parseJson(response);
    return json;
  }

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    final json = await _parseJson(response);
    return json;
  }

  static Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    final json = await _parseJson(response);
    return json;
  }
}
