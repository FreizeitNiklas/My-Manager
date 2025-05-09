import 'package:flutter/material.dart';
import '../../services/cloud/cloud_note.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);
//tyodef: Weil benutzerdefinierter Funktionstyp
//NC: Name des neuen Typs
//v F(DN n): Spezifiziert die Funktion von DNC
//F(DN n): Beschreibt eine Funktion. Diese erwartet ein Argument vom typ "DN" und trägt den Namen "note"
//-> DNC ist eine neue Funktion, welche ein einzelnes Argument vom typ DN nimmt aber nichts zurückgibt

class NotesListView extends StatelessWidget { //NLV erbt von SW
  final Iterable<CloudNote> notes; //notes ist eine Liste von DN Objekten
  final NoteCallback onDeleteNote; //oDN ist eine Callback Funktion, die aufgerufen wird, wenn eine Notiz gelöscht wird
  final NoteCallback onTap;
  // Weißt der NLV verschiedene Dokumente/Funktionen zu

  const NotesListView({ //In der Klammer: Parameterliste
    Key? key, //key ist eine Klasse um Widgets eindeutig zu identifizieren (ID) / Hilft Flutter bei Geschwindigkeit
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key); //hier wird das key Element übergeben
  //Erstellung einer Instanz von NotesListView mit einem Key und notwenidgen parametern

  @override
  Widget build(BuildContext context) { // "build" beschreibt den Aufbau des Widgets
    return ListView.builder( // Darstellung der Liste
      itemCount: notes.length, // iC: Gibt die anzahl der Elemente in einer Liste an
      itemBuilder: (context, index) { // Verknüft die Funktion mit dem Widget? // Erzeugt Widgets basierend auf der Index-Position
        final note = notes.elementAt(index); // Abrufung von "note"-Objekt basierend auf dem Index
        return ListTile( // LT: Um eine Zeile der Liste darzustellen
          onTap: () {
            onTap(note);
          },
          title: Text( // verknüpfung des Titels (was ich sehe) mit einem Text-Widget
            note.text, // verknüpfung von der Eigenschaft "text" von "DatabaseNote"
            maxLines: 1, // maximal eine Zeile
            softWrap: true, // sorgt für Zeilenumbruch
            overflow: TextOverflow.ellipsis, // Text wird abgeschnitten
          ),
          trailing: IconButton( // Symbol-Schaltfläche am Ende der Zeile
            onPressed: () async { // Asynchrone Funktion bei Druck auf die Schaltfläche
              final shouldDelete = await showDeleteDialog(context); // Dialog anzeigen und Ergebnis abwarten
              if (shouldDelete) { // Falls die Notiz gelöscht werden soll
                onDeleteNote(note); // Lösche die Notiz mittels Callback-Funktion
              }
            },
            icon: const Icon(Icons.delete), // Löschsymbol
          ),
        );
      },
    );
  }
}
