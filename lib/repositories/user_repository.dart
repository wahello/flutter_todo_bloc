import 'dart:async';

import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/models/user.dart';
import 'package:flutter_todo_bloc/providers/firebase_provider.dart';
import 'package:flutter_todo_bloc/providers/shared_preferences_provider.dart';

class UserRepository {
  final FirebaseProvider firebaseProvider;
  final SharedPreferencesProvider sharedPreferencesProvider;

  UserRepository({
    @required this.firebaseProvider,
    @required this.sharedPreferencesProvider,
  })  : assert(firebaseProvider != null),
        assert(sharedPreferencesProvider != null);

  Future<User> authenticate({
    @required String email,
    @required String password,
  }) async {
    final user = await firebaseProvider.authenticate(email, password);

    return user;
  }

  void saveUser(User user) {
    sharedPreferencesProvider.saveUser(user);
  }

  Future<User> loadUser() async {
    final user = await sharedPreferencesProvider.loadUser();

    return user;
  }

  void clearData() {
    sharedPreferencesProvider.clear();
  }

  Future<bool> isAuthenticated() async {
    final user = await loadUser();

    return user.id != null;
  }
}
