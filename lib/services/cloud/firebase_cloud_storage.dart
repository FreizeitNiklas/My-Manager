import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorial_flutter/services/cloud/cloud_storage_constants.dart';
import 'package:tutorial_flutter/services/cloud/cloud_storage_exceptions.dart';
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
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event
            .docs
            .map((doc) => CloudNote.fromSnapshot( // Snapshot von jeder Änderung / die map macht aus jedem "event" (= neuer Snapshot) eine sammlung von Iterable<CloudNote> Objekten
                doc))); // bei jedem "event" werden alle Dokumente ("docs") zu einer Liste zusammen gefasst ("map") / eine Liste aus "doc" Objekten
    return allNotes;
  }

  // Erstellen einer neuen Notiz
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchNote = await document.get();
    return CloudNote(
      documentId: fetchNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  // Singleton-Pattern: Statische Instanz der Klasse
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance(); // Privater Konstruktor zur Erstellung der Instanz
  factory FirebaseCloudStorage() =>
      _shared; // Factory-Konstruktor, der die gleiche Instanz zurückgibt => talks with "_shared"
} // creating a singleton
