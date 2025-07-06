// lib/cubits/notes/notes_state.dart
import 'package:equatable/equatable.dart';
import 'package:notes_app/models/note.dart';

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


class NotesActionSuccess extends NotesState {
  final String message;

  const NotesActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}