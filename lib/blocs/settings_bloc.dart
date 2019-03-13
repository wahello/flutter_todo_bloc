import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

// #region Events
abstract class SettingsEvent extends Equatable {
  SettingsEvent([List props = const []]) : super(props);
}

class LoadSettings extends SettingsEvent {}
// #endregion

// #region States
abstract class SettingsState extends Equatable {
  SettingsState([List props = const []]) : super(props);
}

class SettingsUnloaded extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {}
// #endregion

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState => SettingsUnloaded();

  @override
  Stream<SettingsState> mapEventToState(
    SettingsState currentState,
    SettingsEvent event,
  ) async* {
    if (event is LoadSettings) {
      yield SettingsLoading();

      yield SettingsLoaded();
    }
  }
}
