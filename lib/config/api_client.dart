import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'env.dart';

class ApiClient {
  static String get baseUrl =>
      Env.serverURL.isNotEmpty
          ? Env.serverURL
          : '';
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } else {
      throw HttpException(response.body, uri: response.request?.url);
    }
  }

  // Basic HTTP requests
  Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  // Multipart requests for file uploads
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, dynamic> data,
    List<MapEntry<String, File>> files,
  ) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    // Add auth header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      // Add form fields
      data.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            request.fields[key] = item.toString();
          }
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Add files with proper content type
      for (var fileEntry in files) {
        final file = fileEntry.value;
        final fileName = file.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Read file bytes
        final bytes = await file.readAsBytes();

        // Determine MIME type based on file extension
        MediaType contentType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'gif':
            contentType = MediaType('image', 'gif');
            break;
          case 'webp':
            contentType = MediaType('image', 'webp');
            break;
          case 'bmp':
            contentType = MediaType('image', 'bmp');
            break;
          case 'heic':
          case 'heif':
            contentType = MediaType('image', 'heic');
            break;
          default:
            // Default to JPEG for unknown image types
            contentType = MediaType('image', 'jpeg');
        }

        // Ensure filename has proper extension
        String finalFileName = fileName;
        if (!fileName.contains('.') ||
            ![
              'jpg',
              'jpeg',
              'png',
              'gif',
              'webp',
              'bmp',
              'heic',
              'heif',
            ].contains(extension)) {
          finalFileName = '${fileName.split('.').first}.jpg';
          contentType = MediaType('image', 'jpeg');
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            fileEntry.key,
            bytes,
            filename: finalFileName,
            contentType: contentType,
          ),
        );
      }
      final response = await http.Response.fromStream(await request.send());
      return _processResponse(response);
    }
  }
}
