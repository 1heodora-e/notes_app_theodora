// lib/models/note.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final Timestamp timestamp;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return Note(
      id: doc.id,
      userId: (data?['userId'] as String?) ?? '',
      title: (data?['title'] as String?) ?? '',
      content: (data?['content'] as String?) ?? '',
      timestamp: (data?['timestamp'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object> get props => [id, userId, title, content, timestamp];
}