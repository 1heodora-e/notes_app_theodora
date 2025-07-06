// lib/cubits/notes/notes_state.dart
import 'package:equatable/equatable.dart';
import 'package:notes_app/models/note.dart'; // Import your Note model

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object> get props => [message];
}

// Add states for specific operations if needed, e.g.,
// class NoteAdding extends NotesState {}
// class NoteAdded extends NotesState {}
// class NoteDeleting extends NotesState {}
// class NoteDeleted extends NotesState {}
// class NoteUpdating extends NotesState {}
// class NoteUpdated extends NotesState {}