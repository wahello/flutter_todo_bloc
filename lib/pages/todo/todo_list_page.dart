import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';
import 'package:flutter_todo_bloc/models/filter.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/widgets/helpers/message_dialog.dart';
import 'package:flutter_todo_bloc/widgets/todo/todo_list_view.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/confirm_dialog.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key key}) : super(key: key);

  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  AuthenticationBloc _authenticationBloc;
  TodoBloc _todoBloc;
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();

    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.dispatch(FetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _todoBloc,
      builder: (BuildContext context, TodoState state) {
        if (state is TodosLoaded) {
          todos = state.todos;
        }

        Stack stack = Stack(
          children: <Widget>[
            _buildPageContent(context, todos),
          ],
        );

        if (state is TodosLoading) {
          stack.children.add(LoadingModal());
        }

        if (state is TodoError) {
          Future.delayed(
            Duration.zero,
            () => MessageDialog.show(context, message: state.error),
          );
        }

        return stack;
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(Configure.AppName),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        PopupMenuButton<Filter>(
          icon: Icon(Icons.filter_list),
          itemBuilder: (BuildContext context) {
            return [
              CheckedPopupMenuItem<Filter>(
                checked: false,
                value: Filter.All,
                child: Text('All'),
              ),
              CheckedPopupMenuItem<Filter>(
                checked: false,
                value: Filter.Done,
                child: Text('Done'),
              ),
              CheckedPopupMenuItem<Filter>(
                checked: false,
                value: Filter.NotDone,
                child: Text('Not Done'),
              ),
            ];
          },
          onSelected: (Filter filter) {
            print(filter);

            _todoBloc.dispatch(FilterTodos(filter: filter));
          },
        ),
        PopupMenuButton<String>(
          onSelected: (String choice) async {
            switch (choice) {
              case 'Settings':
                Navigator.pushNamed(context, '/settings');
                break;

              case 'LogOut':
                bool confirm = await ConfirmDialog.show(context);

                if (confirm) {
                  _authenticationBloc.dispatch(LoggedOut());
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'Settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
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

  Widget _buildFloatingActionButton(
    BuildContext context,
    bool isShortcutsEnabled,
  ) {
    // if (isShortcutsEnabled) {
    //   return ShortcutsEnabledTodoFab();
    // }

    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, '/editor');
      },
    );
  }

  Widget _buildPageContent(BuildContext context, List<Todo> todos) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFloatingActionButton(context, false),
      body: TodoListView(todos: todos),
    );
  }
}
