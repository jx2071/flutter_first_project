import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/services/cloud/cloud_note.dart';
import 'package:first_app/services/cloud/cloud_storage_constants.dart';
import 'package:first_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection(collectionPath);

  void createNewNote({required String ownerId}) async {
    await notes.add({
      userIdField: ownerId,
      textField: "",
    });
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerId}) =>
      notes.snapshots().map((value) => value.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((element) => element.userId == ownerId));

  Future<Iterable<CloudNote>> getNotes({required String ownerId}) async {
    try {
      return await notes
          .where(userIdField, isEqualTo: ownerId)
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNote(
                  documentId: doc.id,
                  userId: doc.data()[userIdField],
                  text: doc.data()[textField],
                );
              }));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textField: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
