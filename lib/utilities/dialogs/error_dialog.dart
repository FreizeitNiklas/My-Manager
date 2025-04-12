import 'package:flutter/cupertino.dart';
import 'package:tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text
) { // Ruft die Funktion "showGenericDialog" auf und gibt ein "Future<void>" zurück
  return showGenericDialog(
    context: context, // Der BuildContext des aktuellen Widgets
    title: 'An error occurred', // Titel des Dialogs
    content: text, // Inhalt des Dialogs, übergeben als text
    optionsBuilder: () => { // Option "OK", die keinen Wert zurückgibt (null)
      'OK' : null,
    },
  );
}
// Es wird ein Fehler angezeigt. Mit drücken von "OK" schließt sich das Fenster.