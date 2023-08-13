import 'package:first_app/services/auth/auth_service.dart';
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
  late final NotesService _notesService;

  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
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
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (action) async {
                switch (action) {
                  case MenuAction.logout:
                    final logout = await showLogoutDialog(context: context);
                    log(logout.toString());
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
        body: FutureBuilder(
            future: _notesService.getOrCreateUser(email: userEmail),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as List<DatabaseNote>;
                            log(allNotes.toString());
                            return NotesListView(
                                notes: allNotes,
                                onDeleteNote: (note) async {
                                  await _notesService.deleteNote(id: note.id);
                                });
                          } else {
                            return const CircularProgressIndicator();
                          }
                        default:
                          return const CircularProgressIndicator();
                      }
                    },
                  );
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
