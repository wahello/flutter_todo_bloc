import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/blocs/settings_bloc.dart';
import 'package:flutter_todo_bloc/models/settings.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/confirm_dialog.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AuthenticationBloc _authenticationBloc;
  SettingsBloc _settingsBloc;
  Settings settings;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    _settingsBloc.dispatch(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _settingsBloc,
      builder: (BuildContext context, SettingsState state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildPageContent(state),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Settings'),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String choice) async {
            switch (choice) {
              case 'LogOut':
                bool confirm = await ConfirmDialog.show(context);

                if (confirm) {
                  Navigator.pop(context);

                  _authenticationBloc.dispatch(LoggedOut());
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'LogOut',
                child: ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Logout'),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildPageContent(SettingsState state) {
    if (state is SettingsLoaded) {
      settings = state.settings;
    }

    if (settings != null) {
      return ListView(
        children: <Widget>[
          SwitchListTile(
            activeColor: Colors.blue,
            value: settings.isShortcutsEnabled,
            onChanged: (value) {
              _settingsBloc.dispatch(ToggleShortcutsEnabled());
            },
            title: Text('Enable shortcuts'),
          ),
          SwitchListTile(
            activeColor: Colors.blue,
            value: settings.isDarkThemeUsed,
            onChanged: (value) {
              _settingsBloc.dispatch(ToggleDarkThemeUsed());
            },
            title: Text('Use dark theme'),
          )
        ],
      );
    }

    return LoadingModal();
  }
}
