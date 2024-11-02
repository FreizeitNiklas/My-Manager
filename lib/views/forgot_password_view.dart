import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_state.dart';
import 'package:tutorial_flutter/utilities/dialogs/error_dialog.dart';
import 'package:tutorial_flutter/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key); // Konstruktor, der das `key`-Argument an den `super`-Konstruktor übergibt.

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState(); // Erzeugt das State-Objekt für die Ansicht
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  // Ein `TextEditingController`, der den Text des Eingabefelds verwaltet
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(); // Initialisiert den Controller
    super.initState(); // Ruft den `initState` der übergeordneten Klasse auf
  }

  @override
  void dispose() { // Gibt die Ressourcen wieder frei
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>( // Hört auf Änderungen im `AuthBloc`-State
    listener: (context, state) async {
      // Überprüft, ob der aktuelle Zustand `AuthStateForgotPassword` ist
        if (state is AuthStateForgotPassword) {
          _controller.clear(); // Leert das Eingabefeld
          await showPasswordResetSentDialog(context); // Zeigt ein Dialogfenster an, um zu bestätigen, dass eine E-Mail gesendet wurde
        }
        if (state.exception != null) { // Wegen 'exception' musste ich bei "auth_state" die Error-Bekämpfung machen.
          // Was ist hier die richtige Lösung? Ich bekomm dauerhaft jetzt das Pop-Up (dabei hatte ich State gleich 'null' gesetzt?)
          // Zeigt einen Fehlerdialog an, wenn eine Exception vorhanden ist
          await showErrorDialog(context,
              'We could not process your request. Please make sure that you are a registered user, of if not, register a user now by going back one step.');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                  'If you forgot your password, simply enter your email and we will send you a password reset link.'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true, // Öffnen die Tastatur direkt für das Textfeld (Ich hab nur den Courser - aber keine Tastatur)
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Your email address....',
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: const Text('Send me password reset link'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text('Back to login page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
