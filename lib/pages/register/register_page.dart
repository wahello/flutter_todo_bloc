import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/blocs/registration_bloc.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';
import 'package:flutter_todo_bloc/pages/register/register_form.dart';

class RegisterPage extends StatefulWidget {
  final UserRepository userRepository;

  RegisterPage({
    @required this.userRepository,
  }) : assert(userRepository != null);

  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegistrationBloc _registrationBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get userRepository => widget.userRepository;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _registrationBloc = RegistrationBloc(
      authenticationBloc: _authenticationBloc,
      userRepository: userRepository,
    );
  }

  @override
  void dispose() {
    _registrationBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterForm(
      registrationBloc: _registrationBloc,
    );
  }
}
