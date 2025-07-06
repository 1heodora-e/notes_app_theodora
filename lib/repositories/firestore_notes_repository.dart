
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/notes_repository.dart';

class FirestoreNotesRepository implements NotesRepository {
  final FirebaseFirestore _firestore;

  FirestoreNotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Note>> getNotesStream(String userId) {
    print('FirestoreNotesRepository: Setting up notes stream for userId: $userId');
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      print('FirestoreNotesRepository: Received new query snapshot! Docs count: ${querySnapshot.docs.length}');
      for (var doc in querySnapshot.docs) {
        print('  Doc ID: ${doc.id}, Data: ${doc.data()}');
      }
      final notes = querySnapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      print('FirestoreNotesRepository: Converted notes list length: ${notes.length}');
      return notes;
    });
  }

  @override
  Future<void> addNote(String userId, String title, String content) async {
    await _firestore.collection('notes').add({
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    await _firestore.collection('notes').doc(noteId).update({
      'title': newTitle,
      'content': newContent,
    });
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}