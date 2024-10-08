import 'package:flutter/cupertino.dart' show immutable;
import 'package:tutorial_flutter/services/auth/auth_user.dart';

@immutable // Die Instanzen der Klasse können nach ihrer Erstellung nicht mehr verändert werden
abstract class AuthState { // beschreibt den allgemeinen Zustand der Authentifiezierung
  // Dient als Basisklasse für verschiedene spezifische Authentifierungszustände
  const AuthState();
}

class AuthStateLoading extends AuthState { // Authentifizierung lädt im Hintergrund
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState { // Speichert Informationen über den eingeloggten User (Name & logged in Status)
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateLoginFailure extends AuthState { // Speichert den Fehler, der während des Anmeldeversuchs aufgetreten ist
  final Exception exception;
  const AuthStateLoginFailure(this.exception);
}

class AuthStateNeedsVerification extends AuthState { // User ist angemeldet aber Mail nicht verifiziert
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState { // User ist ausgelogged
  const AuthStateLoggedOut();
}

class AuthStateLogoutFailure extends AuthState { // Wenn ein Fehler während des ausloggens auftritt
  final Exception exception; // speichert den Fehler
  const AuthStateLogoutFailure(this.exception);
}