import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: const Text('Write your new note here...'),
    );
  }
}
//Bis hier ist fast alles Standardtext von Flutter (kommt vom StatefulWidget)
//Das einzige was angepasst wurde:
//- Name der Klasse (NewNoteView)
//- Das Scaffold + Hinhalt