import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/blocs/login_bloc.dart';
import 'package:flutter_todo_bloc/widgets/helpers/message_dialog.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/rounded_button.dart';

class AuthForm extends StatefulWidget {
  final LoginBloc loginBloc;

  AuthForm({
    Key key,
    @required this.loginBloc,
  })  : assert(loginBloc != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginBloc get loginBloc => widget.loginBloc;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.85;

    return BlocBuilder<LoginEvent, LoginState>(
        bloc: loginBloc,
        builder: (BuildContext context, LoginState state) {
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              _buildEmailField(),
                              _buildPasswordField(),
                              SizedBox(
                                height: 20.0,
                              ),
                              _buildButtonRow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          if (state is LoginInProgress) {
            stack.children.add(LoadingModal());
          }

          if (state is LoginError) {
            Future.delayed(
              Duration.zero,
              () => MessageDialog.show(context, message: state.error),
            );
          }

          return stack;
        });
  }

  void _authenticate() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    loginBloc.dispatch(LoginStarted(
      email: _formData['email'],
      password: _formData['password'],
    ));
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(labelText: 'Password'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password';
        }
      },
      onSaved: (value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RoundedButton(
          icon: Icon(Icons.edit),
          label: 'Register',
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        SizedBox(
          width: 20.0,
        ),
        RoundedButton(
          icon: Icon(Icons.lock_open),
          label: 'Login',
          onPressed: _authenticate,
        ),
      ],
    );
  }
}
