import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorial_flutter/services/crud/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudNote {
  final String documentId; // Ein endgültiges (unveränderliches) Feld für die Dokument-ID
  final String ownerUserId;
  final String text;
  const CloudNote({ // Der konstante Konstruktor, der verwendet wird, um Instanzen der Klasse zu erstellen.
    required this.documentId, //über "this" weißt dem Feld "documentId" den Wert zu, der beim Erstellen des Objekts an den Konstruktor übergeben wird
    required this.ownerUserId,
    required this.text
  });

  // Ein benannter Konstruktor, der eine CloudNote-Instanz aus einem Datenbank-Snapshot erstellt.
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) : //QDS kommt von der Bib. Ist eine Dokument aus der Abfrageerbenisliste
    documentId = snapshot.id, // Weist die Dokument-ID des Snapshots dem Feld documentId zu
    ownerUserId = snapshot.data()[ownerUserIdFieldName], // Holt die Besitzer-ID aus den Snapshot-Daten und weist sie dem Feld ownerUserId zu
    text = snapshot.data()[textFieldName] as String;
}
