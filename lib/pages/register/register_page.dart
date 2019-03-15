import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/widgets/helpers/message_dialog.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';
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

  void register(String email, String password) {
    _registrationBloc.dispatch(RegistrationStarted(
      email: email,
      password: password,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.85;

    return BlocBuilder<RegistrationEvent, RegistrationState>(
        bloc: _registrationBloc,
        builder: (BuildContext context, RegistrationState state) {
          Stack stack = Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text(Configure.AppName),
                ),
                body: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: targetWidth,
                        child: RegisterForm(register: register),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          if (state is RegistrationInProgress) {
            stack.children.add(LoadingModal());
          }

          if (state is RegistrationError) {
            Future.delayed(
              Duration.zero,
              () {
                MessageDialog.show(context, message: state.error);

                _registrationBloc.dispatch(RegistrationInitialized());
              },
            );
          }

          if (state is RegistrationSuccess) {
            Future.delayed(
              Duration.zero,
              () => Navigator.pop(context),
            );
          }

          return stack;
        });
  }
}
