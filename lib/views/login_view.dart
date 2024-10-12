import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_state.dart';
import 'package:tutorial_flutter/utilities/dialogs/loading_dialog.dart';
import '../utilities/dialogs/error_dialog.dart';
import 'package:tutorial_flutter/services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
} // createState(): Diese Methode gibt die zugehörige Zustandsklasse (_LoginViewState) zurück, die die Logik für das Widget enthält.

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email; // controller für die Texteingabe
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;
//  Diese Variable speichert eine Funktion, um den Lade-Dialog zu schließen.
//  Sie ist optional (?), da der Dialog möglicherweise nicht geöffnet ist.

  @override // Hier überschreibst du die Methode 'initState', die aufgerufen wird, wenn der Zustand des Widgets erstellt wird.
  void initState() {
    _email = TextEditingController(); // Initialisierung der Controller
    _password = TextEditingController();
    super.initState();
  }

  @override // Hier überschreibst du die Methode 'dispose', die aufgerufen wird, wenn der Zustand des Widgets entfernt wird.
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override // Hier überschreibst du die Methode build, die für den Aufbau des Benutzeroberflächen-Widgets verantwortlich ist.
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>( // Listener reagiert auf 'AuthState' Änderung, welche vom 'AuthBloc' kommen.
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) { //Sollte dem nicht so sein, dann passiert nichts.
          if (state.exception is UserNotFoundAuthException) { // Überprüft, ob der Grund für den Logout ist, dass ein Benutzer nicht gefunden wurde.
            final closeDialog = _closeDialogHandle; // Speichert die aktuelle Funktion zum Schließen des Lade-Dialogs.
            if(!state.isLoading && closeDialog != null) { // Wenn keine Aktion geladen wird und der Dialog geöffnet ist,
              closeDialog(); // wird der Dialog geschlossen
              _closeDialogHandle = null; // und die Handhabung des Dialogs auf null gesetzt.
            } else if (state.isLoading && closeDialog == null) { // Wenn eine Aktion gerade geladen wird und kein Dialog offen ist,
              _closeDialogHandle = showLoadingDialog( // wird ein neuer Lade-Dialog angezeigt.
                  context: context,
                  text: 'Loading...',
              );
            } // Das Pop-Up kommt nicht. Hatte versucht es zu fixen aber dann ging die App nicht mehr...
            await showErrorDialog(context, 'User not found');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
  // @override
  // Widget build(BuildContext context) {
  //   return BlocListener<AuthBloc, AuthState>(
  //     listener: (context, state) async {
  //       // Debug: Zustand anzeigen
  //       print('Aktueller Zustand: $state');  // Ausgabe des aktuellen Zustands
  //       // Schließen des Loading-Dialogs, wenn der Zustand nicht AuthStateLoading ist
  //       if (state is! AuthStateLoading && _closeDialogHandle != null) {
  //         _closeDialogHandle?.call(); // Schließen des Dialogs
  //         _closeDialogHandle = null;  // Reset des Handles
  //       }
  //









  //       // Öffnen des Loading-Dialogs, wenn der Zustand AuthStateLoading ist
  //       if (state is AuthStateLoading && _closeDialogHandle == null) {
  //         _closeDialogHandle = showLoadingDialog(
  //           context: context,
  //           text: 'Loading...', // Text des Lade-Dialogs
  //         );
  //       }
  //
  //       // Fehlerbehandlung, wenn der Benutzer ausgeloggt ist
  //       if (state is AuthStateLoggedOut) {
  //         if (state.exception is UserNotFoundAuthException) {
  //           await showErrorDialog(context, 'User not found');
  //         } else if (state.exception is WrongPasswordAuthException) {
  //           await showErrorDialog(context, 'Wrong credentials');
  //         } else if (state.exception is GenericAuthException) {
  //           await showErrorDialog(context, 'Authentication error');
  //         }
  //       }
  //     },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false, // Dies deaktiviert die Vorschläge, die normalerweise beim Eingeben von Text angezeigt werden, um die Eingabe zu erleichtern.
              autocorrect: false, // Diese Einstellung deaktiviert die automatische Korrektur der Eingabe im Textfeld.
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  hintText: 'Enter your E-Mail here',
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true, // sorgt dafür, dass der eingegeben Text nicht sichtbar ist.
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                  hintText: 'Enter your Password here',
              ),
            ),
            TextButton(
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
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add( // suchen nach 'AuthBloc' in 'context'.
                  const AuthEventShouldRegister(), //'.add(c AESR)' -> Sende das "Event" 'AESR'.
                );
              },
              child: Text('Not registered yet? Register here!'),
            )
          ],
        ),
      ),
    );
  }
}