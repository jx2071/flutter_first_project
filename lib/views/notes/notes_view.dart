import 'package:first_app/services/auth/auth_service.dart';
import 'package:first_app/services/cloud/cloud_note.dart';
import 'package:first_app/services/cloud/firebase_cloud_storage.dart';
import 'package:first_app/services/crud/notes_service.dart';
import 'package:first_app/views/notes/notes_list_view.dart';
import 'package:first_app/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';

import 'package:first_app/constants/routes.dart';
import 'package:first_app/enums.dart';

import 'dart:developer' show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  String get userId => AuthService.firebase().currentUser!.userId;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    //_notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Note'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
            tooltip: "Create A New Note",
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (action) async {
              switch (action) {
                case MenuAction.logout:
                  final logout = await showLogoutDialog(context: context);
                  if (logout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
                  break;
                default:
                  log('Unknown action: $action');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.settings,
                child: Text('Settings'),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
              )
            ],
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                if (allNotes.isNotEmpty) {
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return Center(
                      child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text("You don't have any notes",
                          style: TextStyle(
                            fontSize: 15,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Create Now",
                              style: TextStyle(
                                fontSize: 15,
                              )),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(createUpdateNoteRoute);
                            },
                            icon: const Icon(Icons.add),
                            tooltip: "Create A New Note",
                          ),
                        ],
                      ),
                    ],
                  ));
                }
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
