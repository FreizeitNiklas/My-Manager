import 'package:flutter/cupertino.dart' show immutable;
import 'package:tutorial_flutter/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable // Die Instanzen der Klasse können nach ihrer Erstellung nicht mehr verändert werden.
abstract class AuthState { // Beschreibt den allgemeinen Zustand der Authentifiezierung.
  // Dient als Basisklasse für verschiedene spezifische Authentifierungszustände.
  const AuthState();
}

// class AuthStateLoading extends AuthState { // Diese Klasse musste ich einführen, um 'Loading' von 'LoggedOut' zu trennen.
//   const AuthStateLoading();
// }c

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception); // Der Konstruktor erwartet ein Argument für das exception Feld und verwendet es,
                                              // um die Instanz zu initialisieren.
}

class AuthStateLoggedIn extends AuthState { // Speichert Informationen über den eingeloggten User (Name & logged in Status).
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState { // User ist angemeldet aber Mail nicht verifiziert.
  const AuthStateNeedsVerification();
}

// User ist ausgelogged
class AuthStateLoggedOut extends AuthState with EquatableMixin { //'EM' ermöglicht Zustandsvergleiche.
  final Exception? exception; // 'Exception?' wird für Null-Sicherheit genutzt.
  // Die Variable 'exception' speichert die Fehlermeldung.
  // Durch 'E?' wird vorgegeben, dass 'e' entweder eine "Exception" oder "null" ist.
  final bool isLoading;
  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading
  });

  @override // Implementierung von 'get props' aus dem 'EquatableMixin'
  List<Object?> get props => [exception, isLoading];
}
// 'props' gibt eine Liste von Eigenschaften (List<Object?>) zurück.
// Diese wird verwendet, um zu bestimmen, ob zwei Instanzen dieser Klasse als gleich angesehen werden.
// exception und isLoading: Diese beiden Felder sind die relevanten Eigenschaften, die zum Vergleich herangezogen werden.
// 'exception' kann als Eigenschaft 'Exception' oder 'null' haben.
// 'isLoading' kann als Eigenschaft 'true' oder 'false' haben.
// Das Vergleichen von Zuständen hilft dabei die Effizienz der App zu verbessern.
// Beispielsweise wird die UI nur noch dann neu geladen, wenn es tatsächlich eine relevante Änderung gibt.