import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_flutter/constants/routes.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';
import 'package:tutorial_flutter/services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: 'Enter your E-Mail here'
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: 'Enter your Password here'
            ),
          ),
          BlocListener<AuthBloc, AuthState>( // wraped with BlocListener // Wieso AuthBloc anstatt AuthEvent?
            listener: (context, state) async { //Wenn wir den Zustand "Ausgelogged" haben, dann prüft der Listener ob eine Fehlermeldung vorliegt.
              if (state is AuthStateLoggedOut) { //Sollte dem nicht so sein, dann passiert nichts.
                if (state.exception is UserNotFoundAuthException) {
                  await showErrorDialog(context, 'User not found');
                } else if (state.exception is WrongPasswordAuthException) {
                  await showErrorDialog(context, 'Wrong credentials');
                } else if (state.exception is GenericAuthException) {
                  await showErrorDialog(context, 'Authentication error');
                }
              }
            },
            child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                  AuthEventLogIn(
                    email,
                    password,
                  ),
                );
              },
              child: const Text ('Login'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                    (route) => false,
              );
            },
            child: Text('Not registered yet? Register here!'),
          )
        ],
      ),
    );
  }
}