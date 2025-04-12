import 'package:flutter/cupertino.dart' show immutable;

typedef CloseLoadingScreen = bool Function(); // Erwartet keinen Eingabewert.
typedef UpdateLoadingScreen = bool Function (String text); // Erwartet einen String als Eingabewert.

@immutable
class LoadingScreenController { // Controller verwaltet zwei Funktionen: schließen und aktualisieren.
  final CloseLoadingScreen close; // Implementieren der Logik zum Schließen über 'close'.
  final UpdateLoadingScreen update; // Implementieren der Logik zum aktualisieren über 'update'.

  const LoadingScreenController({ // Der Konstruktor nimmt zwei Parameter entgegen: 'close' und 'update'.
    required this.close,
    required this.update,
  });
}