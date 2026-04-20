import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/constants/api_url.dart';

enum AuthType { none, required }

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = ConfigAPI.baseUrl});

  Future<String?> getToken() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not signed in");

    return user.getIdToken(true);
  }

  // Http get method
  Future<http.Response> get(
    String path, {
    AuthType auth = AuthType.none,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'ngrok-skip-browser-warning':
          'true', // Delete when not using ngrok anymore
      if (auth == AuthType.required)
        'Authorization': 'Bearer ${await getToken()}',
    };
    debugPrint("API GET Request: $url with headers: $headers");
    return await http.get(url, headers: headers);
  }

  // Http post method
  Future<http.Response> post(
    String path, {
    required Map<String, dynamic> body,
    AuthType auth = AuthType.none,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'ngrok-skip-browser-warning':
          'true', // Delete when not using ngrok anymore
      'Content-Type': 'application/json',
      if (auth == AuthType.required)
        'Authorization': 'Bearer ${await getToken()}',
    };

    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  // Http post method for file uploads
  Future<http.Response> postFile(
    String path, {
    required File item,
    AuthType auth = AuthType.none,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'ngrok-skip-browser-warning':
          'true', // Delete when not using ngrok anymore
      if (auth == AuthType.required)
        'Authorization': 'Bearer ${await getToken()}',
    };

    final request = http.MultipartRequest("POST", url);

    // Prepare image file
    final extension = p.extension(item.path);
    final filename = 'new$extension';

    final stream = http.ByteStream(item.openRead());
    final length = await item.length();

    final file = http.MultipartFile('file', stream, length, filename: filename);

    request.headers.addAll(headers);
    request.files.add(file);

    http.StreamedResponse streamedResponse = await request.send();

    return await http.Response.fromStream(streamedResponse);
  }
}
