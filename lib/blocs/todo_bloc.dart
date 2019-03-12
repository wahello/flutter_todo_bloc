import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_todo_bloc/models/priority.dart';
import 'package:flutter_todo_bloc/models/filter.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/repositories/todo_repository.dart';

// #region Events
abstract class TodoEvent extends Equatable {
  TodoEvent([List props = const []]) : super(props);
}

class ClearTodos extends TodoEvent {}

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

class CreateTodo extends TodoEvent {
  final String title;
  final String content;
  final Priority priority;
  final bool isDone;

  CreateTodo({
    @required this.title,
    this.content,
    this.priority = Priority.Low,
    this.isDone = false,
  }) : super([title, content, priority, isDone]);
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  UpdateTodo({@required this.todo}) : super([todo]);
}
// #endregion

// #region States
abstract class TodoState extends Equatable {
  TodoState([List props = const []]) : super(props);
}

class TodosEmpty extends TodoState {}

class TodosLoading extends TodoState {}

class TodosLoaded extends TodoState {
  final List<Todo> todos;
  final Filter filter;

  TodosLoaded({
    @required this.todos,
    this.filter = Filter.All,
  })  : assert(todos != null),
        super([todos, filter]);

  @override
  String toString() => 'TodosLoaded {todos: $todos}';
}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final Todo todo;

  TodoLoaded({
    @required this.todo,
  }) : super([todo]);

  @override
  String toString() => 'TodoLoaded {todo: $todo}';
}

class TodoCreated extends TodoState {}

class TodoUpdated extends TodoState {}

class TodoError extends TodoState {
  final String error;

  TodoError({
    @required this.error,
  })  : assert(error != null),
        super([error]);

  @override
  String toString() => 'TodoError {error: $error}';
}
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
    if (event is ClearTodos) {
      yield TodosEmpty();
    } else if (event is FetchTodos) {
      yield TodosLoading();

      try {
        final List<Todo> todos = await todoRepository.fetchTodos();

        yield TodosLoaded(todos: todos);
      } catch (error) {
        yield TodoError(error: error.toString());
      }
    } else if (event is FetchTodo) {
      yield TodoLoading();

      try {
        final Todo todo = todoRepository.fetchTodo(event.id);

        yield TodoLoaded(todo: todo);
      } catch (error) {
        yield TodoError(error: error.toString());
      }
    } else if (event is FilterTodos) {
      final List<Todo> todos = todoRepository.filterTodos(event.filter);

      yield TodosLoaded(todos: todos, filter: event.filter);
    } else if (event is CreateTodo) {
      yield TodoLoading();

      final List<Todo> todos = await todoRepository.createTodo(
        event.title,
        event.content,
        event.priority,
        event.isDone,
      );

      yield TodosLoaded(todos: todos);
    }
  }
}
