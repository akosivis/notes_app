import 'dart:async';
import 'dart:io';
import 'package:notes_app/constants.dart';
import 'package:notes_app/model/NoteModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  // make this a singleton class
  DbHelper._privateConstructor();

  static final DbHelper instance = DbHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  // opens the database/creates the database if the database is not existing
  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, databaseName);
    return await openDatabase(
        path,
        version: databaseVersion,
        onCreate: _onCreate
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $note_table (
            $noteId INTEGER PRIMARY KEY,
            $noteTitle TEXT NOT NULL,
            $noteContent TEXT NOT NULL
          )
          ''');
  }

  /*
   *  CRUD methods for notes!
   */

  // for inserting new notes, returns ID of inserted row
  Future<int> insert(Note noteModel) async {
    final Database db = await instance.database;
    return await db.insert(note_table, noteModel.toMap());
  }

  // get the List of Notes saved from database
  Future<List<Note>> getAllNotes() async {
    Database db = await instance.database;

    final List<Map> results = await db.query(note_table);

    return List.generate(results.length, (index) {
      return Note(
          id: results[index][noteId],
          title: results[index][noteTitle],
          content: results[index][noteContent]
      );
    });
  }

}