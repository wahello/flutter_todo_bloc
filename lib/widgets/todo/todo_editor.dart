import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';
import 'package:flutter_todo_bloc/models/priority.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/widgets/form_fields/priority_form_field.dart';
import 'package:flutter_todo_bloc/widgets/form_fields/toggle_form_field.dart';
import 'package:flutter_todo_bloc/widgets/helpers/priority_helper.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/confirm_dialog.dart';

class TodoEditor extends StatefulWidget {
  final Todo todo;
  final String priority;

  TodoEditor({
    Key key,
    this.todo,
    this.priority,
  }) : super(key: key);

  _TodoEditorState createState() => _TodoEditorState();
}

class _TodoEditorState extends State<TodoEditor> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'content': null,
    'priority': Priority.Low,
    'isDone': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TodoBloc _todoBloc;

  @override
  void initState() {
    super.initState();

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

                  // widget.onLogOut();
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.save),
      onPressed: () {
        if (!_formKey.currentState.validate()) {
          return;
        }

        _formKey.currentState.save();

        // if (widget.todo != null) {
        //   widget.onUpdateTodo(
        //     Todo(
        //       id: widget.todo.id,
        //       title: _formData['title'],
        //       content: _formData['content'],
        //       priority: _formData['priority'],
        //       isDone: _formData['isDone'],
        //       userId: widget.user.id,
        //     ),
        //     this._onSuccess,
        //     this._onError,
        //   );
        // } else {
        //   widget.onCreateTodo(
        //     _formData['title'],
        //     _formData['content'],
        //     _formData['priority'],
        //     _formData['isDone'],
        //     this._onSuccess,
        //     this._onError,
        //   );
        // }
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

  Widget _buildForm() {
    Todo todo = widget.todo;

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

  Future<bool> _onWillPop() async {
    _todoBloc.dispatch(UnloadTodo());

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        floatingActionButton: _buildFloatingActionButton(),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: _buildForm(),
          ),
        ),
      ),
    );
  }
}
