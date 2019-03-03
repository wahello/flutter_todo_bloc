import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/repositories/todo_repository.dart';

// #region Events
abstract class TodoEvent extends Equatable {
  TodoEvent([List props = const []]) : super(props);
}

class FetchTodos extends TodoEvent {}

// #endregion

// #region States
abstract class TodoState extends Equatable {
  TodoState([List props = const []]) : super(props);
}

class TodoEmpty extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  TodoLoaded({
    @required this.todos,
  }) : assert(todos != null);
}

class TodoError extends TodoState {
  final String error;

  TodoError({
    @required this.error,
  })  : assert(error != null),
        super([error]);

  @override
  String toString() => 'LoginFailure {error: $error}';
}
// #endregion

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({
    @required this.todoRepository,
  }) : assert(todoRepository != null);

  @override
  TodoState get initialState => TodoEmpty();

  @override
  Stream<TodoState> mapEventToState(
    TodoState currentState,
    TodoEvent event,
  ) async* {
    if (event is FetchTodos) {
      yield TodoLoading();

      try {
        final List<Todo> todos = await todoRepository.fetchTodos();

        yield TodoLoaded(todos: todos);
      } catch (error) {
        yield TodoError(error: error.toString());
      }
    }
  }
}
