import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/models/priority.dart';
import 'package:flutter_todo_bloc/models/user.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/models/filter.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';
import 'package:flutter_todo_bloc/providers/firebase_provider.dart';

class TodoRepository {
  final FirebaseProvider firebaseProvider;
  final UserRepository userRepository;
  List<Todo> todos = [];
  Filter _filter = Filter.All;

  Filter get filter => _filter;

  TodoRepository({
    @required this.firebaseProvider,
    @required this.userRepository,
  })  : assert(firebaseProvider != null),
        assert(userRepository != null);

  Future<List<Todo>> fetchTodos() async {
    final User user = await userRepository.getUser();
    todos = await firebaseProvider.fetchTodos(user);

    return todos;
  }

  Todo fetchTodo(String todoId) {
    final Todo todo =
        todos.firstWhere((todo) => todo.id == todoId, orElse: () => null);

    return todo;
  }

  List<Todo> filterTodos(Filter newFilter) {
    _filter = newFilter;

    if (newFilter == Filter.All) {
      return todos;
    }

    return todos
        .where((todo) => todo.isDone == (newFilter == Filter.Done))
        .toList();
  }

  Future<List<Todo>> createTodo(
    String title,
    String content,
    Priority priority,
    bool isDone,
  ) async {
    final User user = await userRepository.getUser();
    final Todo todo = await firebaseProvider.createTodo(
      user,
      title,
      content,
      priority,
      isDone,
    );

    todos = List.from(todos)..add(todo);

    return filterTodos(filter);
  }

  Future<List<Todo>> updateTodo(
    String id,
    String title,
    String content,
    Priority priority,
    bool isDone,
  ) async {
    final User user = await userRepository.getUser();
    final Todo todo = await firebaseProvider.updateTodo(
      user,
      id,
      title,
      content,
      priority,
      isDone,
    );

    todos = todos.map((oldTodo) => oldTodo.id == id ? todo : oldTodo).toList();

    return filterTodos(filter);
  }

  Future<List<Todo>> deleteTodo(String id) async {
    final User user = await userRepository.getUser();
    await firebaseProvider.deleteTodo(user, id);

    todos = todos.where((todo) => todo.id != id).toList();

    return filterTodos(filter);
  }
}
