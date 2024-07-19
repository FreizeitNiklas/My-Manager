import 'package:flutter/material.dart';
import 'package:tutorial_flutter/services/auth/auth_service.dart';
import 'package:tutorial_flutter/services/crud/notes_service.dart';
import 'package:tutorial_flutter/views/notes/notes_list_view.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key}); //Sicherstellung, dass der "key" richtig übergeben wird / aber was ist der "key"?

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService; //"late" bedeutet es wird erst initialisiert, sobald verwendet wird
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() { //"initState" wird einmalig aufgerufen, wenn das StatefulWidget zum ersten Mal eingefügt wird. Hier werden alle Initialisierungen vorgenommen, die nur einmal durchgeführt werden müssen.
    _notesService = NotesService();
    super.initState(); //Wird genutzt um sicherzustellen, dass die Initialisierungen der Basisklasse abgeschlossen sind (bewährte Methode), bevor die abgeleitete Klasse initialisiert
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text ('Your Notes'),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.of(context).pushNamed(newNoteRoute); //Navigiert zu "newNoteRoute"
              },
              icon: const Icon(Icons.add)), //Ein "add"-Icon
          PopupMenuButton<MenuAction>(
            onSelected: (value) async { //Ein Callback, der aufgerufen wird, wenn eine Menüoption ausgewählt wird.
              switch (value) { //Ein Switch-Statement, das den ausgewählten Menüwert verarbeitet.
                case MenuAction.logout: //Wenn die Abmeldeoption (logout) ausgewählt wird, wird der folgende Code ausgeführt:
                  final shouldLogout = await showLogOutDialog(context); //Zeigt ein Dialogfeld an, das den Benutzer fragt, ob er sich abmelden möchte.
                  if (shouldLogout) { //Wenn der Benutzer die Abmeldung bestätigt (shouldLogout ist true), wird der folgende Code ausgeführt:
                    await AuthService.firebase().logout(); //Ruft die Abmeldefunktion des AuthService auf, um den Benutzer abzumelden.
                    Navigator.of(context).pushNamedAndRemoveUntil( //Navigiert zum Anmeldebildschirm (loginRoute) und entfernt alle vorherigen Routen aus dem Navigator-Stack.
                      loginRoute,
                          (_) => false, //Der zweite Parameter ist eine Rückruffunktion, die false zurückgibt, was bedeutet, dass keine der vorherigen Routen beibehalten werden sollen.
                    );
                  }
              }
            },
            itemBuilder: (context) { //Eine Funktion, die die Menüelemente für das Popup-Menü erstellt. In diesem Fall wird ein einzelnes Menüelement "Log out" erstellt.
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder( //Ein FutureBuilder, der eine asynchrone Operation überwacht und basierend auf dem Zustand des Future verschiedene Widgets anzeigt.
        future: _notesService.getOrCreateUser(email: userEmail), //Das Future, das überwacht wird.
        // Es ruft die Methode "getOrCreateUser" des "NotesService auf", um sicherzustellen, dass der Benutzer vorhanden ist oder erstellt wird.
        builder: (context, snapshot) { //Eine Funktion, die basierend auf dem aktuellen Zustand des Future verschiedene Widgets rendert. Der snapshot enthält den aktuellen Zustand des Future.
          switch (snapshot.connectionState) { //Ein switch-Statement, das den Zustand des Future überprüft und entsprechend reagiert.
            case ConnectionState.done: //Wenn der Future abgeschlossen ist (done), wird ein StreamBuilder verwendet, um die Notizen anzuzeigen.
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting: //Wenn auf die Fertigstellung des Future gewartet wird, wird ein Text "Waiting for all notes..." angezeigt.
                    case ConnectionState.active: //Wenn der Stream aktiv ist und Daten sendet --> Es wird auch der Text returnt
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(id: note.id);
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                    default:
                      return const CircularProgressIndicator();
                      //"ConnectionState.active" wird verwendet, um anzuzeigen, dass der Stream aktiv ist und Daten sendet,
                      //aber noch nicht abgeschlossen ist. Durch das Kombinieren von "ConnectionState.waiting" und
                      //"ConnectionState.active" im "switch"-Statement kann die Benutzeroberfläche in beiden Fällen
                      //denselben Hinweis ("Waiting for all notes...") anzeigen, um den Benutzer darüber zu informieren,
                      //dass das System auf die Verfügbarkeit der Notizen wartet.
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}