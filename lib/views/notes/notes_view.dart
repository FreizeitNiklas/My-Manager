import 'package:flutter/material.dart';
import 'package:tutorial_flutter/services/auth/auth_service.dart';
import 'package:tutorial_flutter/services/cloud/cloud_note.dart';
import 'package:tutorial_flutter/services/cloud/firebase_cloud_storage.dart';
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
  late final FirebaseCloudStorage _notesService; //"late" bedeutet es wird erst initialisiert, sobald verwendet wird
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() { //"initState" wird einmalig aufgerufen, wenn das StatefulWidget zum ersten Mal eingefügt wird. Hier werden alle Initialisierungen vorgenommen, die nur einmal durchgeführt werden müssen.
    _notesService = FirebaseCloudStorage();
    super.initState(); //mit "super" kann man Funktionen aus der Basisiklasse aufrufen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text ('Your Notes'),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute); //Navigiert zu "newNoteRoute"
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
      body: StreamBuilder(
                stream: _notesService.allNotes(ownerUserId: userId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting: //Wenn auf die Fertigstellung des Future gewartet wird, wird ein Text "Waiting for all notes..." angezeigt.
                    case ConnectionState.active: //Wenn der Stream aktiv ist und Daten sendet --> Es wird auch der Text returnt
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as Iterable<CloudNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(documentId: note.documentId);
                          },
                          onTap: (note) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note,
                              //Beim drücken wird die cOUNR ausgeführt und die "note" übergeben
                            );
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
      ),
    );
  }
}