import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_todo_bloc/pages/auth/auth_page.dart';
import 'package:flutter_todo_bloc/pages/todo/todo_list_page.dart';
import 'package:flutter_todo_bloc/pages/splash/splash_page.dart';
import 'package:flutter_todo_bloc/pages/todo/todo_editor_page.dart';
import 'package:flutter_todo_bloc/providers/firebase_provider.dart';
import 'package:flutter_todo_bloc/providers/shared_preferences_provider.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';
import 'package:flutter_todo_bloc/repositories/todo_repository.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Transition transition) {
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();

  final FirebaseProvider firebaseProvider = FirebaseProvider(
    client: http.Client(),
  );

  final SharedPreferencesProvider sharedPreferencesProvider =
      SharedPreferencesProvider();

  final UserRepository userRepository = UserRepository(
    firebaseProvider: firebaseProvider,
    sharedPreferencesProvider: sharedPreferencesProvider,
  );

  final TodoRepository todoRepository = TodoRepository(
    firebaseProvider: firebaseProvider,
    userRepository: userRepository,
  );

  runApp(App(
    userRepository: userRepository,
    todoRepository: todoRepository,
  ));
}

class App extends StatefulWidget {
  final UserRepository userRepository;
  final TodoRepository todoRepository;

  App({
    Key key,
    @required this.userRepository,
    @required this.todoRepository,
  })  : assert(userRepository != null),
        assert(todoRepository != null),
        super(key: key);

  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc _authenticationBloc;
  TodoBloc _todoBloc;
  UserRepository get userRepository => widget.userRepository;
  TodoRepository get todoRepository => widget.todoRepository;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    _authenticationBloc.dispatch(AppStarted());

    _todoBloc = TodoBloc(todoRepository: todoRepository);
  }

  @override
  void dispose() {
    _todoBloc.dispose();
    _authenticationBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<AuthenticationBloc>(bloc: _authenticationBloc),
        BlocProvider<TodoBloc>(bloc: _todoBloc),
      ],
      child: MaterialApp(
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }

            if (state is AuthenticationAuthenticated) {
              return TodoListPage();
            }

            if (state is AuthenticationUnauthenticated) {
              return AuthPage(userRepository: userRepository);
            }
          },
        ),
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');

          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'editor') {
            final String todoId =
                pathElements.length >= 3 ? pathElements[2] : null;
            final String priority =
                pathElements.length == 4 ? pathElements[3] : null;

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => TodoEditorPage(
                    todoId: todoId,
                    priority: priority,
                  ),
            );
          }

          return null;
        },
      ),
    );
  }
}
