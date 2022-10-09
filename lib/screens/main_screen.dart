import 'package:flutter/material.dart';

import 'startup_screen.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const StartupScreen(),
      /*
      initialRoute: StartupScreen.route,
      routes: {
        StartupScreen.route: (context) => const StartupScreen(),
        CreateAccountScreen.route: (context) => const CreateAccountScreen(),
        LoginUserScreen.route: (context) => const LoginUserScreen(),
        CreateProjectScreen.route: (context) => const CreateProjectScreen(),
        TodoListScreen.route: (context) => const TodoListScreen(),
        // CreateTodoItemScreen.route: (context) => const CreateTodoItemScreen(),
        OpenProjectScreen.route: (context) => const OpenProjectScreen(),
      },
      */
    );
  }
}
