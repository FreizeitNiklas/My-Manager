import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorial_flutter/services/crud/cloud/cloud_storage_constants.dart';
import 'package:tutorial_flutter/services/crud/cloud/cloud_storage_exceptions.dart';
import 'cloud_note.dart';

class FirebaseCloudStorage {
  // Eine Referenz auf die 'notes'-Sammlung in Firestore.
  final notes = FirebaseFirestore.instance.collection('notes');

  // Methode zum Löschen einer Notiz basierend auf der Dokument-ID
  Future<void> deleteNote({required String documentId}) async {
    try {
      // Versucht, die Notiz zu löschen
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // Methode zum Aktualisieren des Textes einer Notiz
  Future<void> updateNote({
    required String documentId,
    required String text,
}) async {
    try {
      // Versucht, die Notiz in Firestore zu aktualisieren
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // Gibt einen Stream von Notizen für einen bestimmten Benutzer zurück
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) => // Stream sendet jedes mal, wenn die Datenbank aktualisiert wird
    notes.snapshots().map((event) => // Snapshot von jeder Änderung / die map macht aus jedem "event" (= neuer Snapshot) eine sammlung von Iterable<CloudNote> Objekten
        event.docs.map((doc) => // bei jedem "event" werden alle Dokumente ("docs") zu einer Liste zusammen gefasst ("map") / eine Liste aus "doc" Objekten
            CloudNote.fromSnapshot(doc)) // Umwandlung in ein nutzbares Datenmodell / "doc" wird durch "fromSnapshot" übergeben und zu "CloudNote" Objekten gemacht
    .where((note) => note.ownerUserId == ownerUserId)); // filtern der "note" nach den "note" bei denen der "ownerUserId" übereinstimmt

  // Methode zum Abrufen aller Notizen eines bestimmten Benutzers
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async{
    try {
      // Abrufen aller Dokumente aus der 'notes'-Sammlung, die zum angegebenen Benutzer gehören
      await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId
          )
          .get() // Führt die Abfrage aus und holt die entsprechenden Dokumente
          .then( // Nach dem Abrufen der Dokumente wird eine Funktion ausgeführt
            (value) => value.docs.map( // "(value)" ist das Ergebnis von ".get" / Mapped jedes Dokument (doc) in der Liste der abgerufenen Dokumente (value.docs)
             (doc) { // sorgt dafür, dass das {} auf jedes "doc" in der Liste angewendet wird
              return CloudNote( // Gibt eine "CloudNote" zurück
                documentId: doc.id, // Weist die Dokument-ID der Notiz zu
                ownerUserId: doc.data()[ownerUserIdFieldName] as String, // Weist die Benutzer-ID aus den Dokumentdaten zu
                text: doc.data()[textFieldName] as String, // Weist den Textinhalt der Notiz aus den Dokumentdaten zu
              );
            },
         ),
       );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  // Erstellen einer neuen Notiz
  void createNewNote({required String ownerUserID}) async {
    notes.add({
      ownerUserIdFieldName: ownerUserID,
      textFieldName: '',
    });
  }

  // Singleton-Pattern: Statische Instanz der Klasse
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance(); // Privater Konstruktor zur Erstellung der Instanz
  factory FirebaseCloudStorage() => _shared; // Factory-Konstruktor, der die gleiche Instanz zurückgibt => talks with "_shared"
} // creating a singleton