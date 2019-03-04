import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';
import 'package:flutter_todo_bloc/widgets/helpers/message_dialog.dart';
import 'package:flutter_todo_bloc/widgets/todo/todo_editor.dart';
import 'package:flutter_todo_bloc/widgets/ui_elements/loading_modal.dart';

class TodoEditorPage extends StatefulWidget {
  final String todoId;
  final String priority;

  TodoEditorPage({Key key, this.todoId, this.priority}) : super(key: key);

  _TodoEditorPageState createState() => _TodoEditorPageState();
}

class _TodoEditorPageState extends State<TodoEditorPage> {
  TodoBloc _todoBloc;

  @override
  void initState() {
    super.initState();

    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.dispatch(FetchTodo(id: widget.todoId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _todoBloc,
      builder: (BuildContext context, TodoState state) {
        Stack stack = Stack(
          children: <Widget>[],
        );

        if (state is TodoLoaded) {
          stack.children.add(TodoEditor(
            todo: state.todo,
            priority: widget.priority,
          ));
        }

        if (state is TodoLoading) {
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
}
