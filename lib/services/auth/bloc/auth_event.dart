import 'package:flutter/cupertino.dart' show  immutable;

@immutable
abstract class AuthEvent { // Basisklasse für alle Authentifizierungs-Ereignisse
  const AuthEvent(); // Konstruktor hilft beim orgnungsgemäßen Initalisieren der Basisiklasse
} // Der Konstruktor der Basisklasse wird immer zuerst ausgeführt wird, bevor der Konstruktor der abgeleiteten Klasse aufgerufen wird.

class AuthEventInitialize extends AuthEvent { // Signalisierung, dass Authentifizierung gestartet werden soll.
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent{
  const AuthEventSendEmailVerification();
}

class AuthEventLogIn extends AuthEvent { // Signalisiert, dass User sich einloggen möchte
  final String email; // Enthält die E-Mail und das Passwort des Benutzers, um die Anmeldedaten zu übergeben
  final String password;
  const AuthEventLogIn(this.email, this. password); } // Konstruktor erhält E-Mail & Passwort und speichert sie in den Instanzvariablen.

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventLogOut extends AuthEvent { // Signalisiert, dass User sich abmelden möchte
  const AuthEventLogOut();
}