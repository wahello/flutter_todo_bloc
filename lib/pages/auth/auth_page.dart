import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo_bloc/pages/auth/auth_form.dart';
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/blocs/login_bloc.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';

class AuthPage extends StatefulWidget {
  final UserRepository userRepository;

  AuthPage({@required this.userRepository}) : assert(userRepository != null);

  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get userRepository => widget.userRepository;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      authenticationBloc: _authenticationBloc,
      userRepository: userRepository,
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Configure.AppName),
      ),
      body: AuthForm(
        authenticationBloc: _authenticationBloc,
        loginBloc: _loginBloc,
      ),
    );
  }
}
