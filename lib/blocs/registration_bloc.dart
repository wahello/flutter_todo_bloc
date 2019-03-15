import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/models/user.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';

// #region Events
abstract class RegistrationEvent extends Equatable {
  RegistrationEvent([List props = const []]) : super(props);
}

class RegistrationInitialized extends RegistrationEvent {}

class RegistrationStarted extends RegistrationEvent {
  final String email;
  final String password;

  RegistrationStarted({
    @required this.email,
    @required this.password,
  })  : assert(email != null),
        assert(password != null),
        super([email, password]);

  @override
  String toString() =>
      'RegistrationStarted { email: $email, password: $password}';
}
// #endregion

// #region States
abstract class RegistrationState extends Equatable {
  RegistrationState([List props = const []]) : super(props);
}

class RegistrationInProgress extends RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {}

class RegistrationError extends RegistrationState {
  final String error;

  RegistrationError({
    @required this.error,
  })  : assert(error != null),
        super([error]);

  @override
  String toString() => 'RegistrationError {error: $error}';
}
// #endregion

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  RegistrationBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  RegistrationState get initialState => RegistrationInitial();

  @override
  Stream<RegistrationState> mapEventToState(
    RegistrationState currentState,
    RegistrationEvent event,
  ) async* {
    if (event is RegistrationInitialized) {
      yield RegistrationInitial();
    } else if (event is RegistrationStarted) {
      yield* _mapRegistrationStartedToState(event);
    }
  }

  Stream<RegistrationState> _mapRegistrationStartedToState(
      RegistrationStarted event) async* {
    yield RegistrationInProgress();

    try {
      final User user = await userRepository.register(
        email: event.email,
        password: event.password,
      );

      authenticationBloc.dispatch(LoggedIn(user: user));

      yield RegistrationSuccess();
    } catch (error) {
      yield RegistrationError(error: error.toString());
    }
  }
}
