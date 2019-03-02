import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_todo_bloc/models/user.dart';
import 'package:flutter_todo_bloc/providers/firebase_provider.dart';

class UserRepository {
  final FirebaseProvider firebaseProvider;

  UserRepository({@required this.firebaseProvider})
      : assert(firebaseProvider != null);

  Future<User> authenticate({
    @required String email,
    @required String password,
  }) async {
    final Map<String, dynamic> responseData =
        await firebaseProvider.authenticate(email, password);

    if (responseData.containsKey('idToken')) {
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final User user = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken'],
          refreshToken: responseData['refreshToken'],
          expiryTime: expiryTime.toIso8601String());

      return user;
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      throw Exception('Email is not found.');
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      throw Exception('Password is invalid.');
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      throw Exception('The user account has been disabled.');
    }

    throw Exception('Unknown error.');
  }

  Future<void> persistUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('userId', user.id);
    prefs.setString('email', user.email);
    prefs.setString('token', user.token);
    prefs.setString('refreshToken', user.refreshToken);
    prefs.setString('expiryTime', user.expiryTime);
  }

  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final User user = User(
      id: prefs.get('userId'),
      email: prefs.get('email'),
      token: prefs.get('token'),
      refreshToken: prefs.get('refreshToken'),
      expiryTime: prefs.get('expiryTime'),
    );

    return user;
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> isAuthenticated() async {
    final user = await getUser();

    return user.id != null;
  }
}
