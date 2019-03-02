import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/.env.dart';

class FirebaseProvider {
  final http.Client client;

  FirebaseProvider({@required this.client}) : assert(client != null);

  Future<Map<String, dynamic>> authenticate(
    String email,
    String password,
  ) async {
    final Map<String, dynamic> formData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    final http.Response response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${Configure.ApiKey}',
      body: json.encode(formData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    return responseData;
  }
}
