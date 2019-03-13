import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';

// #region Events
abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginStarted extends LoginEvent {
  final String email;
  final String password;

  LoginStarted({
    @required this.email,
    @required this.password,
  })  : assert(email != null),
        assert(password != null),
        super([email, password]);

  @override
  String toString() => 'LoginStarted { email: $email, password: $password}';
}
// #endregion

// #region States
abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInProgress extends LoginState {}

class LoginInitial extends LoginState {}

class LoginError extends LoginState {
  final String error;

  LoginError({
    @required this.error,
  })  : assert(error != null),
        super([error]);

  @override
  String toString() => 'LoginFailure {error: $error}';
}
// #endregion

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(
    LoginState currentState,
    LoginEvent event,
  ) async* {
    if (event is LoginStarted) {
      _mapLoginStartedToState(event);
    }
  }

  Stream<LoginState> _mapLoginStartedToState(LoginStarted event) async* {
    yield LoginInProgress();

    try {
      final user = await userRepository.authenticate(
        email: event.email,
        password: event.password,
      );

      authenticationBloc.dispatch(LoggedIn(user: user));

      yield LoginInitial();
    } catch (error) {
      yield LoginError(error: error.toString());
    }
  }
}
