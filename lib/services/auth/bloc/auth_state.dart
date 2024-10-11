import 'package:flutter/cupertino.dart' show immutable;
import 'package:tutorial_flutter/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable // Die Instanzen der Klasse können nach ihrer Erstellung nicht mehr verändert werden
abstract class AuthState { // beschreibt den allgemeinen Zustand der Authentifiezierung
  // Dient als Basisklasse für verschiedene spezifische Authentifierungszustände
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

class AuthStateLoggedIn extends AuthState { // Speichert Informationen über den eingeloggten User (Name & logged in Status)
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState { // User ist angemeldet aber Mail nicht verifiziert
  const AuthStateNeedsVerification();
}

// User ist ausgelogged
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception; // 'Exception?' wird für Null-Sicherheit genutzt
  // Die Variable 'exception' speichert die Fehlermeldung
  // Durch 'E?' wird vorgeben, dass 'e' entweder eine "Exception" oder "null" ist
  final bool isLoading;
  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading
  });

  @override
  List<Object?> get props => [exception, isLoading];
}