import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  // delete note
  Future<void> deleteNote({required String documentId}) async {
    try {
      notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // update note
  Future<void> updateNote({required String documentId, required text}) async {
    try {
      notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // all notes for a specific user
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) => notes
      .snapshots()
      .map((event) => event.docs // see all changes that happen live
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) =>
              note.ownerUserId == ownerUserId)); // notes created by the user

  // getting notes by user ID
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo:
                ownerUserId, //ornerUserIdFieldName equal to the ownserUserId
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(
                doc)), // convert each document into a CloudNote objject
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote =
        await document.get(); // immediately fetch back from the firestore
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  // implement FirebaseCloudStorage as a singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;
}
