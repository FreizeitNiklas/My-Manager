import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_flutter/services/crud/notes_service.dart';
import 'package:tutorial_flutter/utilities/generics/get_arguments.dart';
import '../../services/auth/auth_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteView();
}

class _CreateUpdateNoteView extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  //Die Variable "_note" (vom Typ "DatabaseNote") sorgt dafür, dass die Notiz in der "NewNoteView" gespeichert wird
  late final NotesService _notesService;
  late final TextEditingController _textController; //"TextEditingController" steuert den Text der in einem Feld angezeigt wird

  @override
  void initState() { //"initState" inzitalisiert notwendige Abhängigkeiten, bevor das Widget verwendet wird
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState(); //Sicherstellung, dass alles intialisiert wurde (Standard-Code von Flutter)
  }

  void _textControllerListener() async { //Es soll beim "tippen" die ganze Zeit Updates an die Database geben
    final note = _note;
    if (note == null) { //wenn es keine Notiz gibt, soll die Methode vorzeitig beendet werden
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
        note: note,
        text: text,
    );
  }
//Jedes Mal, wenn der Benutzer eine Änderung vornimmt, wird die Methode aufgerufen und aktualisiert die Notiz in der Datenbank

  void _setupTextControllerListener() { //sorgt dafür, dass der "_textControllerListener" korrekt an den "_textController" angehängt wird
    _textController.removeListener(_textControllerListener); //zuerst den Listener entfernen
    _textController.addListener(_textControllerListener); //dann wieder hinzufügen
  } //so können niemals zwei Listener gleichzeitig laufen

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {

    final widgetNote = context.getArgument<DatabaseNote>();
    // Versucht, ein Argument vom Typ DatabaseNote aus dem Kontext abzurufen.
    // Wird das hier verwendet, um zu überprüfen ob schon eine existierende Notiz da ist?

    if (widgetNote != null) { // Überprüft, ob widgetNote nicht null ist, was bedeutet, dass eine existierende Notiz gefunden wurde.
      _note = widgetNote; // Übergibt die gefundene Notiz an eine private Variable "_note"
      _textController.text = widgetNote.text; // Setzt den Text im Text-Controller auf den Text der gefundenen Notiz
      return widgetNote; // Gibt die existierende Notiz zurück.
    }

    final existingNote = _note; //Weist die bestehende Notiz (falls vorhanden) der lokalen Variable "existingNote" zu
    if (existingNote != null) { //und auch nicht "null" ist
      return existingNote; //Dann gib die bestehende Notiz zurück
    }
    final currentUser = AuthService.firebase().currentUser!; //Holt den aktuellen Benutzer vom AuthService
    final email = currentUser.email; //Holt die E-Mail-Adresse des aktuellen Benutzers
    final owner = await _notesService.getUser(email: email!); //Ruft den Benutzer mit der angegebenen E-Mail-Adresse vom NotesService ab.
    final newNote = await _notesService.createNote(owner: owner); //Erstellt eine neue Notiz für den Benutzer und gibt diese zurück
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note; //Weist "_note" "note" zu
    if (_textController.text.isEmpty && note != null){ //wenn der Text leer ist und ("&&") nicht "null" ist
      _notesService.deleteNote(id: note.id); //dann lösch die Notiz anhand ihrer id
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
          note: note,
          text: text,
      );
    }
  }

  @override
  void dispose() { //"dispose" wird genutzt um den State eines Widgets zu entfernen / die Ressourcen werden freigegeben
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose(); //Controller müssen immer mit ".dispose" aufgerufen werden! /das ist eine eigene Methode des Controllers
    super.dispose(); //Prüfung, dass alles freigegeben/gelöscht ist (Standardtext von Flutter)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) { //prüft die aktuelle ("snapchot") Verbindung
            case ConnectionState.done: //Dieser Fall tritt ein, wenn das Future abgeschlossen ist und ein Ergebnis zurückgegeben hat
              _setupTextControllerListener(); //Diese Methode wird aufgerufen, um einen Listener auf "_textController" zu setzen
              return TextField(
                controller: _textController, //nutzt den "_textController" als Steuerung um den Textinhalt zu verwalten
                keyboardType: TextInputType.multiline, //Textfeld kann mehrzeilig sein
                maxLines: null, //unbegrenzt viele Zeilen
                decoration: const InputDecoration( //"InputDecoration" wird verwendet um Eigabefelder anzupassen
                  hintText: 'Start typing your note...',
                ),
              );
            default: //Dieser Fall wird erreicht, wenn das Future noch nicht abgeschlossen ist
              return const CircularProgressIndicator(); //In diesem Fall wird ein "CircularProgressIndicator" angezeigt
          }
        },
      ),
    );
  }
}