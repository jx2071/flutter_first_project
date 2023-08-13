import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/crud/notes_service.dart';
import 'package:first_app/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef NoteCallBack = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            onTap(note);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context: context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            tooltip: "Delete Note",
          ),
        );
      },
    );
  }
}
