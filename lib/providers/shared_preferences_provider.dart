import 'package:flutter_todo_bloc/models/settings.dart';
import 'package:flutter_todo_bloc/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final Settings settings = Settings(
      isShortcutsEnabled: _loadIsShortcutsEnabled(prefs),
      isDarkThemeUsed: _loadIsDarkThemeUsed(prefs),
    );

    return settings;
  }

  void toggleShortcutsEnabledSetting() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isShortcutsEnabled', !_loadIsShortcutsEnabled(prefs));
  }

  void toggleDarkThemeUsedSetting() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isDarkThemeUsed', !_loadIsDarkThemeUsed(prefs));
  }

  Future<User> loadUser() async {
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

  void saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('userId', user.id);
    prefs.setString('email', user.email);
    prefs.setString('token', user.token);
    prefs.setString('refreshToken', user.refreshToken);
    prefs.setString('expiryTime', user.expiryTime);
  }

  void clear() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.clear();
  }

  bool _loadIsShortcutsEnabled(SharedPreferences prefs) {
    return prefs.getKeys().contains('isShortcutsEnabled') &&
        prefs.getBool('isShortcutsEnabled');
  }

  bool _loadIsDarkThemeUsed(SharedPreferences prefs) {
    return prefs.getKeys().contains('isDarkThemeUsed') &&
        prefs.getBool('isDarkThemeUsed');
  }
}
