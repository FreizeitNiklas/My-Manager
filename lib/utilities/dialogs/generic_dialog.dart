import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();
// Definiert einen Typalias für eine Funktion, die eine Map von String-Schlüsseln zu optionalen Werten vom Typ T zurückgibt.

Future<T?> showGenericDialog<T>({
  required BuildContext context, // Der Kontext des aktuellen Widgets
  required String title, // Der Titel des Dialogs
  required String content, // Der Inhalt des Dialogs
  required DialogOptionBuilder optionsBuilder, // Eine Funktion, die die Optionen für den Dialog erstellt
}) {
  final options = optionsBuilder(); // Ruft die Optionen ab, indem die optionsBuilder-Funktion aufgerufen wird
  return showDialog<T>( // Zeigt einen Dialog an und gibt ein Future zurück, das den ausgewählten Wert enthält
   context: context,
   builder: (context) {
     return AlertDialog(
       title: Text(title), // Setzt den Titel des Dialogs
       content: Text(content), // Setzt den Inhalt des Dialogs
       actions: options.keys.map((optionTitle) { // Erstellt eine Schaltfläche für jede Option
         // Erstellung Schaltfläche (maps) welche verknüpft sind mit "keys" und so Aktionen ausführen
         final T value = options[optionTitle]; // Ruft den Wert der aktuellen Option ab und übergibt ihn an "T"
         return TextButton(
             onPressed: () {
               if (value != null) {
                 Navigator.of(context).pop(value); // Schließt den Dialog und gibt den Wert zurück
               } else {
                 Navigator.of(context).pop(); // Schließt den Dialog ohne Wert
               }
             },
             child: Text(optionTitle), // Setzt den Text der Schaltfläche
         );
       }).toList(),
     );
   },
  );
}
// Die Funktion showGenericDialog zeigt einen generischen Dialog an,
// der eine Titelzeile, einen Inhaltsbereich und eine Reihe von Schaltflächen hat.
// Die Schaltflächen und ihre Rückgabewerte werden durch eine Funktion (DialogOptionBuilder) definiert,
// die eine Map von Schaltflächenbeschriftungen zu Werten zurückgibt.
// Wenn eine Schaltfläche gedrückt wird, schließt der Dialog und gibt den zugehörigen Wert zurück.
// Wenn der Wert null ist, wird der Dialog einfach geschlossen, ohne einen Wert zurückzugeben.