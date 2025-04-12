import 'package:flutter/cupertino.dart';
import 'package:tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog(
      context: context,
      title: 'Sharing',
      content: 'You cannot share an empty note!',
      optionsBuilder: () => { // Es werden Optionen erzuegt, welche dem Nutzer im Dialogfeld angezeigt werden
        'OK': 'null' // Man kann auf 'OK' klicken, es wird aber nichts passieren
      },
  );
}