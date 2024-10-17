import 'package:flutter/cupertino.dart' show immutable;
import 'package:tutorial_flutter/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable // Die Instanzen der Klasse können nach ihrer Erstellung nicht mehr verändert werden.
abstract class AuthState { // Beschreibt den allgemeinen Zustand der Authentifiezierung.
  // Dient als Basisklasse für verschiedene spezifische Authentifierungszustände.
  // Sie stellt allgemeine Eigenschaften wie `isLoading` und `loadingText` bereit, die in allen Zuständen nützlich sind.
  final bool isLoading; // Zeigt an, ob gerade eine Operation (wie Einloggen oder Registrieren) läuft.
  final String? loadingText; // Optionaler Text, der während einer Ladeoperation angezeigt wird.
  // Konstruktor der AuthState-Klasse. `isLoading` muss übergeben werden, `loadingText` hat einen Standardwert.
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wat a moment',
  });
}

// 'AuthStateUninitialized' ist ein Zustand, der verwendet wird, wenn die Authentifizierung noch nicht initialisiert wurde.
class AuthStateUninitialized extends AuthState {
  // Dieser Zustand zeigt an, dass die Authentifizierung noch nicht gestartet wurde.
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading); // Der isLoading-Wert wird an die Basisklasse übergeben.
}

// AuthStateRegistering ist ein Zustand, der verwendet wird, wenn ein Benutzer sich gerade registriert.
class AuthStateRegistering extends AuthState {
  final Exception? exception; // Speichert mögliche Fehler, die während der Registrierung auftreten können.
  // Konstruktor für den Zustand während der Registrierung.
  // `exception` kann `null` sein, wenn kein Fehler aufgetreten ist.
  const AuthStateRegistering({
    required this.exception, // Die Ausnahme, falls ein Fehler während der Registrierung auftritt.
    required isLoading, // Ob der Registrierungsvorgang gerade läuft.
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedIn extends AuthState { // Speichert Informationen über den eingeloggten User (Name & logged in Status).
  final AuthUser user;
  const AuthStateLoggedIn({
    required this.user, // Die Instanz des eingeloggt Benutzers.
    required bool isLoading, // Ob gerade eine Operation läuft (wird im Allgemeinen `false` sein, wenn eingeloggt).
  }) : super(isLoading: isLoading);
}


// 'AuthStateNeedsVerification' ist ein Zustand, der verwendet wird, wenn der Benutzer eingeloggt ist,
// aber die E-Mail noch nicht verifiziert wurde.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required  bool isLoading})
      : super(isLoading: isLoading);
}

// User ist ausgelogged
class AuthStateLoggedOut extends AuthState with EquatableMixin { //'EM' ermöglicht Zustandsvergleiche.
  final Exception? exception; // 'Exception?' wird für Null-Sicherheit genutzt.
  // Die Variable 'exception' speichert die Fehlermeldung.
  // Durch 'E?' wird vorgegeben, dass 'e' entweder eine "Exception" oder "null" ist.

  // Konstruktor für den Zustand, in dem der Benutzer ausgeloggt ist.
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override // Implementierung von 'get props' aus dem 'EquatableMixin'
  List<Object?> get props => [exception, isLoading];
}
// 'props' gibt eine Liste von Eigenschaften (List<Object?>) zurück.
// Diese wird verwendet, um zu bestimmen, ob zwei Instanzen dieser Klasse als gleich angesehen werden.
// exception und isLoading: Diese beiden Felder sind die relevanten Eigenschaften, die zum Vergleich der Instanzen herangezogen werden.
// 'exception' kann als Eigenschaft 'Exception' oder 'null' haben.
// 'isLoading' kann als Eigenschaft 'true' oder 'false' haben.
// Das Vergleichen von Zuständen hilft dabei die Effizienz der App zu verbessern.
// Beispielsweise wird die UI nur noch dann neu geladen, wenn es tatsächlich eine relevante Änderung gibt.