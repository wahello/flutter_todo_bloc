import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/models/settings.dart';
import 'package:flutter_todo_bloc/providers/shared_preferences_provider.dart';

class SettingsRepository {
  final SharedPreferencesProvider sharedPreferencesProvider;

  SettingsRepository({
    @required this.sharedPreferencesProvider,
  }) : assert(sharedPreferencesProvider != null);

  Future<Settings> loadSettings() async {
    return await sharedPreferencesProvider.loadSettings();
  }

  void toggleShortcutsEnabledSetting() async {
    sharedPreferencesProvider.toggleShortcutsEnabledSetting();
  }

  void toggleDarkThemeUsedSetting() async {
    sharedPreferencesProvider.toggleDarkThemeUsedSetting();
  }
}
