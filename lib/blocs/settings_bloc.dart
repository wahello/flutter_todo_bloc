import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/models/settings.dart';
import 'package:flutter_todo_bloc/repositories/settings_repository.dart';

// #region Events
abstract class SettingsEvent extends Equatable {
  SettingsEvent([List props = const []]) : super(props);
}

class LoadSettings extends SettingsEvent {}

class ToggleDarkThemeUsed extends SettingsEvent {}

class ToggleShortcutsEnabled extends SettingsEvent {}
// #endregion

// #region States
abstract class SettingsState extends Equatable {
  SettingsState([List props = const []]) : super(props);
}

class SettingsUnloaded extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Settings settings;

  SettingsLoaded({@required this.settings})
      : assert(settings != null),
        super([settings]);
}
// #endregion

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({
    @required this.settingsRepository,
  }) : assert(settingsRepository != null);

  @override
  SettingsState get initialState => SettingsUnloaded();

  @override
  Stream<SettingsState> mapEventToState(
    SettingsState currentState,
    SettingsEvent event,
  ) async* {
    if (event is LoadSettings) {
      yield SettingsLoading();

      final settings = await settingsRepository.loadSettings();

      yield SettingsLoaded(settings: settings);
    } else if (event is ToggleDarkThemeUsed) {
      yield SettingsLoading();

      settingsRepository.toggleDarkThemeUsedSetting();
      final settings = await settingsRepository.loadSettings();

      yield SettingsLoaded(settings: settings);
    }
  }
}
