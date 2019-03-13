import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';
import 'package:flutter_todo_bloc/models/priority.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/widgets/form_fields/priority_form_field.dart';
import 'package:flutter_todo_bloc/widgets/form_fields/toggle_form_field.dart';
import 'package:flutter_todo_bloc/widgets/helpers/message_dialog.dart';
import 'package:flutter_todo_bloc/widgets/helpers/priority_helper.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/confirm_dialog.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';

class TodoEditorPage extends StatefulWidget {
  final String todoId;
  final String priority;

  TodoEditorPage({Key key, this.todoId, this.priority}) : super(key: key);

  _TodoEditorPageState createState() => _TodoEditorPageState();
}

class _TodoEditorPageState extends State<TodoEditorPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'content': null,
    'priority': Priority.Low,
    'isDone': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthenticationBloc _authenticationBloc;
  TodoBloc _todoBloc;
  Todo _todo;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(Configure.AppName),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String choice) async {
            switch (choice) {
              case 'Settings':
                Navigator.pushNamed(context, '/settings');
                break;

              case 'LogOut':
                bool confirm = await ConfirmDialog.show(context);

                if (confirm) {
                  Navigator.pop(context);

                  _todoBloc.dispatch(ClearTodos());
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

  Widget _buildFloatingActionButton(Todo todo) {
    return FloatingActionButton(
      child: Icon(Icons.save),
      onPressed: () {
        if (!_formKey.currentState.validate()) {
          return;
        }

        _formKey.currentState.save();

        if (todo != null) {
          _todoBloc.dispatch(UpdateTodo(
            id: todo.id,
            title: _formData['title'],
            content: _formData['content'],
            priority: _formData['priority'],
            isDone: _formData['isDone'],
          ));
        } else {
          _todoBloc.dispatch(CreateTodo(
            title: _formData['title'],
            content: _formData['content'],
            priority: _formData['priority'],
            isDone: _formData['isDone'],
          ));
        }
      },
    );
  }

  Widget _buildTitleField(Todo todo) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Title'),
      initialValue: todo != null ? todo.title : '',
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter todo\'s title';
        }
      },
      onSaved: (value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildContentField(Todo todo) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Content'),
      initialValue: todo != null ? todo.content : '',
      maxLines: 5,
      onSaved: (value) {
        _formData['content'] = value;
      },
    );
  }

  Widget _buildOthers(Todo todo) {
    final bool isDone = todo != null && todo.isDone;
    final priority = todo != null
        ? todo.priority
        : PriorityHelper.toPriority(
            "Priority.${widget.priority != null ? widget.priority : 'Low'}");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ToggleFormField(
          initialValue: isDone,
          onSaved: (value) {
            _formData['isDone'] = value;
          },
        ),
        PriorityFormField(
          initialValue: priority,
          onSaved: (value) {
            _formData['priority'] = value;
          },
        )
      ],
    );
  }

  Widget _buildForm(Todo todo) {
    _formData['title'] = todo != null ? todo.title : null;
    _formData['content'] = todo != null ? todo.content : null;
    _formData['priority'] = todo != null
        ? todo.priority
        : PriorityHelper.toPriority(
            "Priority.${widget.priority != null ? widget.priority : 'Low'}");
    _formData['isDone'] = todo != null ? todo.isDone : false;

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          _buildTitleField(todo),
          _buildContentField(todo),
          SizedBox(
            height: 12.0,
          ),
          _buildOthers(todo),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _todoBloc,
      builder: (BuildContext context, TodoState state) {
        if (state is TodoLoaded) {
          _todo = state.todo;
        }

        final form =
            _todo != null || state is TodoLoaded ? _buildForm(_todo) : null;
        final floatingActionButton = _todo != null || state is TodoLoaded
            ? _buildFloatingActionButton(_todo)
            : null;

        Stack stack = Stack(
          children: <Widget>[
            Scaffold(
              appBar: _buildAppBar(),
              floatingActionButton: floatingActionButton,
              body: Container(
                child: form,
                padding: EdgeInsets.all(8),
              ),
            )
          ],
        );

        if (state is TodoLoading) {
          stack.children.add(LoadingModal());
        }

        if (state is TodosLoaded) {
          Future.delayed(
            Duration.zero,
            () => Navigator.pop(context),
          );
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
}
