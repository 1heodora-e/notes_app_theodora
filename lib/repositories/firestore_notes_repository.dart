// lib/repositories/firestore_notes_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/notes_repository.dart'; // Ensure this import is correct

class FirestoreNotesRepository implements NotesRepository {
  final FirebaseFirestore _firestore;

  // Constructor must be public and callable
  FirestoreNotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Note>> getNotesStream(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) =>
        querySnapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
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