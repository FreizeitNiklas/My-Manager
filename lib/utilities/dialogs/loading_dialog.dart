import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({ // Rückgabewert: 'CD'
  required BuildContext context, // 'context' wird benötigt um den Dialog im richtigen Umfeld anzuzeigen.
  required String text,
}) {
  final dialog = AlertDialog( // weist dem 'dialog' einen neuen 'AlertDialog' zu
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );
  // 'showLoadingDialog' kann nicht wissen wann das Laden abgeschlossen ist.
  // Daher muss es eine Möglichkeit geben, das Pup-Up zu einem späteren Zeitpunkt zu schließen.

  showDialog( // Hier wird der eigentliche Dialog angezeigt.
    context: context, // Der Kontext wird benötigt, um den Dialog im richtigen Widget-Baum zu platzieren.
    barrierDismissible: false, // Festlegung, dass der Dialog nicht durch Tippen außerhalb des Dialogs geschlossen werden kann.
    builder: (context) => dialog, // Hier wird der Dialog erstellt, den wir oben definiert haben (mit 'Column')
  );

  return () => Navigator.of(context).pop();
}
// 'Navigator.of(context).pop()': Dies verwendet den 'Navigator_, um den aktuellen Dialog zu schließen.
// 'pop()' entfernt das oberste Widget (in diesem Fall den Dialog) vom Stack des 'Navigators'.