import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class NotesService {
  Database? _db; //"_db" ist eine Instanz der Datenbank / sie ist anfang Null, bis die Datenbank geöffnet wird
  //Mit "_db" wird die Datenbank verbindung verwaltet

  List<DatabaseNote> _notes = []; //Diese Liste hält alle Notizen die aus der Datenbank geladen werden. Sie dient als Cache.
  //Mit "_notes" werden die Notizen gecached

  static final NotesService _shared = NotesService._sharedInstance();
  //Erstellung einer einzelnen statischen Instanz von "NotesService"
  //Die Instanz wird durch Aufruf des privaten Konstruktors NotesService._sharedInstance() erstellt.
  NotesService._sharedInstance() { //Benannte konstruktoren ("._sharedInstance) werden für initalisierungen verwendet / hier sorgt er dafür, dass es nur eine Instanz der Klasse gibt
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast( //Infos übergeben / ".broadcast" -> mehrere Zuhöherer
      onListen: () { //"onListen" wird aufgerufen, wenn ein neuer Zuhöhere beitritt
        _notesStreamController.sink.add(_notes);
      }, //der neue Zuhöhrer bekommt aktuellen Zustand von "_notes"
    );   //"sink.add(_notes)" fügt die aktuelle Liste ("_notes") dem Stream hinzu, so bekommt der neue Nutzer die bestehenden Infos
  }
  factory NotesService() => _shared;
  //Dies ist ein Factory-Konstruktor, der immer die gleiche Instanz von NotesService zurückgibt, nämlich _shared.
  //"factory" wird verwendet um ein bestehendes Objekt zurückzugeben, anstatt ein neues zu erstellen.
  //NotesService ist als Singleton implementiert, was bedeutet, dass es nur eine Instanz dieser Klasse gibt.
  // Das stellt sicher, dass alle Teile der Anwendung dieselbe Datenbankverbindung und denselben Datenstatus teilen.

   late final StreamController<List<DatabaseNote>> _notesStreamController;
//"_notesStreamController" ist in StreamController, der Änderungen an den Notizen verwaltet und die Notizen an alle Abonnenten sendet.
//Die Zeile definiert eine Variable "_notesStreamController" als "StreamController",
// die eine Liste von DatabaseNote-Objekten verwaltet.

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
//"allNotes" ist ein Stream, den die UI oder andere Teile der Anwendung abonnieren können, um über Änderungen an den Notizen informiert zu werden.

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }
//Diese Methode versucht, einen Benutzer mit der angegebenen E-Mail-Adresse zu finden. Wenn der Benutzer nicht existiert, wird ein neuer Benutzer erstellt.

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }
  //Diese Methode lädt alle Notizen aus der Datenbank und aktualisiert den lokalen Cache und den StreamController.

  Future<DatabaseNote> updateNote({ //"updateNotes" aktualisiert: SQLite-Datei, lokale Liste und den Stream
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen(); //Stellt sicher, dass die Datenbank geöffnet ist
    final db = _getDatabaseOrThrow(); //Holt die Datenbankinstanz oder wirft eine Ausnahme, wenn die Datenbank nicht geöffnet ist

    // make sure note exists
    await getNote(id: note.id); //Überprüft, ob die Notiz mit der angegebenen id in der Datenbank existiert

    // update DB
    final updatesCount = await db.update(noteTable,{
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    //Aktualisiert die Notiz in der Datenbank, indem sie den Text der Notiz (textColumn) und den isSyncedWithCloudColumn auf 0 setzt.

    if (updatesCount == 0) {
      throw CouldNotUpdateNote(); //Wenn updatesCount 0 ist, bedeutet dies, dass keine Zeilen aktualisiert wurden, und es wird eine Ausnahme (CouldNotUpdateNote) ausgelöst
    } else {
     final updatedNote = await getNote(id: note.id); //Andernfalls wird die aktualisierte Notiz abgerufen, welche die lokale Liste der Notizen aktualisiert und der Stream mit den aktualisierten Notizen versorgt.
     _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
     _notesStreamController.add(_notes);
     return updatedNote; //Schließlich wird die aktualisierte Notiz zurückgegeben.
    }
  }
//Diese Methode aktualisiert den Text einer Notiz und synchronisiert die Änderung mit dem lokalen Cache und dem StreamController.

  Future<Iterable<DatabaseNote>> getAllNotes() async { //Die Methode getAllNotes ist eine asynchrone Methode, die ein Future zurückgibt. Das Future enthält eine(n) Iterable (Stream?) von DatabaseNote-Objekten.
    await _ensureDbIsOpen(); //Diese Zeile stellt sicher, dass die Datenbank geöffnet ist, bevor irgendwelche Operationen darauf ausgeführt werden.
    final db = _getDatabaseOrThrow(); //Diese Zeile holt die Datenbankinstanz. Wenn die Datenbank nicht geöffnet ist, wird eine Ausnahme ausgelöst.
    final notes = await db.query(noteTable); //"query" ist eine Warteschalnge -> Brauch ich hier weil mehrere Inhalte
    //Führt eine Abfrage auf der Tabelle noteTable aus und speichert das Ergebnis in der Variable notes.
    // Die Methode "query" gibt eine Liste von Maps zurück, wobei jede Map eine Zeile aus der Tabelle repräsentiert.

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }
  //Diese Zeile wandelt jede Zeile (jeden Eintrag in der Liste notes) in ein DatabaseNote-Objekt um. Dazu wird die Methode fromRow von DatabaseNote verwendet.
  //"notes.map" erstellt eine neue Iterable von DatabaseNote-Objekten, die aus den Zeilen der Datenbanktabelle erstellt werden.

  //Diese Methode ruft alle Notizen aus der Datenbank (das Ergebnis von der query) ab.

  Future<DatabaseNote> getNote({required int id}) async { //Dies ist eine asynchrone Methode, die eine DatabaseNote für eine gegebene ID zurückgibt. Der Parameter id ist erforderlich
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable, //Der Name der Tabelle, aus der die Daten abgefragt werden
      limit: 1, //Begrenzen der Ergebnisse auf ein einzelnes Element
      where: 'id = ?', //Er sucht ob irgendwo 'id =' vorkommt ("?" ist ein Platzhalten für das Ergebnis)
      whereArgs:  [id], //Hier steht wonach ich suche / nach der "required id" von oben
    );
    //Die Methode "query" durchsucht die Tabelle "noteTable" und verwendet die Bedingung "where: 'id = ?'" mit dem Argument "whereArgs: [id]",
    // um die spezifische Notiz zu finden. Das Ergebnis wird in der Variable "notes" gespeichert.

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first); //Wenn die Abfrage erfolgreich war, wird das erste (und einzige) Ergebnis ("notes.first") in ein DatabaseNote-Objekt umgewandelt
      _notes.removeWhere((note) => note.id == id); //Diese Zeile entfernt die Notiz mit der gegebenen ID aus der internen Liste "_notes", um sicherzustellen, dass keine doppelten Einträge vorhanden sind
      _notes.add(note); //Diese Zeile fügt die gefundene und umgewandelte Notiz zur internen Liste "_notes" hinzu.
      _notesStreamController.add(_notes); //Aktualisiert den Stream mit der neuen Liste von Notizen. Dies ist wichtig für die Synchronisierung der Benutzeroberfläche mit den neuesten Daten.
      return note; //Schließlich wird die gefundene Notiz zurückgegeben
    }
  }
//Diese Methode ruft eine spezifische Notiz anhand ihrer ID ab.

  Future<int> deleteAllNotes() async { //Das "int" steht für die Anzahl der gelöschten Einträg
    await _ensureDbIsOpen(); //warten bis Datenbank offen ist bzw. sie wird geöffnet
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable); //Ausführung DELETE-Operation auf Tabelle "noteTable",
    //Alle Einträge in dieser Tabelle werden gelöscht. Die Anzahl der gelöschten Zeilen wird in der Variablen "numberOfDeletions" gespeichert
    _notes = []; //Diese Zeile leert die interne Liste _notes, da alle Notizen aus der Datenbank gelöscht wurden und die interne Liste dies widerspiegeln sollte
    _notesStreamController.add(_notes); //Diese Zeile aktualisiert den Stream mit der neuen (leeren) Liste von Notizen. Dies ist wichtig für die Synchronisierung
    return numberOfDeletions; //Schließlich gibt die Methode die Anzahl der gelöschten Einträge zurück
  }
//Diese Methode löscht alle Notizen aus der Datenbank

  Future<void> deleteNote({required int id}) async { //Die Methode erwartet einen int-Parameter "id", der die ID der zu löschenden Notiz ist
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete( //Diese Zeile führt eine DELETE-Operation auf der Tabelle "noteTable" aus, um die Notiz mit der angegebenen ID zu löschen
      noteTable,
      where: 'id = ?', //Dies spezifiziert, dass nur die Zeilen gelöscht werden sollen, bei denen die id-Spalte mit dem übergebenen id-Wert übereinstimmt
      whereArgs: [id], //Diese Liste enthält die Werte, die anstelle der Platzhalter "?" in der where-Klausel verwendet werden. In diesem Fall enthält sie nur den Wert "id"
    );
    if (deletedCount == 0) { //Diese Bedingung überprüft, ob keine Zeilen gelöscht wurden (deletedCount ist 0). Wenn dies der Fall ist, wird eine Ausnahme geworfen.
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id); //Wenn die Notiz erfolgreich gelöscht wurde, wird sie auch aus der internen Liste _notes entfernt
      _notesStreamController.add(_notes); //Diese Zeile aktualisiert den Stream mit der neuen Liste von Notizen. Dies ist wichtig für die Synchronisierung der Benutzeroberfläche mit den neuesten Daten
    }
  }
  //Diese Methode löscht eine spezifische Notiz anhand ihrer ID

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async { //Diese Methode ist eine asynchrone Funktion (async), die ein Future-Objekt vom Typ DatabaseNote zurückgibt.
    // Sie erwartet einen Parameter "owner", der ein DatabaseUser-Objekt ist und angibt, welcher Benutzer die Notiz erstellt.
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id

    final dbUser = await getUser(email: owner.email); //Diese Zeile ruft den Benutzer aus der Datenbank ab, der die Notiz erstellen möchte, basierend auf der E-Mail des "owner"
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = ''; //Eine leere Zeichenfolge wird als Standardtext für die neue Notiz festgelegt
    //create the note
    final noteId = await db.insert(noteTable, { //Diese Zeile fügt eine neue Notiz in die Datenbank ein / Die Methode "db.insert" gibt die ID der eingefügten Notiz ("noteId") zurück / "insert" gibt als Rückgabewert eine id zurück
      userIdColumn: owner.id, //Die Notiz enthält die "userId", "text" und "isSyncedWithCloud"-Spalten
      textColumn: text,
      isSyncedWithCloudColumn: 1
    });

    final note = DatabaseNote( //Ein neues DatabaseNote-Objekt wird erstellt, das die eingefügte Notiz darstellt.
      // Es enthält die ID der Notiz, die Benutzer-ID, den Text und den Synchronisierungsstatus
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note); //Die neue Notiz wird der internen Liste _notes hinzugefügt
    _notesStreamController.add(_notes); //Aktualisierung des Streams

    return note; //Erstellte Notiz wird zurückgegeben
  }
  //Diese Methode erstellt eine neue Notiz für einen bestimmten Benutzer

  Future<DatabaseUser> getUser ({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query( //Die db.query-Methode wird verwendet, um eine Abfrage an die userTable-Tabelle zu senden.
      // Die Abfrage sucht nach einem Datensatz, dessen email-Spalte mit der angegebenen E-Mail übereinstimmt
      userTable, //Dies ist der Name der Tabelle, in der die Benutzerinformationen gespeichert sind
      limit: 1, //Begrenz Abfrageergebnisse auf 1
      where: 'email = ?', //Dies ist die Bedingung für die Abfrage. Es wird nach einem Datensatz gesucht, bei dem die email-Spalte gleich der angegebenen E-Mail-Adresse ist
      whereArgs: [email.toLowerCase()], //Diese Zeile liefert die Argumente für die Bedingung where.
      // Die E-Mail-Adresse wird in Kleinbuchstaben umgewandelt, um eine konsistente und fallunabhängige Suche zu gewährleisten
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }
  //Diese Methode ruft einen Benutzer anhand seiner E-Mail-Adresse ab
  //Wofür brauch ich das?????

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, { //Wenn kein Benutzer mit der angegebenen E-Mail existiert, wird ein neuer Datensatz in die "userTable"-Tabelle eingefügt
      emailColumn: email.toLowerCase(),
    });
    
    return DatabaseUser(
        id: userId,
        email: email,
    );
  }
  //Diese Methode erstellt einen neuen Benutzer mit der angegebenen E-Mail-Adresse

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete( //Diese Zeile führt eine Löschoperation in der userTable-Tabelle durch.
      // Die Methode db.delete gibt die Anzahl der gelöschten Datensätze zurück
        userTable,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
  //Diese Methode löscht einen Benutzer anhand seiner E-Mail-Adresse

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }
  //Diese Methode gibt die Datenbankinstanz zurück, wenn sie geöffnet ist.
  //Falls die Datenbank nicht geöffnet ist ("_db" ist null), wird eine Ausnahme "DatabaseIsNotOpen" geworfen.

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
  //Diese Methode schließt die Datenbank, wenn sie geöffnet ist.
  // Falls die Datenbank nicht geöffnet ist, wird eine Ausnahme DatabaseIsNotOpen geworfen.
  // Nach dem Schließen wird _db auf null gesetzt, um anzuzeigen, dass die Datenbank geschlossen ist.

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //Ignoriere die Ausnahme, wenn die Datenbank bereits geöffnet ist
    }
  }
//Diese Methode stellt sicher, dass die Datenbank geöffnet ist.
// Falls die Datenbank bereits geöffnet ist (DatabaseAlreadyOpenException), wird die Ausnahme ignoriert.

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory(); //"getApplicationDocumentsDirectory": Diese Methode holt den Pfad zum Verzeichnis, in dem die Anwendung Dokumente speichern kann.
      //Dies wird für die plattformübergreifende Entwicklung benötigt, da sich die Dokumentenverzeichnisse zwischen iOS und Android unterscheiden können.
      final dbPath = join(docsPath.path, dbName);
      //"join(docsPath.path, dbName)": Diese Methode kombiniert den Pfad zum Dokumentenverzeichnis und den Datenbanknamen, um den vollständigen Pfad zur Datenbankdatei zu erstellen
      final db = await openDatabase(dbPath);
      //"openDatabase(dbPath)": Diese Methode öffnet die Datenbank am angegebenen Pfad. Wenn die Datei nicht existiert, wird sie erstellt.
      _db = db; //Die geöffnete Datenbankinstanz wird der _db Variablen zugewiesen.
      //create the user table
      await db.execute(createUserTable); //Diese Zeile führt das SQL-Kommando "createUserTable" aus, um die "user" Tabelle zu erstellen, falls sie noch nicht existiert.
      // create the note table
      await db.execute(createNoteTable); //Diese Zeile führt das SQL-Kommando "createNoteTable" aus, um die "note" Tabelle zu erstellen, falls sie noch nicht existiert.
      await _cacheNotes(); //Diese Methode wird aufgerufen, um alle Notizen aus der Datenbank zwischenzuspeichern.
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory(); //Fehlermeldung dass das Dokumentverzeichnis nicht gefunden werden kann
    }
  }
}
//Diese Methode öffnet die Datenbank. Wenn die Datenbank bereits geöffnet ist, wird eine DatabaseAlreadyOpenException geworfen.
//Sie erstellt den Pfad zur Datenbankdatei und öffnet die Datenbank.
//Anschließend werden die Tabellen "userTable" und "noteTable" erstellt, falls sie noch nicht existieren, und die Notizen werden zwischengespeichert.

@immutable //Eine unveränderliche Klasse
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map) //Dieser Konstruktor erstellt eine Instanz von DatabaseUser aus einer Map, die eine Datenbankzeile repräsentiert
      : id = map[idColumn] as int, //"idColumn" und "emailColumn" sind Konstanten, die die Namen der entsprechenden Spalten in der Datenbanktabelle enthalten
        email = map[emailColumn] as String; //"map[idColumn] as int" und "map[emailColumn] as String" weisen die Werte aus der Map den Feldern id und email zu.

  @override
  String toString() => 'person, ID = $id, email = $email';
//Diese Methode gibt eine String-Repräsentation des DatabaseUser Objekts zurück, die die ID und die E-Mail-Adresse des Benutzers enthält.

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
//Diese Methode vergleicht zwei "DatabaseUser" Objekte basierend auf ihrer ID. Zwei "DatabaseUser" Objekte werden als gleich betrachtet, wenn ihre IDs gleich sind.

  @override
  int get hashCode => id.hashCode;
//Diese Methode gibt den Hashcode des DatabaseUser Objekts zurück, der auf der ID basiert. Dies ist wichtig für die Verwendung in Sets oder als Schlüssel in Maps.
}
//Diese Klasse repräsentiert einen Benutzer in der Datenbank

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map) //Dieser Konstruktor erstellt eine Instanz von "DatabaseNote" aus einer Map, die eine Datenbankzeile repräsentiert.
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
  //"idColumn", "userIdColumn", "textColumn" und "isSyncedWithCloudColumn" sind Konstanten, die die Namen der entsprechenden Spalten in der Datenbanktabelle enthalten.
  //Die Werte aus der Map werden den entsprechenden Feldern zugewiesen.

  @override
  String toString() => 'Note, ID = $id, userId = $userId, isSyncedWithClod = $isSyncedWithCloud, text = $text';
//Diese Methode gibt eine String-Repräsentation des "DatabaseNote" Objekts zurück, die die ID, die Benutzer-ID, den Synchronisationsstatus und den Text der Notiz enthält.

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;
//Diese Methode vergleicht zwei "DatabaseNote" Objekte basierend auf ihrer ID.

  @override
  int get hashCode => id.hashCode;
//Diese Methode gibt den Hashcode des "DatabaseNote" Objekts zurück, der auf der ID basiert. Dies ist wichtig für die Verwendung in Sets oder als Schlüssel in Maps.
}

const dbName = 'notes.db'; //Definiert den Namen der SQLite-Datenbankdatei als 'notes.db'.
const noteTable = 'note'; //Definiert den Namen der Tabelle für Notizen als 'note'.
const userTable = 'user'; //Definiert den Namen der Tabelle für Benutzer als 'user'.
const idColumn = 'id'; //Definiert den Namen der Spalte für die eindeutige ID in den Tabellen als 'id'.
const emailColumn = 'email'; //Definiert den Namen der Spalte für die E-Mail-Adressen der Benutzer als 'email'.
const userIdColumn = 'user_id'; //Definiert den Namen der Spalte für die Benutzer-ID in der Notizentabelle als 'user_id'.
const textColumn = 'text'; //Definiert den Namen der Spalte für den Textinhalt der Notiz als 'text'.
const isSyncedWithCloudColumn = 'is_synced_with_cloud'; //Definiert den Namen der Spalte, die angibt, ob die Notiz mit der Cloud synchronisiert ist, als 'is_synced_with_cloud'.
const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
//Definiert eine SQL-Anweisung zur Erstellung der Benutzertabelle, falls sie noch nicht existiert
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
//Definiert eine SQL-Anweisung zur Erstellung der Notizentabelle, falls sie noch nicht existiert