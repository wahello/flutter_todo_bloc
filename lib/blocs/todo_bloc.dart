import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_todo_bloc/models/filter.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/repositories/todo_repository.dart';

// #region Events
abstract class TodoEvent extends Equatable {
  TodoEvent([List props = const []]) : super(props);
}

class FetchTodos extends TodoEvent {}

class FilterTodos extends TodoEvent {
  final Filter filter;

  FilterTodos({
    @required this.filter,
  })  : assert(filter != null),
        super([filter]);

  @override
  String toString() => 'FilterTodos { filter: $filter }';
}

class FetchTodo extends TodoEvent {
  final String id;

  FetchTodo({
    @required this.id,
  })  : assert(id != null),
        super([id]);

  @override
  String toString() => 'FetchTodo { id: $id }';
}

class UnloadTodo extends TodoEvent {}

// #endregion

// #region States
abstract class TodoState extends Equatable {
  TodoState([List props = const []]) : super(props);
}

class TodosEmpty extends TodoState {}

class TodosLoading extends TodoState {}

class TodosLoaded extends TodoState {
  final List<Todo> todos;

  TodosLoaded({
    @required this.todos,
  }) : assert(todos != null);
}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final Todo todo;

  TodoLoaded({
    @required this.todo,
  }) : assert(todo != null);
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

class TodoUnloaded extends TodoState {}
// #endregion

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({
    @required this.todoRepository,
  }) : assert(todoRepository != null);

  @override
  TodoState get initialState => TodosEmpty();

  @override
  Stream<TodoState> mapEventToState(
    TodoState currentState,
    TodoEvent event,
  ) async* {
    if (event is FetchTodos) {
      yield TodosLoading();

      try {
        final List<Todo> todos = await todoRepository.fetchTodos();

        yield TodosLoaded(todos: todos);
      } catch (error) {
        yield TodoError(error: error.toString());
      }
    }

    if (event is FetchTodo) {
      yield TodoLoading();

      try {
        final Todo todo = todoRepository.fetchTodo(event.id);

        yield TodoLoaded(todo: todo);
      } catch (error) {
        yield TodoError(error: error.toString());
      }
    }

    if (event is UnloadTodo) {
      yield TodoUnloaded();
    }

    if (event is FilterTodos) {
      final List<Todo> todos = await todoRepository.filterTodos(event.filter);

      yield TodosLoaded(todos: todos);
    }
  }
}
