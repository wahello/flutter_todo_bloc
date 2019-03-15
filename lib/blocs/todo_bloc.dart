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

class TodoInitialized extends TodoEvent {}

class UpdateTodo extends TodoEvent {
  final String id;
  final String title;
  final String content;
  final Priority priority;
  final bool isDone;

  UpdateTodo({
    @required this.id,
    @required this.title,
    this.content,
    this.priority = Priority.Low,
    this.isDone = false,
  }) : super([id, title, content, priority, isDone]);
}

class DeleteTodo extends TodoEvent {
  final String id;

  DeleteTodo({
    @required this.id,
  }) : super([id]);
}
// #endregion

// #region States
abstract class TodoState extends Equatable {
  TodoState([List props = const []]) : super(props);
}

class TodosInitial extends TodoState {}

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

class TodosError extends TodoState {
  final String error;

  TodosError({
    @required this.error,
  })  : assert(error != null),
        super([error]);

  @override
  String toString() => 'TodosError {error: $error}';
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

class TodoInitial extends TodoState {}

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

// #region Bloc
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({
    @required this.todoRepository,
  }) : assert(todoRepository != null);

  @override
  TodoState get initialState => TodosInitial();

  @override
  Stream<TodoState> mapEventToState(
    TodoState currentState,
    TodoEvent event,
  ) async* {
    if (event is TodoInitialized) {
      yield TodoInitial();
    } else if (event is FetchTodos) {
      yield* _mapFetchTodosToState();
    } else if (event is FetchTodo) {
      yield* _mapFetchTodoToState(event);
    } else if (event is FilterTodos) {
      yield* _mapFilterTodosToState(event);
    } else if (event is CreateTodo) {
      yield* _mapCreateTodoToState(event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodoToState(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(event);
    }
  }

  Stream<TodoState> _mapFetchTodosToState() async* {
    yield TodosLoading();

    try {
      final List<Todo> todos = await todoRepository.fetchTodos();

      yield TodosLoaded(todos: todos);
    } catch (error) {
      yield TodosError(error: error.toString());
    }
  }

  Stream<TodoState> _mapFetchTodoToState(FetchTodo event) async* {
    yield TodoLoading();

    try {
      final Todo todo = todoRepository.fetchTodo(event.id);

      yield TodoLoaded(todo: todo);
    } catch (error) {
      yield TodoError(error: error.toString());
    }
  }

  Stream<TodoState> _mapFilterTodosToState(FilterTodos event) async* {
    final List<Todo> todos = todoRepository.filterTodos(event.filter);

    yield TodosLoaded(
      todos: todos,
      filter: event.filter,
    );
  }

  Stream<TodoState> _mapCreateTodoToState(CreateTodo event) async* {
    yield TodoLoading();

    try {
      final List<Todo> todos = await todoRepository.createTodo(
        event.title,
        event.content,
        event.priority,
        event.isDone,
      );

      yield TodosLoaded(
        todos: todos,
        filter: todoRepository.filter,
      );
    } catch (error) {
      yield TodoError(error: error.toString());
    }
  }

  Stream<TodoState> _mapUpdateTodoToState(UpdateTodo event) async* {
    yield TodoLoading();

    try {
      final List<Todo> todos = await todoRepository.updateTodo(
        event.id,
        event.title,
        event.content,
        event.priority,
        event.isDone,
      );

      yield TodosLoaded(
        todos: todos,
        filter: todoRepository.filter,
      );
    } catch (error) {
      yield TodoError(error: error.toString());
    }
  }

  Stream<TodoState> _mapDeleteTodoToState(DeleteTodo event) async* {
    yield TodosLoading();

    try {
      final List<Todo> todos = await todoRepository.deleteTodo(event.id);

      yield TodosLoaded(
        todos: todos,
        filter: todoRepository.filter,
      );

      todoRepository.removeTodoFromFirebase(event.id);
    } catch (error) {
      yield TodoError(error: error.toString());
    }
  }
}

// #endregion
