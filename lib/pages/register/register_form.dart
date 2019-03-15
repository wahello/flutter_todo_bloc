import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/blocs/registration_bloc.dart';
import 'package:flutter_todo_bloc/widgets/helpers/message_dialog.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/rounded_button.dart';

class RegisterForm extends StatefulWidget {
  final RegistrationBloc registrationBloc;

  RegisterForm({
    Key key,
    @required this.registrationBloc,
  })  : assert(registrationBloc != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  RegistrationBloc get registrationBloc => widget.registrationBloc;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.85;

    return BlocBuilder<RegistrationEvent, RegistrationState>(
        bloc: registrationBloc,
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              _buildEmailField(),
                              _buildPasswordField(),
                              _buildConfirmPasswordField(),
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

          if (state is RegistrationInProgress) {
            stack.children.add(LoadingModal());
          }

          if (state is RegistrationError) {
            Future.delayed(
              Duration.zero,
              () => MessageDialog.show(context, message: state.error),
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

  void _register() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    registrationBloc.dispatch(RegistrationStarted(
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
      controller: _passwordController,
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

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(labelText: 'Confirm Password'),
      validator: (value) {
        if (value != _passwordController.value.text) {
          return 'Password and confirm password are not match';
        }
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
          onPressed: _register,
        ),
      ],
    );
  }
}
