import 'package:notes_app/constants.dart';

class Note {
  final int id;
  final String title;
  final String content;

  Note({
    this.id,
    this.title,
    this.content
  });

  // Converts a note to map
  Map<String, dynamic> toMap() {
    return {
      noteId: id,
      noteTitle: title,
      noteContent: content
    };
  }
}