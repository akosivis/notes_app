import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/database/notes_db_helper.dart';
import 'package:notes_app/model/NoteModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NotesApp(),
    );
  }
}

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {

  final dbHelper = DbHelper.instance;
  final _inputNoteKey = GlobalKey<FormState>();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteBodyController = TextEditingController();
  List<Note> noteList = [];

  @override
  void initState() {
    // TODO: implement initState
    fetchInitialNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // for the two buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Add a new item"),
                    onPressed: () {
                      // add a new note here
                      _showNoteDialog();
                    },
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text("Refresh list"),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            // for the ListView
            Expanded(
                child: noteList.isEmpty
                    ? Center(child: Text("You have no notes!"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: noteList.length,
                        itemBuilder: (context, index) => createNoteDisplay(noteList[index])))
          ],
        ),
      ),
    );
  }

  void _showNoteDialog() {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.NO_HEADER,
        body: Center(
          child: Form(
            key: _inputNoteKey,
            child: Column(
              children: <Widget>[
                // TextFormField for note's title
                TextFormField(
                  controller: _noteTitleController,
                  decoration: new InputDecoration(
                      hintStyle: new TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic),
                      hintText: "Title",
                      fillColor: Colors.white),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter some text for the note's title";
                    }

                    return null;
                  },
                ),

                // TextFormField for note's content
                TextFormField(
                  controller: _noteBodyController,
                  decoration: new InputDecoration(
                      hintStyle: new TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic),
                      hintText: "Enter note's content here",
                      fillColor: Colors.white),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter some text for the note's content";
                    }

                    return null;
                  },
                ),

                // Button to enter the note!
                ElevatedButton(
                  onPressed: () {
                    if (_inputNoteKey.currentState.validate()) {
                      // save the note
                      String title = _noteTitleController.text;
                      String content = _noteBodyController.text;

                      insertNote(title, content);
                      // close the dialog here

                    }
                  },
                  child: Text('Save note'),
                )
              ],
            ),
          ),
        ),
        title: 'This is Ignored',
        desc: 'This is also Ignored')
      ..show().then((value) {
        _noteBodyController.clear();
        _noteTitleController.clear();
      });
  }

  Future<void> insertNote(String title, String content) async {
    final noteModel = Note(title: title, content: content);

    // insert the note in the database here
    final id = await dbHelper.insert(noteModel);
    print('inserted row id: $id');

    if (id > 0) {
      // successfully inserted
      // refresh the list here
      noteList = await dbHelper.getAllNotes();
      setState(() {});

    }

  }

  Future<void> fetchInitialNotes() async {
    noteList = await dbHelper.getAllNotes();
  }

  createNoteDisplay(Note noteList) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(noteList.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
                Text(noteList.content,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
