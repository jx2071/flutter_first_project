import 'dart:async';
import 'dart:developer';

import 'package:first_app/extensions/list/filter.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'package:first_app/services/crud/crud_exceptions.dart';
import "package:first_app/services/crud/crud_constants.dart";

class NotesService {
  Database? _db;

  DatabaseUser? _user;

  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  static final NotesService _shared = NotesService._sharedInstance();

  factory NotesService() => _shared;

  Database _getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserNotSetBeforeReadingNotesException();
        }
      });

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();

    _notesStreamController.add(_notes);
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //log("DB Already Open");
    }
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createUserTableSQL);
      // create note table
      await db.execute(createNoteTableSQL);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _getDatabase();
    await db.close();
    _db = null;
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final deleteCount = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final result = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final id = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: id, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final result = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw UserNotFoundException();
    }
    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) _user = user;
      return user;
    } on UserNotFoundException {
      final user = await createUser(email: email);
      if (setAsCurrentUser) _user = user;
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final deleteCount = await db.delete(
      noteTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (deleteCount != 1) {
      throw CouldNotDeleteNoteException();
    }
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNote() async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final deleteCount = await db.delete(noteTable);
    // update local cache
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw UserNotFoundException();
    }

    // create note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      cloudSyncColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      cloudSync: true,
    );
    // update local cache
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw NoteNotFoundException();
    }

    final note = DatabaseNote.fromRow(notes.first);
    // update local cache
    _notes.removeWhere((oldNote) => oldNote.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final notes = await db.query(noteTable);

    if (notes.isEmpty) throw NoteNotFoundException();

    final results = notes.map((note) => DatabaseNote.fromRow(note));

    return results;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    // make sure note exists
    await getNote(id: note.id);
    // update DB
    final count = await db.update(
      noteTable,
      {
        textColumn: text,
        cloudSyncColumn: 0,
      },
      where: "$idColumn = ?",
      whereArgs: [note.id],
    );

    if (count != 1) {
      throw CouldNotUpdateNoteException();
    }

    final updateNote = await getNote(id: note.id);
    // update local cache
    _notes.removeWhere((oldNote) => oldNote.id == note.id);
    _notes.add(updateNote);
    _notesStreamController.add(_notes);

    return updateNote;
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID: $id, Email: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool cloudSync;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.cloudSync,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        cloudSync = (map[cloudSyncColumn] as int == 1) ? true : false;

  @override
  String toString() => 'Note, ID:$id, User: $userId, Sync: $cloudSync';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
