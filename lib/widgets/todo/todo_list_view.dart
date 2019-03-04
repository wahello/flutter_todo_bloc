import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/widgets/todo/todo_cart.dart';

class TodoListView extends StatelessWidget {
  final List<Todo> todos;

  TodoListView({Key key, @required this.todos})
      : assert(todos != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget todoCards = todos.length > 0 ? _buildListView() : _buildEmptyText();

    return todoCards;
  }

  Widget _buildEmptyText() {
    String emptyText =
        'This is boring here. \r\nCreate a Not Done todo to make it crowd.';

    return Container(
      color: Color.fromARGB(16, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/todo_list.svg',
            width: 200,
          ),
          SizedBox(
            height: 40.0,
          ),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (BuildContext context, int index) {
        Todo todo = todos[index];

        return Dismissible(
          key: Key(todo.id),
          onDismissed: (DismissDirection direction) {},
          child: TodoCard(todo),
          background: Container(color: Colors.red),
        );
      },
    );
  }
}
