import 'package:flutter/material.dart';

import 'package:flutter_todo_bloc/widgets/ui_elements/rounded_button.dart';

class RegisterForm extends StatefulWidget {
  final Function register;

  RegisterForm({Key key, @required this.register})
      : assert(register != null),
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

  @override
  Widget build(BuildContext context) {
    return Form(
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
    );
  }

  void _register() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    widget.register(_formData['email'], _formData['password']);
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
