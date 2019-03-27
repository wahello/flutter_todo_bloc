import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo_bloc/.env.dart';
import 'package:flutter_todo_bloc/pages/auth/auth_page.dart';
import 'package:flutter_todo_bloc/pages/todo/todo_list_page.dart';
import 'package:flutter_todo_bloc/pages/settings/settings_page.dart';
import 'package:flutter_todo_bloc/pages/register/register_page.dart';
import 'package:flutter_todo_bloc/pages/splash/splash_page.dart';
import 'package:flutter_todo_bloc/pages/todo/todo_editor_page.dart';
import 'package:flutter_todo_bloc/providers/firebase_provider.dart';
import 'package:flutter_todo_bloc/providers/shared_preferences_provider.dart';
import 'package:flutter_todo_bloc/repositories/user_repository.dart';
import 'package:flutter_todo_bloc/repositories/todo_repository.dart';
import 'package:flutter_todo_bloc/repositories/settings_repository.dart';
import 'package:flutter_todo_bloc/blocs/authentication_bloc.dart';
import 'package:flutter_todo_bloc/blocs/todo_bloc.dart';
import 'package:flutter_todo_bloc/blocs/settings_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Transition transition) {
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();

  final FirebaseProvider firebaseProvider = FirebaseProvider();

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

  final SettingsRepository settingsRepository = SettingsRepository(
    sharedPreferencesProvider: sharedPreferencesProvider,
  );

  runApp(App(
    userRepository: userRepository,
    todoRepository: todoRepository,
    settingsRepository: settingsRepository,
  ));
}

class App extends StatefulWidget {
  final UserRepository userRepository;
  final TodoRepository todoRepository;
  final SettingsRepository settingsRepository;

  App({
    Key key,
    @required this.userRepository,
    @required this.todoRepository,
    @required this.settingsRepository,
  })  : assert(userRepository != null),
        assert(todoRepository != null),
        assert(settingsRepository != null),
        super(key: key);

  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc _authenticationBloc;
  TodoBloc _todoBloc;
  SettingsBloc _settingsBloc;

  UserRepository get userRepository => widget.userRepository;
  TodoRepository get todoRepository => widget.todoRepository;
  SettingsRepository get settingsRepository => widget.settingsRepository;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    _authenticationBloc.dispatch(AppStarted());

    _todoBloc = TodoBloc(todoRepository: todoRepository);

    _settingsBloc = SettingsBloc(settingsRepository: settingsRepository);
    _settingsBloc.dispatch(LoadSettings());
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
          BlocProvider<SettingsBloc>(bloc: _settingsBloc),
        ],
        child: BlocBuilder<SettingsEvent, SettingsState>(
          bloc: _settingsBloc,
          builder: (BuildContext context, SettingsState state) {
            bool useDarkTheme = false;

            if (state is SettingsLoaded) {
              useDarkTheme = state.settings.isDarkThemeUsed;
            }

            return MaterialApp(
              title: Configure.AppName,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                accentColor: Colors.blue,
                primaryColor: Colors.blue,
                brightness: useDarkTheme ? Brightness.dark : Brightness.light,
              ),
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
              routes: {
                '/settings': (BuildContext context) => SettingsPage(),
                '/register': (BuildContext context) => RegisterPage(
                      userRepository: userRepository,
                    ),
              },
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
            );
          },
        ));
  }
}
