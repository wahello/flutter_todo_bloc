import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key key}) : super(key: key);

  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  TodoBloc _todoBloc;

  @override
  void initState() {
    super.initState();

    _todoBloc = BlocProvider.of<TodoBloc>(context);

    _todoBloc.dispatch(FetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _todoBloc,
      builder: (BuildContext context, TodoState state) {
        if (state is TodoLoading) {
          return Center(
            child: Text('Loading'),
          );
        }

        if (state is TodoLoaded) {
          return Center(
            child: Text('Todo Count: ${state.todos.length}'),
          );
        }

        if (state is TodoError) {
          return Center(
            child: Text('Error: ${state.error}'),
          );
        }
      },
    );
  }
}
