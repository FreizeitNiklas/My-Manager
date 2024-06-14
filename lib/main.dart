import 'package:flutter/material.dart';
import 'package:tutorial_flutter/views/login_view.dart';
import 'package:tutorial_flutter/views/notes_view.dart';
import 'package:tutorial_flutter/views/register_view.dart';
import 'package:tutorial_flutter/views/verify_email_view.dart';
import 'constants/routes.dart';
import 'package:tutorial_flutter/services/auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.done: //if Connection is done -> Return Text "Done" (Row 44) otherwise return Row 46
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
            } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}