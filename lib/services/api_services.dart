import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // ✅ Apna IP yahan daalo
  // Local test ke liye: http://192.168.x.x:8080
  static const String baseUrl = 'http://192.168.x.x:8080';

  static Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/classify'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send().timeout(
        const Duration(seconds: 60), // rembg time leta hai
      );

      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['detail']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}