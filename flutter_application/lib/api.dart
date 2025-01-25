import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> transferImage(imagePath) async {
  final url = Uri.parse('http://127.0.0.1:5000/image-path');
  final response = await http.post(url,headers: {'Content-Type': 'application/json'}, body: jsonEncode({'imagePath': imagePath}));

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    return result;
  } else {
    print(response.reasonPhrase);
    return {};
  }
}