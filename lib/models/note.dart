// lib/models/note.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final Timestamp timestamp; // Use Timestamp for consistent Firestore dates

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to create a Note object from a Firestore DocumentSnapshot
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id, // The document ID from Firestore
      userId: data['userId'] as String? ?? '', // Handle potential null
      title: data['title'] as String? ?? 'No Title', // Handle potential null
      content: data['content'] as String? ?? '', // Handle potential null
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(), // Handle potential null
    );
  }

  // Method to convert a Note object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }
}