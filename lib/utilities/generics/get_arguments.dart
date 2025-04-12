import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext { // Erstellt eine Erweiterungsmethode für die BuildContext-Klasse
  T? getArgument<T>() { // Definiert eine Methode "getArgument", die ein optionales Argument vom Typ T zurückgibt
    final modalRoute = ModalRoute.of(this);
    // mR: Ist eine neu erstelle Variable
    // MR: Ist eine Klasse in Flutter, die eine Route beschreibt, die einen Dialog (wie einen Bildschirm oder ein Pop-up) darstellt.
    // ".of(this)" ist eine Methode von MR. Diese Methode wird verwendet, um die MR, die den angegebenen BuildContext umschließt, abzurufen.
    // "this" bezieht sich auf die aktuelle Instanz der Klasse, die die Methode "getArgument" enthält.
    // Da diese Methode eine Erweiterungsmethode für "BuildContext" ist,
    // wird "this" als der aktuelle BuildContext interpretiert, in dem die Methode aufgerufen wird.
    // Hier werden Daten zwischen verschiedenen Bildschirmen übertragen
    // Die Zeile hat die Funktion, die aktuelle MR-Instanz, die den gegebenen BuildContext ("this") umgibt,
    // abzurufen und in der Variablen "modalRoute" zu speichern.
    if (modalRoute != null) { // Überprüft, ob die ModalRoute nicht null ist.
      final args = modalRoute.settings.arguments; // Holt die Argumente aus den Einstellungen der "ModalRoute"
      if (args != null && args is T) { // Überprüft, ob die Argumente nicht null sind und ob sie vom Typ T sind.
        return args as T; // Gibt die Argumente als Typ T zurück
      }
    }
    return null;  // Gibt null zurück, wenn keine Argumente gefunden wurden oder sie nicht vom Typ T sind
  }
}