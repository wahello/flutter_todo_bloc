import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/models/user.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';
import 'package:flutter_todo_bloc/providers/firebase_provider.dart';

class TodoRepository {
  final FirebaseProvider firebaseProvider;
  final UserRepository userRepository;
  List<Todo> todos;

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
    final Todo todo = todos.firstWhere((todo) => todo.id == todoId);

    return todo;
  }
}
