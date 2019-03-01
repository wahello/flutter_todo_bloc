import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/pages/auth/auth_page.dart';
import 'package:flutter_todo_bloc/pages/todo/todo_list_page.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Transition transition) {
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();

  final UserRepository userRepository = UserRepository();

  runApp(App(userRepository: userRepository));
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc _authenticationBloc;
  UserRepository get userRepository => widget.userRepository;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    _authenticationBloc.dispatch(AppStarted());
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<AuthenticationBloc>(bloc: _authenticationBloc)
      ],
      child: MaterialApp(
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationAuthenticated) {
              return TodoListPage();
            }

            if (state is AuthenticationUnauthenticated) {
              return AuthPage(userRepository: userRepository);
            }
          },
        ),
      ),
    );
  }
}
