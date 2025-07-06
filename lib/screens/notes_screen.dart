// lib/screens/notes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/cubits/auth/auth_cubit.dart';
import 'package:notes_app/cubits/notes/notes_cubit.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';
import 'package:notes_app/models/note.dart'; // Ensure this import is correct

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      context.read<NotesCubit>().listenToNotes(currentUser.uid);
    } else {
      print('Error: User is null in NotesScreen initState. Cannot listen to notes.');
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesCubit, NotesState>(
      listener: (context, state) {
        if (state is NotesError) {
          _showSnackBar(context, state.message, isError: true);
        } else if (state is NotesActionSuccess) {
          _showSnackBar(context, state.message);
        }
      },
      // IMPORTANT: buildWhen controls when the builder function rebuilds the UI
      buildWhen: (previousState, currentState) {
        // Only rebuild the UI if the current state is NotesLoaded, NotesLoading, or NotesError.
        // This prevents the UI from briefly showing an empty state or
        // flickering when NotesActionSuccess is emitted, as NotesActionSuccess
        // is handled by the listener, not by rebuilding the main body.
        return currentState is NotesLoaded || currentState is NotesLoading || currentState is NotesError;
      },
      builder: (context, state) {
        // The builder only gets states that pass the buildWhen condition
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Notes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
              ),
            ],
          ),
          body: state is NotesLoading
              ? const Center(child: CircularProgressIndicator())
              : state is NotesLoaded
              ? state.notes.isEmpty
              ? const Center(child: Text('No notes yet. Add one!'))
              : ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return Card(
                key: ValueKey(note.id), // Crucial for list optimization
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(note.content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showNoteDialog(context, note: note),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this note?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      context.read<NotesCubit>().deleteNote(note.id);
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
              : state is NotesError // Handle NotesError if it's the current state
              ? Center(child: Text('Error: ${state.message}'))
              : const Center(child: Text('Press the + button to add your first note!')), // Default fallback

          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNoteDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showNoteDialog(BuildContext context, {Note? note}) {
    final TextEditingController _titleController = TextEditingController(text: note?.title);
    final TextEditingController _contentController = TextEditingController(text: note?.content);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(note == null ? 'Add New Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String title = _titleController.text.trim();
                final String content = _contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    if (note == null) {
                      context.read<NotesCubit>().addNote(currentUser.uid, title, content);
                    } else {
                      context.read<NotesCubit>().updateNote(note.id, title, content);
                    }
                    Navigator.of(dialogContext).pop();
                  } else {
                    _showSnackBar(context, 'You must be logged in to perform this action!', isError: true);
                  }
                } else {
                  _showSnackBar(context, 'Title and Content cannot be empty!', isError: true);
                }
              },
              child: Text(note == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}