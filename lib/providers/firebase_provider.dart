import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/models/priority.dart';
import 'package:flutter_todo_bloc/models/todo.dart';
import 'package:flutter_todo_bloc/models/user.dart';
import 'package:flutter_todo_bloc/widgets/helpers/priority_helper.dart';

class FirebaseProvider {
  final http.Client client;

  FirebaseProvider({@required this.client}) : assert(client != null);

  Future<User> authenticate(
    String email,
    String password,
  ) async {
    final Map<String, dynamic> formData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    final http.Response response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${Configure.ApiKey}',
      body: json.encode(formData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData.containsKey('idToken')) {
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final User user = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken'],
          refreshToken: responseData['refreshToken'],
          expiryTime: expiryTime.toIso8601String());

      return user;
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      throw Exception('Email is not found.');
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      throw Exception('Password is invalid.');
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      throw Exception('The user account has been disabled.');
    }

    throw Exception('Unknown error.');
  }

  Future<List<Todo>> fetchTodos(User user) async {
    final http.Response response = await http.get(
        '${Configure.FirebaseUrl}/todos.json?auth=${user.token}&orderBy="userId"&equalTo="${user.id}"');

    if (response.statusCode != 200 && response.statusCode != 201) {
      // if (response.statusCode == 401) {
      // TODO: Handle refresh token
      // }

      throw Exception('Response status code: ${response.statusCode}');
    }

    final Map<String, dynamic> todoListData = json.decode(response.body);
    final List<Todo> todos = [];

    if (todoListData != null) {
      todoListData.forEach((String todoId, dynamic todoData) {
        final Todo todo = Todo(
          id: todoId,
          title: todoData['title'],
          content: todoData['content'],
          priority: PriorityHelper.toPriority(todoData['priority']),
          isDone: todoData['isDone'],
          userId: user.id,
        );

        todos.add(todo);
      });
    }

    return todos;
  }

  Future<Todo> createTodo(
    User user,
    String title,
    String content,
    Priority priority,
    bool isDone,
  ) async {
    final Map<String, dynamic> formData = {
      'title': title,
      'content': content,
      'priority': priority.toString(),
      'isDone': isDone,
      'userId': user.id,
    };

    final http.Response response = await http.post(
      '${Configure.FirebaseUrl}/todos.json?auth=${user.token}',
      body: json.encode(formData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // if (response.statusCode == 401) {
      // TODO: Handle refresh token
      // }

      throw Exception('Response status code: ${response.statusCode}');
    }

    final Map<String, dynamic> responseData = json.decode(response.body);

    Todo todo = Todo(
      id: responseData['name'],
      title: title,
      content: content,
      priority: priority,
      isDone: isDone,
      userId: user.id,
    );

    return todo;
  }

  Future updateTodo(
    User user,
    String id,
    String title,
    String content,
    Priority priority,
    bool isDone,
  ) async {
    final Map<String, dynamic> formData = {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority.toString(),
      'isDone': isDone,
      'userId': user.id,
    };

    final http.Response response = await http.put(
      '${Configure.FirebaseUrl}/todos/$id.json?auth=${user.token}',
      body: json.encode(formData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // if (response.statusCode == 401) {
      // TODO: Handle refresh token
      // }

      throw Exception('Response status code: ${response.statusCode}');
    }

    Todo todo = Todo(
      id: id,
      title: title,
      content: content,
      priority: priority,
      isDone: isDone,
      userId: user.id,
    );

    return todo;
  }
}
